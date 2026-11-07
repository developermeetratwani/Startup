import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class VendorOrderRepository {
  final FirebaseFirestore _firestore;

  VendorOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<OrderEntity>> watchVendorOrders(String storeId) {
    OrderSyncService.startBackgroundSync();
    // 1. Listen to cross-app live sync bus
    final localStream = OrderSyncService.ordersStream.map((orders) {
      return OrderSyncService.getOrdersForStore(storeId);
    });

    // 2. Query Firestore without multi-field composite index constraint
    Stream<List<OrderEntity>> firestoreStream;
    try {
      firestoreStream = _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .snapshots()
          .map((snap) {
            final orders = snap.docs.map((doc) => _mapToOrderEntity(doc)).toList();
            // Sort in memory by placedAt descending
            orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
            if (orders.isNotEmpty) return orders;
            return OrderSyncService.getOrdersForStore(storeId);
          })
          .handleError((error) {
            AppLogger.warning('VendorOrderRepository.watchVendorOrders', 'Fallback to OrderSync: $error');
            return OrderSyncService.getOrdersForStore(storeId);
          });
    } catch (_) {
      firestoreStream = Stream.value(OrderSyncService.getOrdersForStore(storeId));
    }

    // Merge streams with local orders as default seed
    final controller = StreamController<List<OrderEntity>>.broadcast();
    
    // Seed immediately with existing local orders
    final initial = OrderSyncService.getOrdersForStore(storeId);
    controller.add(initial);

    // Listen to local bus
    localStream.listen((orders) {
      if (!controller.isClosed) controller.add(orders);
    });

    // Listen to Firestore
    firestoreStream.listen(
      (orders) {
        if (!controller.isClosed && orders.isNotEmpty) controller.add(orders);
      },
      onError: (_) {
        if (!controller.isClosed) {
          controller.add(OrderSyncService.getOrdersForStore(storeId));
        }
      },
    );

    return controller.stream;
  }

  Future<void> acceptOrder(String orderId) async {
    OrderSyncService.updateOrderStatus(orderId, OrderStatus.confirmed);
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.warning('VendorOrderRepository.acceptOrder', e.toString());
    }
  }

  Future<void> markReadyForPickup(String orderId) async {
    OrderSyncService.updateOrderStatus(orderId, OrderStatus.readyForPickup);
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'ready_for_pickup',
        'readyAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.warning('VendorOrderRepository.markReadyForPickup', e.toString());
    }
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    OrderSyncService.updateOrderStatus(orderId, OrderStatus.cancelled);
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.warning('VendorOrderRepository.rejectOrder', e.toString());
    }
  }

  OrderEntity _mapToOrderEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final p = data['pricing'] as Map<String, dynamic>? ?? {};

    return OrderEntity(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      storeId: data['storeId'] ?? '',
      vendorId: data['vendorId'] ?? '',
      driverId: data['driverId'],
      deliveryAddressId: data['deliveryAddressId'] ?? '',
      deliveryAddressSnapshot: Map<String, dynamic>.from(data['deliveryAddressSnapshot'] ?? {}),
      status: _parseOrderStatus(data['status']),
      paymentMethod: data['paymentMethod'] == 'online' ? PaymentMethod.payOnline : PaymentMethod.cod,
      paymentStatus: _parsePaymentStatus(data['paymentStatus']),
      razorpayOrderId: data['razorpayOrderId'],
      razorpayPaymentId: data['razorpayPaymentId'],
      pricing: OrderPricing(
        productTotal: (p['productTotal'] as num?)?.toInt() ?? 0,
        deliveryCharge: (p['deliveryCharge'] as num?)?.toInt() ?? 0,
        discount: (p['discount'] as num?)?.toInt() ?? 0,
        coinRedemption: (p['coinRedemption'] as num?)?.toInt() ?? 0,
        grandTotal: (p['grandTotal'] as num?)?.toInt() ?? 0,
        platformCommission: (p['platformCommission'] as num?)?.toInt() ?? 0,
        vendorEarning: (p['vendorEarning'] as num?)?.toInt() ?? 0,
        driverEarning: (p['driverEarning'] as num?)?.toInt() ?? 0,
      ),
      cancellationReason: data['cancellationReason'],
      placedAt: (data['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  OrderStatus _parseOrderStatus(dynamic status) {
    return switch (status) {
      'confirmed' => OrderStatus.confirmed,
      'preparing' => OrderStatus.preparing,
      'ready_for_pickup' => OrderStatus.readyForPickup,
      'picked_up' => OrderStatus.pickedUp,
      'delivered' => OrderStatus.delivered,
      'cancelled' => OrderStatus.cancelled,
      'refunded' => OrderStatus.refunded,
      _ => OrderStatus.pending,
    };
  }

  PaymentStatus _parsePaymentStatus(dynamic status) {
    return switch (status) {
      'paid' => PaymentStatus.paid,
      'refunded' => PaymentStatus.refunded,
      'failed' => PaymentStatus.failed,
      _ => PaymentStatus.pending,
    };
  }
}
