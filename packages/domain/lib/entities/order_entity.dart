import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending, confirmed, preparing, readyForPickup,
  pickedUp, delivered, cancelled, refunded, exchangeRequested, exchanged
}

enum PaymentMethod {
  cod,           // Cash on delivery (₹21 fee)
  payOnDelivery, // UPI / Card upon delivery via driver QR
  payOnline,     // Pre-paid through Razorpay gateway
  directPay      // Store direct / Instant UPI
}

enum PaymentStatus { pending, paid, refunded, failed }

class OrderPricing extends Equatable {
  final int productTotal;         // in paise
  final int deliveryCharge;       // in paise
  final int packagingCharge;      // in paise (1% per quantity base)
  final int codCharge;            // in paise (₹21 = 2100 paise if COD)
  final int exchangeCharge;       // in paise (if size exchange applied)
  final int discount;             // in paise
  final int coinRedemption;       // in paise
  final int grandTotal;           // in paise
  final int platformCommission;   // in paise
  final int vendorEarning;        // in paise
  final int driverEarning;        // in paise

  const OrderPricing({
    required this.productTotal,
    required this.deliveryCharge,
    this.packagingCharge = 0,
    this.codCharge = 0,
    this.exchangeCharge = 0,
    this.discount = 0,
    this.coinRedemption = 0,
    required this.grandTotal,
    required this.platformCommission,
    required this.vendorEarning,
    required this.driverEarning,
  });

  @override
  List<Object?> get props => [grandTotal, packagingCharge, codCharge, exchangeCharge];
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
  final String? exchangeReason;
  final String? requestedExchangeSize;
  final String? cancellationReason;
  final int estimatedDeliveryMinutes;
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
    this.exchangeReason,
    this.requestedExchangeSize,
    this.cancellationReason,
    this.estimatedDeliveryMinutes = 45,
    required this.placedAt,
    this.deliveredAt,
  });

  bool get isActive => ![
    OrderStatus.delivered,
    OrderStatus.cancelled,
    OrderStatus.refunded,
  ].contains(status);

  @override
  List<Object?> get props => [id, customerId, status];
}
