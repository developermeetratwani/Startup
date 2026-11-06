import 'package:equatable/equatable.dart';

class ProductVariantEntity extends Equatable {
  final String id;
  final String productId;
  final String size;
  final String color;
  final String colorHex;
  final int additionalPrice; // paise
  final String sku;
  final int stockCount;
  final bool isAvailable;

  const ProductVariantEntity({
    required this.id,
    required this.productId,
    required this.size,
    required this.color,
    required this.colorHex,
    this.additionalPrice = 0,
    required this.sku,
    required this.stockCount,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [id, productId, size, color];
}

class ProductEntity extends Equatable {
  final String id;
  final String storeId;
  final String vendorId;
  final String name;
  final String description;
  final String categoryId;
  final List<String> imageUrls;
  final int basePrice; // paise
  final int discountedPrice; // paise
  final bool isPublished;
  final List<String> tags;
  final double rating;
  final int totalRatings;
  final int totalSold;
  final List<ProductVariantEntity> variants;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.imageUrls,
    required this.basePrice,
    required this.discountedPrice,
    this.isPublished = true,
    this.tags = const [],
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalSold = 0,
    this.variants = const [],
    required this.createdAt,
  });

  int get effectivePrice =>
      discountedPrice > 0 ? discountedPrice : basePrice;
  String get priceDisplay =>
      '₹${(effectivePrice / 100).toStringAsFixed(0)}';

  @override
  List<Object?> get props => [id, vendorId, storeId];
}
