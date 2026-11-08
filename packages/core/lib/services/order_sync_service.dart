import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';
import 'smtp_auth_service.dart';
import 'notification_service.dart';

/// Remittance Record when a driver deposits collected COD cash to the company
class DriverRemittanceRecord {
  final String id;
  final String driverId;
  final String driverName;
  final int amount; // in paise
  final String paymentMode; // 'COMPANY_UPI' or 'CASH_AT_HUB'
  final String referenceNumber;
  final DateTime submittedAt;
  bool isVerifiedByAdmin;
  DateTime? verifiedAt;

  DriverRemittanceRecord({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.amount,
    required this.paymentMode,
    required this.referenceNumber,
    required this.submittedAt,
    this.isVerifiedByAdmin = false,
    this.verifiedAt,
  });

  String get amountDisplay => '₹${(amount / 100).toStringAsFixed(0)}';
}

/// COD & Trip Reconciliation summary for a driver
class DriverCodSummary {
  final String driverId;
  final String driverName;
  final int totalCodCashCollected; // in paise
  final int totalOnlinePaidOrders;
  final int totalCodOrders;
  final int remittedCashToCompany; // in paise
  final int pendingCashInHand; // in paise (must be remitted)

  const DriverCodSummary({
    required this.driverId,
    required this.driverName,
    required this.totalCodCashCollected,
    required this.totalOnlinePaidOrders,
    required this.totalCodOrders,
    required this.remittedCashToCompany,
    required this.pendingCashInHand,
  });

  String get collectedDisplay => '₹${(totalCodCashCollected / 100).toStringAsFixed(0)}';
  String get remittedDisplay => '₹${(remittedCashToCompany / 100).toStringAsFixed(0)}';
  String get pendingCashDisplay => '₹${(pendingCashInHand / 100).toStringAsFixed(0)}';
}

/// Request for physical cash handover at a designated hub location with OTP verification
class DriverHubHandoverRequest {
  final String id;
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String hubLocation;
  final int amount; // in paise
  final String otp;
  final DateTime createdAt;
  bool isVerified;
  DateTime? verifiedAt;
  String? adminId;
  String? receiptNumber;
  String firestoreSyncStatus;

  DriverHubHandoverRequest({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.hubLocation,
    required this.amount,
    required this.otp,
    required this.createdAt,
    this.isVerified = false,
    this.verifiedAt,
    this.adminId,
    this.receiptNumber,
    this.firestoreSyncStatus = 'PENDING_SYNC',
  });

  String get amountDisplay => '₹${(amount / 100).toStringAsFixed(0)}';
}

/// Real-time Cross-App Order Synchronization, Concurrency Bus & COD Hub Settlement
/// Bridges Customer App, Vendor App, Driver Partner App, and Central Admin Dashboard.
class OrderSyncService {
  static const List<String> hubLocations = [
    'Kubernagar Main Market Hub (Ahmedabad)',
    'Gandhinagar Sector 21 Collection Desk',
    'Nikol & Nana Chiloda Hub (East Ahmedabad)',
    'Ghuma & Bopal Hub Desk (West Ahmedabad)',
    'Sindhu Bhavan Road (SBR) Hub (West Ahmedabad)',
    'Prahlad Nagar & SG Highway Hub (West Ahmedabad)',
  ];

