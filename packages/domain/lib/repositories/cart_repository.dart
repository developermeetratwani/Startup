import '../entities/cart_item_entity.dart';
import '../core/failure.dart';

abstract class CartRepository {
  Future<(List<CartItemEntity>?, Failure?)> getCartItems(String customerId);
  Stream<List<CartItemEntity>> watchCart(String customerId);
  Future<Failure?> addToCart(CartItemEntity item);
  Future<Failure?> updateQuantity({
    required String customerId,
    required String itemId,
    required int quantity,
  });
  Future<Failure?> removeFromCart({
    required String customerId,
    required String itemId,
  });
  Future<Failure?> clearCart(String customerId);
  Future<int> getCartCount(String customerId);
}
