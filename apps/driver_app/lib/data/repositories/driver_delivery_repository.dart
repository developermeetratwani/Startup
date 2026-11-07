import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class DriverDeliveryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _rtdb;

  static final List<DeliveryEntity> _mockDeliveries = [
    DeliveryEntity(
      id: 'del-102',
      orderId: 'ord-delivered-7731',
      driverId: 'driver-1',
      driverName: 'Suresh Solanki',
      driverPhone: '+91 98980 12345',
      vendorId: 'vendor-kubernagar-1',
      customerId: 'cust-ahmedabad-01',
      pickupLat: 23.0768,
      pickupLng: 72.6346,
      dropLat: 23.0780,
      dropLng: 72.6360,
      status: DeliveryStatus.delivered,
      deliveryFee: 5000, // ₹50
      estimatedEtaMinutes: 0,
      documentRecord: const DriverDocumentRecord(
        aadhaarNumber: 'XXXX-XXXX-8912',
        drivingLicenseNumber: 'GJ01-20210045678',
        isVerified: true,
        isBlacklisted: false,
      ),
      assignedAt: DateTime.now().subtract(const Duration(hours: 3)),
      pickedUpAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
      deliveredAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
    ),
  ];

  DriverDeliveryRepository({
    FirebaseFirestore? firestore,
    FirebaseDatabase? rtdb,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _rtdb = rtdb ?? FirebaseDatabase.instance;

  DeliveryEntity _orderToDelivery(OrderEntity o) {
    final syncStatus = OrderSyncService.getDeliveryStatus(o.id);
    DeliveryStatus status;
    if (o.status == OrderStatus.delivered || syncStatus == DeliveryStatus.delivered) {
      status = DeliveryStatus.delivered;
    } else if (syncStatus == DeliveryStatus.atDelivery) {
      status = DeliveryStatus.atDelivery;
    } else if (syncStatus == DeliveryStatus.pickedUp || o.status == OrderStatus.pickedUp) {
      status = DeliveryStatus.pickedUp;
    } else if (syncStatus == DeliveryStatus.atPickup) {
      status = DeliveryStatus.atPickup;
    } else if (syncStatus == DeliveryStatus.accepted || o.driverId != null) {
      status = DeliveryStatus.accepted;
    } else {
      status = DeliveryStatus.assigned;
    }

    return DeliveryEntity(
      id: 'del-${o.id}',
      orderId: o.id,
      driverId: o.driverId ?? 'driver-1',
      driverName: 'Suresh Solanki',
      driverPhone: '+91 98980 12345',
      vendorId: o.vendorId,
      customerId: o.customerId,
      pickupLat: 23.0768,
      pickupLng: 72.6346,
      dropLat: 23.0795,
      dropLng: 72.6380,
      currentDriverLat: 23.0772,
      currentDriverLng: 72.6350,
      status: status,
      deliveryFee: o.pricing.driverEarning > 0 ? o.pricing.driverEarning : 4500,
      estimatedEtaMinutes: o.estimatedDeliveryMinutes,
      documentRecord: const DriverDocumentRecord(
        aadhaarNumber: 'XXXX-XXXX-8912',
        drivingLicenseNumber: 'GJ01-20210045678',
        isVerified: true,
        isBlacklisted: false,
      ),
      assignedAt: o.placedAt,
    );
  }

  Stream<List<DeliveryEntity>> watchDriverDeliveries(String driverId) {
    OrderSyncService.startBackgroundSync();
    final controller = StreamController<List<DeliveryEntity>>.broadcast();

    void emitMerged(List<DeliveryEntity> firestoreList) {
      final readyOrders = OrderSyncService.currentOrders.where((o) =>
        !OrderSyncService.hasDriverDeclined(driverId, o.id) &&
        (o.driverId == null || o.driverId == driverId) &&
        (o.status == OrderStatus.readyForPickup ||
         o.status == OrderStatus.pickedUp ||
         o.status == OrderStatus.delivered)
      ).map(_orderToDelivery).toList();

      final merged = <String, DeliveryEntity>{};
      for (final d in _mockDeliveries) {
        merged[d.id] = d;
      }
      for (final d in firestoreList) {
        merged[d.id] = d;
      }
      for (final d in readyOrders) {
        merged[d.id] = d;
      }

      final result = merged.values.toList();
      result.sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
      if (!controller.isClosed) controller.add(result);
    }

    // Initial emit
    emitMerged([]);

    // Listen to OrderSyncService changes
    final syncSub = OrderSyncService.ordersStream.listen((_) {
      emitMerged([]);
    });

    // Listen to Firestore deliveries
    try {
      _firestore
          .collection('deliveries')
          .where('driverId', isEqualTo: driverId)
          .snapshots()
          .listen((snap) {
            final list = snap.docs.map((doc) => _mapToDelivery(doc)).toList();
            emitMerged(list);
          }, onError: (e) {
            AppLogger.warning('watchDriverDeliveries', 'Firestore fallback: $e');
            emitMerged([]);
          });
    } catch (_) {}

    return controller.stream;
  }

  /// Attempts atomic delivery acceptance with multi-driver concurrency lock
  bool acceptDelivery({
    required String orderId,
    required String driverId,
    required String driverName,
  }) {
    return OrderSyncService.acceptDeliveryByDriver(
      orderId: orderId,
      driverId: driverId,
      driverName: driverName,
    );
  }

  /// Declines the delivery assignment for this driver
  void declineDelivery({
    required String orderId,
    required String driverId,
  }) {
    OrderSyncService.declineDeliveryByDriver(
      orderId: orderId,
      driverId: driverId,
    );
  }

  Future<void> updateDeliveryStatus(String deliveryId, DeliveryStatus status, String orderId) async {
    // Sync with cross-app bus & update state
    OrderSyncService.updateDeliveryProgress(orderId, status);

    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == DeliveryStatus.pickedUp) {
        updates['pickedUpAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('orders').doc(orderId).update({'status': 'picked_up'});
      } else if (status == DeliveryStatus.delivered) {
        updates['deliveredAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'delivered',
          'deliveredAt': FieldValue.serverTimestamp(),
          'paymentStatus': 'paid',
        });
      }

      await _firestore.collection('deliveries').doc(deliveryId).update(updates);
    } catch (e) {
      AppLogger.warning('updateDeliveryStatus', 'Local in-memory update active: $e');
    }
  }

  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _rtdb.ref('driverLocations/$driverId').set({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      AppLogger.warning('updateDriverLocation', 'Local simulator mode active: $e');
    }
  }

  DeliveryEntity _mapToDelivery(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final docRec = data['documentRecord'] as Map<String, dynamic>? ?? {};

    return DeliveryEntity(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? 'Suresh Solanki',
      driverPhone: data['driverPhone'] ?? '+91 98980 12345',
      vendorId: data['vendorId'] ?? '',
      customerId: data['customerId'] ?? '',
      pickupLat: (data['pickupLat'] as num?)?.toDouble() ?? 23.0768,
      pickupLng: (data['pickupLng'] as num?)?.toDouble() ?? 72.6346,
      dropLat: (data['dropLat'] as num?)?.toDouble() ?? 23.0795,
      dropLng: (data['dropLng'] as num?)?.toDouble() ?? 72.6380,
      currentDriverLat: (data['currentDriverLat'] as num?)?.toDouble() ?? 23.0772,
      currentDriverLng: (data['currentDriverLng'] as num?)?.toDouble() ?? 72.6350,
      status: _parseDeliveryStatus(data['status']),
      deliveryFee: (data['deliveryFee'] as num?)?.toInt() ?? 4500,
      estimatedEtaMinutes: (data['estimatedEtaMinutes'] as num?)?.toInt() ?? 18,
      documentRecord: DriverDocumentRecord(
        aadhaarNumber: docRec['aadhaarNumber'] ?? 'XXXX-XXXX-8912',
        drivingLicenseNumber: docRec['drivingLicenseNumber'] ?? 'GJ01-20210045678',
        isVerified: docRec['isVerified'] ?? true,
        isBlacklisted: docRec['isBlacklisted'] ?? false,
      ),
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickedUpAt: (data['pickedUpAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  DeliveryStatus _parseDeliveryStatus(dynamic status) {
    return switch (status) {
      'accepted' => DeliveryStatus.accepted,
      'atPickup' => DeliveryStatus.atPickup,
      'pickedUp' => DeliveryStatus.pickedUp,
      'atDelivery' => DeliveryStatus.atDelivery,
      'delivered' => DeliveryStatus.delivered,
      _ => DeliveryStatus.assigned,
    };
  }
}
