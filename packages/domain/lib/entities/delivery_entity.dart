import 'package:equatable/equatable.dart';

enum DeliveryStatus {
  assigned, accepted, atPickup, pickedUp, atDelivery, delivered,
}

class DeliveryEntity extends Equatable {
  final String id;
  final String orderId;
  final String driverId;
  final String vendorId;
  final String customerId;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final DeliveryStatus status;
  final int deliveryFee; // paise
  final DateTime assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  const DeliveryEntity({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.vendorId,
    required this.customerId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.status,
    required this.deliveryFee,
    required this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  @override
  List<Object?> get props => [id, orderId, driverId];
}
