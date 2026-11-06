import 'package:equatable/equatable.dart';

enum DeliveryStatus {
  assigned, accepted, atPickup, pickedUp, atDelivery, delivered,
}

class DriverDocumentRecord extends Equatable {
  final String aadhaarNumber;
  final String? aadhaarPhotoUrl;
  final String? electricityBillUrl;
  final String drivingLicenseNumber;
  final String? drivingLicensePhotoUrl;
  final bool isVerified;
  final bool isBlacklisted;
  final String? blacklistReason;

  const DriverDocumentRecord({
    required this.aadhaarNumber,
    this.aadhaarPhotoUrl,
    this.electricityBillUrl,
    required this.drivingLicenseNumber,
    this.drivingLicensePhotoUrl,
    this.isVerified = true,
    this.isBlacklisted = false,
    this.blacklistReason,
  });

  @override
  List<Object?> get props => [aadhaarNumber, drivingLicenseNumber, isBlacklisted];
}

class DeliveryEntity extends Equatable {
  final String id;
  final String orderId;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vendorId;
  final String customerId;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final double? currentDriverLat;
  final double? currentDriverLng;
  final DeliveryStatus status;
  final int deliveryFee; // in paise
  final int estimatedEtaMinutes;
  final DriverDocumentRecord? documentRecord;
  final DateTime assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  const DeliveryEntity({
    required this.id,
    required this.orderId,
    required this.driverId,
    this.driverName = 'Verified Driver Partner',
    this.driverPhone = '+91 98980 12345',
    required this.vendorId,
    required this.customerId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    this.currentDriverLat,
    this.currentDriverLng,
    required this.status,
    required this.deliveryFee,
    this.estimatedEtaMinutes = 18,
    this.documentRecord,
    required this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  @override
  List<Object?> get props => [id, orderId, driverId, status];
}
