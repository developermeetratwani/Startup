import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class VendorProductRepository {
  final FirebaseFirestore _firestore;

  VendorProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ProductEntity>> watchVendorProducts(String storeId) {
    return _firestore
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .asyncMap((snap) async {
      final list = <ProductEntity>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final variantsSnap = await doc.reference.collection('variants').get();
        final variants = variantsSnap.docs.map((v) {
          final vData = v.data();
          return ProductVariantEntity(
            id: v.id,
            productId: doc.id,
            size: vData['size'] ?? 'M',
            color: vData['color'] ?? 'Standard',
            colorHex: vData['colorHex'] ?? '#000000',
            additionalPrice: (vData['additionalPrice'] as num?)?.toInt() ?? 0,
            sku: vData['sku'] ?? '',
            stockCount: (vData['stockCount'] as num?)?.toInt() ?? 10,
            isAvailable: vData['isAvailable'] ?? true,
          );
        }).toList();

        list.add(ProductEntity(
          id: doc.id,
          storeId: storeId,
          vendorId: data['vendorId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          categoryId: data['categoryId'] ?? 'western',
          imageUrls: List<String>.from(data['imageUrls'] ?? []),
          basePrice: (data['basePrice'] as num?)?.toInt() ?? 0,
          discountedPrice: (data['discountedPrice'] as num?)?.toInt() ?? 0,
          isPublished: data['isPublished'] ?? true,
          tags: List<String>.from(data['tags'] ?? []),
          rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
          totalRatings: (data['totalRatings'] as num?)?.toInt() ?? 0,
          totalSold: (data['totalSold'] as num?)?.toInt() ?? 0,
          variants: variants,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ));
      }
      return list;
    });
  }

  Future<void> addProduct({
    required String storeId,
    required String vendorId,
    required String name,
    required String description,
    required String categoryId,
    required int basePrice, // in paise
    required int discountedPrice, // in paise
    required List<String> imageUrls,
    required List<Map<String, dynamic>> variants,
  }) async {
    try {
      final productRef = await _firestore.collection('products').add({
        'storeId': storeId,
        'vendorId': vendorId,
        'name': name,
        'description': description,
        'categoryId': categoryId,
        'basePrice': basePrice,
        'discountedPrice': discountedPrice,
        'imageUrls': imageUrls.isEmpty
            ? ['https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800&auto=format&fit=crop']
            : imageUrls,
        'isPublished': true,
        'isDeleted': false,
        'rating': 5.0,
        'totalRatings': 0,
        'totalSold': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      for (final v in variants) {
        await productRef.collection('variants').add({
          'productId': productRef.id,
          'size': v['size'],
          'color': v['color'],
          'colorHex': v['colorHex'] ?? '#000000',
          'additionalPrice': v['additionalPrice'] ?? 0,
          'sku': v['sku'] ?? '',
          'stockCount': v['stockCount'] ?? 10,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      AppLogger.error('addProduct', e.toString());
      rethrow;
    }
  }

  Future<void> togglePublishStatus(String productId, bool isPublished) async {
    await _firestore.collection('products').doc(productId).update({
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateVariantStock({
    required String productId,
    required String variantId,
    required int newStock,
  }) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .collection('variants')
        .doc(variantId)
        .update({
      'stockCount': newStock,
      'isAvailable': newStock > 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
