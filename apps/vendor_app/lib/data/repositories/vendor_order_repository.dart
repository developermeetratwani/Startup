import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class VendorOrderRepository {
  final FirebaseFirestore _firestore;

  VendorOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<OrderEntity>> watchVendorOrders(String storeId) {
    return _firestore
        .collection('orders')
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        final rawItems = data['items'] as List<dynamic>? ?? [];
        final items = rawItems.map((itemMap) {
          final m = itemMap as Map<String, dynamic>;
          return OrderItemEntity(
            productId: m['productId'] ?? '',
            variantId: m['variantId'] ?? '',
            productName: m['productName'] ?? 'Product',
            size: m['size'] ?? 'M',
            color: m['color'] ?? 'Standard',
            unitPrice: (m['unitPrice'] as num?)?.toInt() ?? 0,
            quantity: (m['quantity'] as num?)?.toInt() ?? 1,
            lineTotal: (m['lineTotal'] as num?)?.toInt() ?? 0,
          );
        }).toList();

        final rawPricing = data['pricing'] as Map<String, dynamic>? ?? {};
        final pricing = OrderPricing(
          subtotal: (rawPricing['subtotal'] as num?)?.toInt() ?? 0,
          deliveryFee: (rawPricing['deliveryFee'] as num?)?.toInt() ?? 0,
          discount: (rawPricing['discount'] as num?)?.toInt() ?? 0,
          coinRedemption: (rawPricing['coinRedemption'] as num?)?.toInt() ?? 0,
          platformCommission: (rawPricing['platformCommission'] as num?)?.toInt() ?? 0,
          retailerPayout: (rawPricing['retailerPayout'] as num?)?.toInt() ?? 0,
          grandTotal: (rawPricing['grandTotal'] as num?)?.toInt() ?? 0,
        );

        final rawAddr = data['deliveryAddress'] as Map<String, dynamic>? ?? {};
        final deliveryAddress = AddressEntity(
          id: 'addr-${doc.id}',
          userId: data['customerId'] ?? '',
          tag: AddressTag.home,
          recipientName: rawAddr['recipientName'] ?? 'Customer',
          phone: rawAddr['phone'] ?? '',
          addressLine1: rawAddr['addressLine1'] ?? 'Local Street',
          area: rawAddr['area'] ?? 'Kubernagar',
          city: rawAddr['city'] ?? 'Ahmedabad',
          pincode: rawAddr['pincode'] ?? '382340',
          latitude: (rawAddr['latitude'] as num?)?.toDouble() ?? 23.0768,
          longitude: (rawAddr['longitude'] as num?)?.toDouble() ?? 72.6346,
          isDefault: true,
        );

        final statusStr = data['status'] as String? ?? 'PLACED';
        final status = OrderStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => OrderStatus.PLACED,
        );

        final paymentMethodStr = data['paymentMethod'] as String? ?? 'COD';
        final paymentMethod = PaymentMethod.values.firstWhere(
          (p) => p.name == paymentMethodStr,
          orElse: () => PaymentMethod.COD,
        );

        final paymentStatusStr = data['paymentStatus'] as String? ?? 'PENDING';
        final paymentStatus = PaymentStatus.values.firstWhere(
          (p) => p.name == paymentStatusStr,
          orElse: () => PaymentStatus.PENDING,
        );

        return OrderEntity(
          id: doc.id,
          orderNumber: data['orderNumber'] ?? doc.id.substring(0, 8).toUpperCase(),
          customerId: data['customerId'] ?? '',
          storeId: data['storeId'] ?? '',
          vendorId: data['vendorId'] ?? '',
          status: status,
          items: items,
          pricing: pricing,
          deliveryAddress: deliveryAddress,
          paymentMethod: paymentMethod,
          paymentStatus: paymentStatus,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'CONFIRMED',
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('acceptOrder', e.toString());
    }
  }

  Future<void> markReadyForPickup(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'READY_FOR_PICKUP',
        'readyAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('markReadyForPickup', e.toString());
    }
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'CANCELLED',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('rejectOrder', e.toString());
    }
  }
}
