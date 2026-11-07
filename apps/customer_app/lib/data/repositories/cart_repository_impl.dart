import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore? _customFirestore;
  FirebaseFirestore? _firestoreInstance;

  static final Map<String, List<CartItemEntity>> _inMemoryCarts = {};
  static final StreamController<List<CartItemEntity>> _cartController = StreamController<List<CartItemEntity>>.broadcast();

  CartRepositoryImpl({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return _firestoreInstance ??= FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _cartItems(String customerId) =>
      _firestore?.collection('carts').doc(customerId).collection('items');

  @override
  Future<(List<CartItemEntity>?, Failure?)> getCartItems(String customerId) async {
    try {
      final itemsRef = _cartItems(customerId);
      if (itemsRef == null) {
        return (_inMemoryCarts[customerId] ?? [], null);
      }
      final snap = await itemsRef.get();
      final items = snap.docs.map((doc) => _mapToCartItem(doc.id, doc.data())).toList();
      return (items.isNotEmpty ? items : (_inMemoryCarts[customerId] ?? []), null);
    } catch (e) {
      return (_inMemoryCarts[customerId] ?? [], null);
    }
  }

  @override
  Stream<List<CartItemEntity>> watchCart(String customerId) {
    try {
      final itemsRef = _cartItems(customerId);
      if (itemsRef == null) {
        return Stream.value(_inMemoryCarts[customerId] ?? []);
      }
      return itemsRef.snapshots().map((snap) {
        final list = snap.docs.map((doc) => _mapToCartItem(doc.id, doc.data())).toList();
        if (list.isNotEmpty) {
          _inMemoryCarts[customerId] = list;
          return list;
        }
        return _inMemoryCarts[customerId] ?? [];
      }).handleError((_) => _inMemoryCarts[customerId] ?? []);
    } catch (_) {
      return Stream.value(_inMemoryCarts[customerId] ?? []);
    }
  }

  @override
  Future<Failure?> addToCart(CartItemEntity item) async {
    final list = _inMemoryCarts.putIfAbsent(item.customerId, () => []);
    final existingIdx = list.indexWhere((i) => i.id == item.id);
    if (existingIdx != -1) {
      final existing = list[existingIdx];
      list[existingIdx] = CartItemEntity(
        id: existing.id,
        customerId: existing.customerId,
        productId: existing.productId,
        variantId: existing.variantId,
        storeId: existing.storeId,
        vendorId: existing.vendorId,
        productName: existing.productName,
        imageUrl: existing.imageUrl,
        unitPrice: existing.unitPrice,
        quantity: existing.quantity + item.quantity,
        size: existing.size,
        color: existing.color,
      );
    } else {
      list.add(item);
    }
    _cartController.add(list);

    try {
      final itemsRef = _cartItems(item.customerId);
      if (itemsRef != null) {
        final ref = itemsRef.doc(item.id);
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
      }
    } catch (e) {
      AppLogger.warning('CartRepositoryImpl.addToCart', 'Firestore sync pending: $e');
    }
    return null;
  }

  @override
  Future<Failure?> updateQuantity({
    required String customerId,
    required String itemId,
    required int quantity,
  }) async {
    final list = _inMemoryCarts[customerId] ?? [];
    if (quantity <= 0) {
      return removeFromCart(customerId: customerId, itemId: itemId);
    }
    final idx = list.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final item = list[idx];
      list[idx] = CartItemEntity(
        id: item.id,
        customerId: item.customerId,
        productId: item.productId,
        variantId: item.variantId,
        storeId: item.storeId,
        vendorId: item.vendorId,
        productName: item.productName,
        imageUrl: item.imageUrl,
        unitPrice: item.unitPrice,
        quantity: quantity,
        size: item.size,
        color: item.color,
      );
      _cartController.add(list);
    }

    try {
      await _cartItems(customerId)?.doc(itemId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
    return null;
  }

  @override
  Future<Failure?> removeFromCart({
    required String customerId,
    required String itemId,
  }) async {
    final list = _inMemoryCarts[customerId] ?? [];
    list.removeWhere((i) => i.id == itemId);
    _cartController.add(list);

    try {
      await _cartItems(customerId)?.doc(itemId).delete();
    } catch (_) {}
    return null;
  }

  @override
  Future<Failure?> clearCart(String customerId) async {
    _inMemoryCarts[customerId]?.clear();
    _cartController.add([]);

    final itemsRef = _cartItems(customerId);
    final fs = _firestore;
    if (itemsRef != null && fs != null) {
      try {
        final snap = await itemsRef.get();
        final batch = fs.batch();
        for (var doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<int> getCartCount(String customerId) async {
    final list = _inMemoryCarts[customerId] ?? [];
    return list.fold<int>(0, (int total, item) => total + item.quantity);
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
