import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String customerId;
  final String productId;
  final String variantId;
  final String storeId;
  final String vendorId;
  final String productName;
  final String imageUrl;
  final int unitPrice; // paise — price snapshot
  final int quantity;
  final String size;
  final String color;

  const CartItemEntity({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.variantId,
    required this.storeId,
    required this.vendorId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.size,
    required this.color,
  });

  int get lineTotal => unitPrice * quantity;
  String get lineTotalDisplay => '₹${(lineTotal / 100).toStringAsFixed(0)}';

  @override
  List<Object?> get props => [id, productId, variantId];
}
