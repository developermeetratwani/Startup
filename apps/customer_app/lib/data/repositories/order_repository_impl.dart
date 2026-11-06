import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  OrderRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  @override
  Stream<List<OrderEntity>> watchCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _mapToOrderEntity(doc)).toList());
  }

  @override
  Stream<List<OrderEntity>> watchVendorOrders(String vendorId) {
    return _firestore
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _mapToOrderEntity(doc)).toList());
  }

  @override
  Future<(List<OrderEntity>?, Failure?)> getOrderHistory({
    required String customerId,
    int limit = 20,
    dynamic lastDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .orderBy('placedAt', descending: true)
          .limit(limit);

      if (lastDocument is DocumentSnapshot) {
        query = query.startAfterDocument(lastDocument);
      }

      final snap = await query.get();
      final orders = snap.docs.map((doc) => _mapToOrderEntity(doc)).toList();
      return (orders, null);
    } catch (e) {
      AppLogger.error('OrderRepositoryImpl.getOrderHistory', e.toString());
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(OrderEntity?, Failure?)> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) return (null, const NotFoundFailure('Order not found'));
      return (_mapToOrderEntity(doc), null);
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Stream<OrderEntity?> watchOrder(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _mapToOrderEntity(doc);
    });
  }

  @override
  Future<(String?, Failure?)> createOrder({
    required String customerId,
    required String storeId,
    required String deliveryAddressId,
    required String paymentMethod,
    String? promoCode,
    int coinRedemptionAmount = 0,
  }) async {
    try {
      // Calls createOrder Cloud Function to securely calculate totals, check inventory, and reserve
      final callable = _functions.httpsCallable('createOrder');
      final result = await callable.call({
        'storeId': storeId,
        'deliveryAddressId': deliveryAddressId,
        'paymentMethod': paymentMethod,
        'promoCode': promoCode,
        'coinRedemptionAmount': coinRedemptionAmount,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final orderId = data['orderId'] as String?;
      return (orderId, null);
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error('createOrderFunction', '${e.code}: ${e.message}');
      return (null, ServerFailure(e.message ?? 'Failed to place order'));
    } catch (e) {
      return (null, UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final callable = _functions.httpsCallable('cancelOrder');
      await callable.call({
        'orderId': orderId,
        'reason': reason,
      });
      return null;
    } on FirebaseFunctionsException catch (e) {
      return ServerFailure(e.message ?? 'Failed to cancel order');
    } catch (e) {
      return ServerFailure(e.toString());
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
      paymentMethod: data['paymentMethod'] == 'online' ? PaymentMethod.online : PaymentMethod.cod,
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
