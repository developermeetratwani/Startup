import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _firestore;

  CartRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cartItems(String customerId) =>
      _firestore.collection('carts').doc(customerId).collection('items');

  @override
  Future<(List<CartItemEntity>?, Failure?)> getCartItems(String customerId) async {
    try {
      final snap = await _cartItems(customerId).get();
      final items = snap.docs.map((doc) => _mapToCartItem(doc.id, doc.data())).toList();
      return (items, null);
    } catch (e) {
      AppLogger.error('CartRepositoryImpl.getCartItems', e.toString());
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<CartItemEntity>> watchCart(String customerId) {
    return _cartItems(customerId).snapshots().map((snap) {
      return snap.docs.map((doc) => _mapToCartItem(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<Failure?> addToCart(CartItemEntity item) async {
    try {
      final ref = _cartItems(item.customerId).doc(item.id);
      final existing = await ref.get();

      if (existing.exists) {
        final currentQty = (existing.data()?['quantity'] as num?)?.toInt() ?? 1;
        await ref.update({
          'quantity': currentQty + item.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.set({
          'customerId': item.customerId,
          'productId': item.productId,
          'variantId': item.variantId,
          'storeId': item.storeId,
          'vendorId': item.vendorId,
          'productName': item.productName,
          'imageUrl': item.imageUrl,
          'unitPrice': item.unitPrice,
          'quantity': item.quantity,
          'size': item.size,
          'color': item.color,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } catch (e) {
      AppLogger.error('CartRepositoryImpl.addToCart', e.toString());
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> updateQuantity({
    required String customerId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        return removeFromCart(customerId: customerId, itemId: itemId);
      }
      await _cartItems(customerId).doc(itemId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> removeFromCart({
    required String customerId,
    required String itemId,
  }) async {
    try {
      await _cartItems(customerId).doc(itemId).delete();
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> clearCart(String customerId) async {
    try {
      final snap = await _cartItems(customerId).get();
      final batch = _firestore.batch();
      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<int> getCartCount(String customerId) async {
    try {
      final snap = await _cartItems(customerId).get();
      int count = 0;
      for (var doc in snap.docs) {
        count += (doc.data()['quantity'] as num?)?.toInt() ?? 0;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  CartItemEntity _mapToCartItem(String id, Map<String, dynamic> data) {
    return CartItemEntity(
      id: id,
      customerId: data['customerId'] ?? '',
      productId: data['productId'] ?? '',
      variantId: data['variantId'] ?? '',
      storeId: data['storeId'] ?? '',
      vendorId: data['vendorId'] ?? '',
      productName: data['productName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      unitPrice: (data['unitPrice'] as num?)?.toInt() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      size: data['size'] ?? '',
      color: data['color'] ?? '',
    );
  }
}