  static final List<OrderEntity> _orders = [
    OrderEntity(
      id: 'ord-kubernagar-8920',
      customerId: 'cust-ahmedabad-01',
      storeId: 'store-kubernagar-1',
      vendorId: 'vendor-kubernagar-1',
      driverId: null, // Available for dispatch
      deliveryAddressId: 'addr-ahmedabad-01',
      deliveryAddressSnapshot: const {
        'recipientName': 'Kavya Sharma',
        'phone': '+91 98765 43210',
        'addressLine1': 'B-42, Krishna Park Colony, Kubernagar Main Bazar',
        'city': 'Ahmedabad',
        'pincode': '382340',
      },
      status: OrderStatus.readyForPickup,
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      pricing: const OrderPricing(
        productTotal: 89900,
        deliveryCharge: 2500,
        packagingCharge: 899,
        codCharge: 2100,
        grandTotal: 95399,
        platformCommission: 8990,
        vendorEarning: 80910,
        driverEarning: 4500,
      ),
      estimatedDeliveryMinutes: 28,
      placedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  /// Delivery lifecycle statuses mapped by order ID
  static final Map<String, DeliveryStatus> _deliveryStatuses = {
    'ord-kubernagar-8920': DeliveryStatus.assigned,
  };

  /// Set of orders declined by each driver
  static final Map<String, Set<String>> _driverDeclinedOrders = {};

  /// Remittance records ledger
  static final List<DriverRemittanceRecord> _remittances = [
    DriverRemittanceRecord(
      id: 'REMIT-2026-101',
      driverId: 'driver-1',
      driverName: 'Suresh Solanki',
      amount: 250000, // ₹2,500
      paymentMode: 'COMPANY_UPI',
      referenceNumber: 'UPI/991204/XYZ-ADMIN',
      submittedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      isVerifiedByAdmin: true,
      verifiedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  /// Hub cash handover OTP requests
  static final List<DriverHubHandoverRequest> _handoverRequests = [
    DriverHubHandoverRequest(
      id: 'HANDOVER-2026-001',
      driverId: 'driver-1',
      driverName: 'Suresh Solanki',
      driverEmail: 'developermeetratwani@gmail.com',
      hubLocation: 'Kubernagar Main Market Hub (Ahmedabad)',
      amount: 185000, // ₹1,850
      otp: '741258',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isVerified: false,
    ),
  ];

  static final StreamController<List<OrderEntity>> _streamController =
      StreamController<List<OrderEntity>>.broadcast();

  static final StreamController<List<DriverRemittanceRecord>> _remittanceController =
      StreamController<List<DriverRemittanceRecord>>.broadcast();

  static final StreamController<List<DriverHubHandoverRequest>> _handoverController =
      StreamController<List<DriverHubHandoverRequest>>.broadcast();

  static Stream<List<OrderEntity>> get ordersStream async* {
    yield List.unmodifiable(_orders);
    yield* _streamController.stream;
  }
  static Stream<List<DriverRemittanceRecord>> get remittancesStream async* {
    yield List.unmodifiable(_remittances);
    yield* _remittanceController.stream;
  }
  static Stream<List<DriverHubHandoverRequest>> get handoversStream async* {
    yield List.unmodifiable(_handoverRequests);
    yield* _handoverController.stream;
  }

  static List<OrderEntity> get currentOrders => List.unmodifiable(_orders);
  static List<DriverRemittanceRecord> get currentRemittances => List.unmodifiable(_remittances);
  static List<DriverHubHandoverRequest> get currentHandovers => List.unmodifiable(_handoverRequests);

  // ── BRIDGE INTER-APP SYNC ──────────────────────────────────────────
  static String? _resolvedBaseUrl;
  static const List<String> _candidateUrls = [
    'http://localhost:5055',
    'http://127.0.0.1:5055',
    'http://10.0.2.2:5055',
  ];

  static Future<String> _getBaseUrl() async {
    if (_resolvedBaseUrl != null) return _resolvedBaseUrl!;
    for (final url in _candidateUrls) {
      try {
        final res = await http.get(Uri.parse('$url/health')).timeout(const Duration(milliseconds: 600));
        if (res.statusCode == 200) {
          _resolvedBaseUrl = url;
          return url;
        }
      } catch (_) {}
    }
    _resolvedBaseUrl = 'http://localhost:5055';
    return _resolvedBaseUrl!;
  }

  static Timer? _syncTimer;
  static bool _isSyncing = false;

  /// Starts periodic polling to sync with all apps through the local bridge server
  static void startBackgroundSync() {
    if (_streamController.hasListener) {
      _streamController.add(List.unmodifiable(_orders));
    }
    if (_syncTimer != null) return;
    syncFromBridgeServer();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      syncFromBridgeServer();
    });
  }

  /// Manually synchronizes in-memory orders from the central bridge server
  static Future<void> syncFromBridgeServer() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final baseUrl = await _getBaseUrl();
      final res = await http.get(Uri.parse('$baseUrl/api/orders')).timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        final fetchedOrders = list.map((item) => _orderFromJson(item as Map<String, dynamic>)).toList();

        bool hasChanges = false;
        if (fetchedOrders.length != _orders.length) {
          hasChanges = true;
        } else {
          for (int i = 0; i < fetchedOrders.length; i++) {
            if (fetchedOrders[i].id != _orders[i].id ||
                fetchedOrders[i].status != _orders[i].status ||
                fetchedOrders[i].driverId != _orders[i].driverId) {
              hasChanges = true;
              break;
            }
          }
        }

        if (hasChanges) {
          _orders.clear();
          _orders.addAll(fetchedOrders);
          for (final o in _orders) {
            if (o.status == OrderStatus.readyForPickup) {
              _deliveryStatuses.putIfAbsent(o.id, () => DeliveryStatus.assigned);
            } else if (o.status == OrderStatus.pickedUp) {
              _deliveryStatuses[o.id] = DeliveryStatus.pickedUp;
            } else if (o.status == OrderStatus.delivered) {
              _deliveryStatuses[o.id] = DeliveryStatus.delivered;
            }
          }
          _streamController.add(List.unmodifiable(_orders));
        }
      }
    } catch (_) {
      // Ignore background transient network hiccups
    } finally {
      _isSyncing = false;
    }
  }

  /// Registers a newly placed customer order
  static void registerOrder(OrderEntity order) {
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx >= 0) {
      _orders[idx] = order;
    } else {
      _orders.insert(0, order);
    }
    _deliveryStatuses[order.id] = DeliveryStatus.assigned;
    AppLogger.info('OrderSyncService', 'Dispatched order ${order.id} to Vendor & Driver pipeline');
    _streamController.add(List.unmodifiable(_orders));

    // Push to central bridge server for cross-app broadcast
    _pushOrderToBridge(order);
  }

  static Future<void> _pushOrderToBridge(OrderEntity order) async {
    try {
      final baseUrl = await _getBaseUrl();
      await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_orderToJson(order)),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      AppLogger.warning('OrderSyncService._pushOrderToBridge', e.toString());
    }
  }

  /// Updates status (vendor confirmation, ready for pickup, etc.)
  static void updateOrderStatus(String orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final existing = _orders[idx];
      _orders[idx] = OrderEntity(
        id: existing.id,
        customerId: existing.customerId,
        storeId: existing.storeId,
        vendorId: existing.vendorId,
        driverId: existing.driverId,
        deliveryAddressId: existing.deliveryAddressId,
        deliveryAddressSnapshot: existing.deliveryAddressSnapshot,
        status: status,
        paymentMethod: existing.paymentMethod,
        paymentStatus: status == OrderStatus.delivered ? PaymentStatus.paid : existing.paymentStatus,
        pricing: existing.pricing,
        estimatedDeliveryMinutes: existing.estimatedDeliveryMinutes,
        placedAt: existing.placedAt,
      );

      if (status == OrderStatus.confirmed) {
        NotificationService.dispatchStageChange(
          orderId: orderId,
          status: 'Confirmed',
          message: 'Boutique accepted order #${orderId.substring(0, orderId.length > 6 ? 6 : orderId.length)} and started packing.',
        );
      } else if (status == OrderStatus.preparing) {
        NotificationService.dispatchStageChange(
          orderId: orderId,
          status: 'Preparing',
          message: 'Clothing boutique is packaging your fashion items with care.',
        );
      } else if (status == OrderStatus.readyForPickup) {
        _deliveryStatuses[orderId] = DeliveryStatus.assigned;
        NotificationService.dispatchStageChange(
          orderId: orderId,
          status: 'Ready for Pickup',
          message: 'Order packed! Driver Suresh Solanki assigned for pickup.',
        );
        NotificationService.dispatchHandoverOtp(
          orderId: orderId,
          driverName: 'Suresh Solanki',
          otpCode: '4821',
        );
      } else if (status == OrderStatus.pickedUp) {
        _deliveryStatuses[orderId] = DeliveryStatus.pickedUp;
        NotificationService.dispatchStageChange(
          orderId: orderId,
          status: 'Out for Delivery',
          message: 'Driver Suresh Solanki picked up your package. Live tracking active!',
        );
        NotificationService.dispatchProximityAlert(
          orderId: orderId,
          driverName: 'Suresh Solanki',
          distanceMeters: 90,
        );
      } else if (status == OrderStatus.delivered) {
        _deliveryStatuses[orderId] = DeliveryStatus.delivered;
        NotificationService.dispatchDeliveryCompleted(
          orderId: orderId,
          customerName: 'Customer',
        );
      }

      AppLogger.info('OrderSyncService', 'Order $orderId status updated to $status');
      _streamController.add(List.unmodifiable(_orders));

      // Push update to bridge server
      _pushStatusToBridge(orderId, status.name);
    }
  }

  static Future<void> _pushStatusToBridge(String orderId, String statusName) async {
    try {
      final baseUrl = await _getBaseUrl();
      await http.post(
        Uri.parse('$baseUrl/api/orders/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'status': statusName}),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      AppLogger.warning('OrderSyncService._pushStatusToBridge', e.toString());
    }
  }

  /// Multi-Driver Concurrency Orchestration Lock:
  /// Atomically claims an order for [driverId].
  /// If another driver has already claimed this order, returns false to prevent two drivers at one location.
  static bool acceptDeliveryByDriver({
    required String orderId,
    required String driverId,
    required String driverName,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return false;

    final existing = _orders[idx];

    // Orchestration Concurrency Guard: Check if another driver claimed it
    if (existing.driverId != null && existing.driverId != driverId) {
      AppLogger.warning('OrderSyncService', 'CONCURRENCY CONFLICT: Order $orderId already claimed by ${existing.driverId}');
      return false; // Rejected: Locked by another driver!
    }

    // Atomically lock order to this driver
    _orders[idx] = OrderEntity(
      id: existing.id,
      customerId: existing.customerId,
      storeId: existing.storeId,
      vendorId: existing.vendorId,
      driverId: driverId,
      deliveryAddressId: existing.deliveryAddressId,
      deliveryAddressSnapshot: existing.deliveryAddressSnapshot,
      status: existing.status,
      paymentMethod: existing.paymentMethod,
      paymentStatus: existing.paymentStatus,
      pricing: existing.pricing,
      estimatedDeliveryMinutes: existing.estimatedDeliveryMinutes,
      placedAt: existing.placedAt,
    );

    _deliveryStatuses[orderId] = DeliveryStatus.accepted;
    AppLogger.info('OrderSyncService', 'Order $orderId atomically locked to driver $driverName ($driverId)');
    _streamController.add(List.unmodifiable(_orders));

    _pushDriverAcceptanceToBridge(orderId, driverId, driverName);
    return true;
  }

  static Future<void> _pushDriverAcceptanceToBridge(String orderId, String driverId, String driverName) async {
    try {
      final baseUrl = await _getBaseUrl();
      await http.post(
        Uri.parse('$baseUrl/api/orders/accept-driver'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'driverId': driverId, 'driverName': driverName}),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      AppLogger.warning('OrderSyncService._pushDriverAcceptanceToBridge', e.toString());
    }
  }

  /// Decline delivery assignment by a driver:
  /// Releases order from this driver's screen so they can receive other assignments,
  /// and makes it available to other drivers in the cluster.
  static void declineDeliveryByDriver({
    required String orderId,
    required String driverId,
  }) {
    _driverDeclinedOrders.putIfAbsent(driverId, () => {}).add(orderId);

    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0 && _orders[idx].driverId == driverId) {
      final existing = _orders[idx];
      _orders[idx] = OrderEntity(
        id: existing.id,
        customerId: existing.customerId,
        storeId: existing.storeId,
        vendorId: existing.vendorId,
        driverId: null, // Released
        deliveryAddressId: existing.deliveryAddressId,
        deliveryAddressSnapshot: existing.deliveryAddressSnapshot,
        status: existing.status,
        paymentMethod: existing.paymentMethod,
        paymentStatus: existing.paymentStatus,
        pricing: existing.pricing,
        estimatedDeliveryMinutes: existing.estimatedDeliveryMinutes,
        placedAt: existing.placedAt,
      );
    }

    _deliveryStatuses[orderId] = DeliveryStatus.assigned;
    AppLogger.info('OrderSyncService', 'Driver $driverId declined order $orderId');
    _streamController.add(List.unmodifiable(_orders));
  }

  /// Updates driver delivery stepper progress
  static void updateDeliveryProgress(String orderId, DeliveryStatus status) {
    _deliveryStatuses[orderId] = status;

    if (status == DeliveryStatus.pickedUp) {
      updateOrderStatus(orderId, OrderStatus.pickedUp);
    } else if (status == DeliveryStatus.delivered) {
      updateOrderStatus(orderId, OrderStatus.delivered);
    } else {
      _streamController.add(List.unmodifiable(_orders));
    }
  }

  static DeliveryStatus getDeliveryStatus(String orderId) {
    return _deliveryStatuses[orderId] ?? DeliveryStatus.assigned;
  }

  static bool hasDriverDeclined(String driverId, String orderId) {
    return _driverDeclinedOrders[driverId]?.contains(orderId) ?? false;
  }

  /// Calculates real-time COD cash collected, online orders, and remittance dues for a driver
  static DriverCodSummary getDriverCodSummary(String driverId, String driverName) {
    int totalCodCash = 185000; // Starter ₹1,850 baseline from completed trips
    int totalOnlineOrders = 3;
    int totalCodOrders = 2;

    for (final order in _orders) {
      if (order.driverId == driverId && order.status == OrderStatus.delivered) {
        if (order.paymentMethod == PaymentMethod.cod) {
          totalCodCash += order.pricing.grandTotal;
          totalCodOrders++;
        } else {
          totalOnlineOrders++;
        }
      }
    }

    int remitted = 0;
    for (final r in _remittances) {
      if (r.driverId == driverId && r.isVerifiedByAdmin) {
        remitted += r.amount;
      }
    }

    final pending = (totalCodCash - remitted).clamp(0, 99999999);

    return DriverCodSummary(
      driverId: driverId,
      driverName: driverName,
      totalCodCashCollected: totalCodCash,
      totalOnlinePaidOrders: totalOnlineOrders,
      totalCodOrders: totalCodOrders,
      remittedCashToCompany: remitted,
      pendingCashInHand: pending,
    );
  }

  /// Initiates physical cash handover at a specific hub location and dispatches OTP to rider's email
  static Future<DriverHubHandoverRequest> initiateHubCashHandover({
    required String driverId,
    required String driverName,
    required String driverEmail,
    required String hubLocation,
    required int amount,
  }) async {
    final otp = SmtpAuthService.generateOtp();
    final handoverId = 'HANDOVER-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final request = DriverHubHandoverRequest(
      id: handoverId,
      driverId: driverId,
      driverName: driverName,
      driverEmail: driverEmail,
      hubLocation: hubLocation,
      amount: amount,
      otp: otp,
      createdAt: DateTime.now(),
      isVerified: false,
    );

    _handoverRequests.insert(0, request);

    // Attempt Firebase Cloud write (transparently handling Firestore security rules)
    try {
      await FirebaseFirestore.instance.collection('hub_handovers').doc(handoverId).set({
        'id': handoverId,
        'driverId': driverId,
        'driverName': driverName,
        'driverEmail': driverEmail,
        'hubLocation': hubLocation,
        'amount': amount,
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      });
      request.firestoreSyncStatus = 'FIREBASE_CLOUD_SYNCED';
    } catch (e) {
      request.firestoreSyncStatus = 'FALLBACK_LOCAL_SYNC (Firestore rules restrict direct client write)';
      AppLogger.warning('OrderSyncService.initiateHubCashHandover', 'Firestore sync info: $e');
    }

    // Send Real Branded Email via SMTP
    try {
      final smtp = SmtpAuthService();
      await smtp.sendCodRemittanceOtpEmail(
        recipientEmail: driverEmail,
        driverName: driverName,
        otpCode: otp,
        amountPaise: amount,
        hubLocation: hubLocation,
      );
    } catch (e) {
      AppLogger.error('OrderSyncService.sendEmail', e.toString());
    }

    _handoverController.add(List.unmodifiable(_handoverRequests));
    _streamController.add(List.unmodifiable(_orders));
    return request;
  }

  /// Admin enters the Rider's OTP at the hub desk to verify and settle the cash handover
  static Future<(bool success, String message)> verifyHubCashHandoverWithOtp({
    required String handoverId,
    required String enteredOtp,
    required String adminId,
  }) async {
    final idx = _handoverRequests.indexWhere((h) => h.id == handoverId);
    if (idx < 0) return (false, 'Handover request #$handoverId not found.');

    final request = _handoverRequests[idx];
    if (request.isVerified) {
      return (false, 'This handover request is already settled and verified.');
    }

    if (request.otp.trim() != enteredOtp.trim()) {
      return (false, 'Invalid OTP! The code entered does not match the OTP sent to the rider.');
    }

    // Valid OTP: Approve settlement
    final receiptNum = 'RCPT-HUB-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    request.isVerified = true;
    request.verifiedAt = DateTime.now();
    request.adminId = adminId;
    request.receiptNumber = receiptNum;

    // Automatically record in the verified remittance ledger to clear driver's Cash In Hand
    final remittanceRecord = DriverRemittanceRecord(
      id: 'REMIT-${request.id}',
      driverId: request.driverId,
      driverName: request.driverName,
      amount: request.amount,
      paymentMode: 'CASH_AT_HUB (${request.hubLocation})',
      referenceNumber: receiptNum,
      submittedAt: DateTime.now(),
      isVerifiedByAdmin: true,
      verifiedAt: DateTime.now(),
    );
    _remittances.insert(0, remittanceRecord);

    // Attempt Firebase Cloud write for settled state
    try {
      await FirebaseFirestore.instance.collection('hub_handovers').doc(handoverId).update({
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'adminId': adminId,
        'receiptNumber': receiptNum,
      });
      await FirebaseFirestore.instance.collection('remittances').doc(remittanceRecord.id).set({
        'id': remittanceRecord.id,
        'driverId': request.driverId,
        'driverName': request.driverName,
        'amount': request.amount,
        'hubLocation': request.hubLocation,
        'receiptNumber': receiptNum,
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.warning('OrderSyncService.verifyHubCashHandoverWithOtp', 'Firestore update info: $e');
    }

    // Send Settlement Confirmation Receipt Email to Rider
    try {
      final smtp = SmtpAuthService();
      await smtp.sendCodSettlementConfirmedEmail(
        recipientEmail: request.driverEmail,
        driverName: request.driverName,
        settlementId: receiptNum,
        amountPaise: request.amount,
        hubLocation: request.hubLocation,
        adminId: adminId,
      );
    } catch (_) {}

    _handoverController.add(List.unmodifiable(_handoverRequests));
    _remittanceController.add(List.unmodifiable(_remittances));
    _streamController.add(List.unmodifiable(_orders));

    return (true, 'Success: Cash handover of ${request.amountDisplay} verified! Receipt #$receiptNum issued.');
  }

  /// Driver submits collected COD cash remittance to company (direct digital transfer mode)
  static void submitCashRemittance({
    required String driverId,
    required String driverName,
    required int amount,
    required String paymentMode,
    required String referenceNumber,
  }) {
    final record = DriverRemittanceRecord(
      id: 'REMIT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      driverId: driverId,
      driverName: driverName,
      amount: amount,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      submittedAt: DateTime.now(),
      isVerifiedByAdmin: false,
    );

    _remittances.insert(0, record);
    AppLogger.info('OrderSyncService', 'Driver $driverName submitted remittance of ₹${amount / 100} ($paymentMode)');
    _remittanceController.add(List.unmodifiable(_remittances));
    _streamController.add(List.unmodifiable(_orders));
  }

  /// Admin verifies and settles driver remittance
  static void verifyRemittanceByAdmin(String remittanceId) {
    final idx = _remittances.indexWhere((r) => r.id == remittanceId);
    if (idx >= 0) {
      _remittances[idx].isVerifiedByAdmin = true;
      _remittances[idx].verifiedAt = DateTime.now();
      AppLogger.info('OrderSyncService', 'Admin verified remittance $remittanceId');
      _remittanceController.add(List.unmodifiable(_remittances));
      _streamController.add(List.unmodifiable(_orders));
    }
  }

  static List<OrderEntity> getOrdersForStore(String storeId) {
    if (_orders.isEmpty) return [];
    return _orders.where((o) => o.storeId == storeId || storeId == 'store-kubernagar-1').toList();
  }

  // ── JSON SERIALIZATION HELPERS ──────────────────────────────────────
  static Map<String, dynamic> _orderToJson(OrderEntity order) {
    return {
      'id': order.id,
      'customerId': order.customerId,
      'storeId': order.storeId,
      'vendorId': order.vendorId,
      'driverId': order.driverId,
      'deliveryAddressId': order.deliveryAddressId,
      'deliveryAddressSnapshot': order.deliveryAddressSnapshot,
      'status': order.status.name,
      'paymentMethod': order.paymentMethod.name,
      'paymentStatus': order.paymentStatus.name,
      'razorpayOrderId': order.razorpayOrderId,
      'razorpayPaymentId': order.razorpayPaymentId,
      'pricing': {
        'productTotal': order.pricing.productTotal,
        'deliveryCharge': order.pricing.deliveryCharge,
        'packagingCharge': order.pricing.packagingCharge,
        'codCharge': order.pricing.codCharge,
        'exchangeCharge': order.pricing.exchangeCharge,
        'discount': order.pricing.discount,
        'coinRedemption': order.pricing.coinRedemption,
        'grandTotal': order.pricing.grandTotal,
        'platformCommission': order.pricing.platformCommission,
        'vendorEarning': order.pricing.vendorEarning,
        'driverEarning': order.pricing.driverEarning,
      },
      'exchangeReason': order.exchangeReason,
      'requestedExchangeSize': order.requestedExchangeSize,
      'cancellationReason': order.cancellationReason,
      'estimatedDeliveryMinutes': order.estimatedDeliveryMinutes,
      'placedAt': order.placedAt.toIso8601String(),
      'deliveredAt': order.deliveredAt?.toIso8601String(),
    };
  }

  static OrderEntity _orderFromJson(Map<String, dynamic> json) {
    final p = json['pricing'] is Map ? (json['pricing'] as Map).cast<String, dynamic>() : <String, dynamic>{};
    return OrderEntity(
      id: json['id'] as String? ?? 'ord-${DateTime.now().millisecondsSinceEpoch}',
      customerId: json['customerId'] as String? ?? 'cust-ahmedabad-01',
      storeId: json['storeId'] as String? ?? 'store-kubernagar-1',
      vendorId: json['vendorId'] as String? ?? 'vendor-kubernagar-1',
      driverId: json['driverId'] as String?,
      deliveryAddressId: json['deliveryAddressId'] as String? ?? 'addr-ahmedabad-01',
      deliveryAddressSnapshot: Map<String, dynamic>.from(json['deliveryAddressSnapshot'] as Map? ?? {}),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cod,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      pricing: OrderPricing(
        productTotal: (p['productTotal'] as num?)?.toInt() ?? 0,
        deliveryCharge: (p['deliveryCharge'] as num?)?.toInt() ?? 0,
        packagingCharge: (p['packagingCharge'] as num?)?.toInt() ?? 0,
        codCharge: (p['codCharge'] as num?)?.toInt() ?? 0,
        exchangeCharge: (p['exchangeCharge'] as num?)?.toInt() ?? 0,
        discount: (p['discount'] as num?)?.toInt() ?? 0,
        coinRedemption: (p['coinRedemption'] as num?)?.toInt() ?? 0,
        grandTotal: (p['grandTotal'] as num?)?.toInt() ?? 0,
        platformCommission: (p['platformCommission'] as num?)?.toInt() ?? 0,
        vendorEarning: (p['vendorEarning'] as num?)?.toInt() ?? 0,
        driverEarning: (p['driverEarning'] as num?)?.toInt() ?? 0,
      ),
      exchangeReason: json['exchangeReason'] as String?,
      requestedExchangeSize: json['requestedExchangeSize'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      estimatedDeliveryMinutes: (json['estimatedDeliveryMinutes'] as num?)?.toInt() ?? 35,
      placedAt: json['placedAt'] != null
          ? DateTime.tryParse(json['placedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
    );
  }
}
