import 'package:equatable/equatable.dart';

class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String geohash;
  final String address;
  final String city;
  final String pincode;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.address,
    required this.city,
    required this.pincode,
  });

  @override
  List<Object?> get props => [latitude, longitude];

  String get fullAddress {
    final parts = [if (address.isNotEmpty) address, city, pincode];
    return parts.join(', ');
  }
}

class StoreEntity extends Equatable {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String? bannerImageUrl;
  final String? logoImageUrl;
  final List<String> categoryIds;
  final GeoLocation location;
  final bool isOpen;
  final bool isActive;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;

  const StoreEntity({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    this.bannerImageUrl,
    this.logoImageUrl,
    required this.categoryIds,
    required this.location,
    this.isOpen = true,
    this.isActive = true,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, vendorId];
}
