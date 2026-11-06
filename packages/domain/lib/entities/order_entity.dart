import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending, confirmed, preparing, readyForPickup,
  pickedUp, delivered, cancelled, refunded,
}
enum PaymentMethod { cod, online }
enum PaymentStatus { pending, paid, refunded, failed }

class OrderPricing extends Equatable {
  final int productTotal;
  final int deliveryCharge;
  final int discount;
  final int coinRedemption;
  final int grandTotal;
  final int platformCommission;
  final int vendorEarning;
  final int driverEarning;

  const OrderPricing({
    required this.productTotal,
    required this.deliveryCharge,
    this.discount = 0,
    this.coinRedemption = 0,
    required this.grandTotal,
    required this.platformCommission,
    required this.vendorEarning,
    required this.driverEarning,
  });

  @override
  List<Object?> get props => [grandTotal];
}

class OrderEntity extends Equatable {
  final String id;
  final String customerId;
  final String storeId;
  final String vendorId;
  final String? driverId;
  final String deliveryAddressId;
  final Map<String, dynamic> deliveryAddressSnapshot;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final OrderPricing pricing;
  final String? cancellationReason;
  final DateTime placedAt;
  final DateTime? deliveredAt;

  const OrderEntity({
    required this.id,
    required this.customerId,
    required this.storeId,
    required this.vendorId,
    this.driverId,
    required this.deliveryAddressId,
    required this.deliveryAddressSnapshot,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.pricing,
    this.cancellationReason,
    required this.placedAt,
    this.deliveredAt,
  });

  bool get isActive => ![
    OrderStatus.delivered,
    OrderStatus.cancelled,
    OrderStatus.refunded,
  ].contains(status);

  @override
  List<Object?> get props => [id, customerId];
}
