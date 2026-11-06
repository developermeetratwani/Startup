import '../entities/order_entity.dart';
import '../core/failure.dart';

abstract class OrderRepository {
  Stream<List<OrderEntity>> watchCustomerOrders(String customerId);
  Stream<List<OrderEntity>> watchVendorOrders(String vendorId);
  Future<(List<OrderEntity>?, Failure?)> getOrderHistory({
    required String customerId,
    int limit = 20,
    dynamic lastDocument,
  });
  Future<(OrderEntity?, Failure?)> getOrderById(String orderId);
  Stream<OrderEntity?> watchOrder(String orderId);
  Future<(String?, Failure?)> createOrder({
    required String customerId,
    required String storeId,
    required String deliveryAddressId,
    required String paymentMethod,
    String? promoCode,
    int coinRedemptionAmount,
  });
  Future<Failure?> cancelOrder({
    required String orderId,
    required String reason,
  });
  Future<Failure?> requestOrderExchange({
    required String orderId,
    required String reason,
    required String requestedSize,
  });
}
