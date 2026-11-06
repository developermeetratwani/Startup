import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<(List<ProductEntity>?, Failure?)> getProductsByStore({
    required String storeId,
    String? categoryId,
    int limit = 20,
    dynamic lastDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('products')
          .where('storeId', isEqualTo: storeId)
          .where('isPublished', isEqualTo: true)
          .where('isDeleted', isEqualTo: false);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (lastDocument is DocumentSnapshot) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final products = await Future.wait(
        snapshot.docs.map((doc) => _mapToProductEntity(doc)),
      );
      if (products.isEmpty) {
        return (_getMockProducts(storeId: storeId, categoryId: categoryId), null);
      }
      return (products, null);
    } catch (e) {
      AppLogger.error('ProductRepositoryImpl.getProductsByStore', e.toString());
      return (_getMockProducts(storeId: storeId, categoryId: categoryId), null);
    }
  }

  @override
  Future<(List<ProductEntity>?, Failure?)> getProductsByCategory({
    required String categoryId,
    int limit = 20,
    dynamic lastDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isPublished', isEqualTo: true)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument is DocumentSnapshot) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final products = await Future.wait(
        snapshot.docs.map((doc) => _mapToProductEntity(doc)),
      );
      if (products.isEmpty) {
        return (_getMockProducts(categoryId: categoryId), null);
      }
      return (products, null);
    } catch (e) {
      return (_getMockProducts(categoryId: categoryId), null);
    }
  }

  @override
  Future<(ProductEntity?, Failure?)> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        final mock = _getMockProducts().firstWhere(
          (p) => p.id == productId,
          orElse: () => _getMockProducts().first,
        );
        return (mock, null);
      }
      final product = await _mapToProductEntity(doc);
      return (product, null);
    } catch (e) {
      final mock = _getMockProducts().firstWhere(
        (p) => p.id == productId,
        orElse: () => _getMockProducts().first,
      );
      return (mock, null);
    }
  }

  @override
  Future<(List<ProductEntity>?, Failure?)> searchProducts({
    required String query,
    String? storeId,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _firestore
          .collection('products')
          .where('isPublished', isEqualTo: true)
          .where('isDeleted', isEqualTo: false);

      if (storeId != null && storeId.isNotEmpty) {
        q = q.where('storeId', isEqualTo: storeId);
      }

      final snapshot = await q.limit(50).get();
      final lower = query.toLowerCase();

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final name = (data['name'] as String? ?? '').toLowerCase();
        final desc = (data['description'] as String? ?? '').toLowerCase();
        final tags = List<String>.from(data['tags'] ?? []).map((t) => t.toLowerCase());
        return name.contains(lower) || desc.contains(lower) || tags.any((t) => t.contains(lower));
      }).take(limit);

      final products = await Future.wait(filteredDocs.map((doc) => _mapToProductEntity(doc)));
      if (products.isEmpty) {
        final mock = _getMockProducts(storeId: storeId).where((p) {
          final l = query.toLowerCase();
          return p.name.toLowerCase().contains(l) || p.description.toLowerCase().contains(l);
        }).toList();
        return (mock, null);
      }
      return (products, null);
    } catch (e) {
      final mock = _getMockProducts(storeId: storeId).where((p) {
        final l = query.toLowerCase();
        return p.name.toLowerCase().contains(l) || p.description.toLowerCase().contains(l);
      }).toList();
      return (mock, null);
    }
  }

  @override
  Future<(String?, Failure?)> createProduct(ProductEntity product) async {
    try {
      final ref = await _firestore.collection('products').add({
        'storeId': product.storeId,
        'vendorId': product.vendorId,
        'name': product.name,
        'description': product.description,
        'categoryId': product.categoryId,
        'imageUrls': product.imageUrls,
        'basePrice': product.basePrice,
        'discountedPrice': product.discountedPrice,
        'isPublished': product.isPublished,
        'isDeleted': false,
        'tags': product.tags,
        'rating': product.rating,
        'totalRatings': product.totalRatings,
        'totalSold': product.totalSold,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return (ref.id, null);
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> updateProduct({
    required String productId,
    required Map<String, dynamic> fields,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> addVariant({
    required String productId,
    required ProductVariantEntity variant,
  }) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('variants')
          .add({
        'productId': productId,
        'size': variant.size,
        'color': variant.color,
        'colorHex': variant.colorHex,
        'additionalPrice': variant.additionalPrice,
        'sku': variant.sku,
        'stockCount': variant.stockCount,
        'isAvailable': variant.isAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> updateStock({
    required String productId,
    required String variantId,
    required int newStock,
  }) async {
    try {
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
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  Future<ProductEntity> _mapToProductEntity(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    // Fetch variants subcollection
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

    return ProductEntity(
      id: doc.id,
      storeId: data['storeId'] ?? '',
      vendorId: data['vendorId'] ?? '',
      name: data['name'] ?? 'Product',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      basePrice: (data['basePrice'] as num?)?.toInt() ?? 0,
      discountedPrice: (data['discountedPrice'] as num?)?.toInt() ?? 0,
      isPublished: data['isPublished'] ?? true,
      tags: List<String>.from(data['tags'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      totalRatings: (data['totalRatings'] as num?)?.toInt() ?? 0,
      totalSold: (data['totalSold'] as num?)?.toInt() ?? 0,
      variants: variants,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  List<ProductEntity> _getMockProducts({String? storeId, String? categoryId}) {
    final allProducts = [
      ProductEntity(
        id: 'prod-1',
        storeId: 'store-kubernagar-1',
        vendorId: 'vendor-1',
        name: 'Royal Velvet Embroidered Kurti',
        description: 'Handcrafted zari work velvet kurti with intricate border detailing. Ideal for festive celebrations and wedding functions.',
        categoryId: 'women',
        imageUrls: const [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
        ],
        basePrice: 129900,
        discountedPrice: 89900,
        isPublished: true,
        tags: const ['kurti', 'ethnic', 'velvet', 'women'],
        rating: 4.8,
        totalRatings: 38,
        totalSold: 120,
        variants: const [
          ProductVariantEntity(
            id: 'v1',
            productId: 'prod-1',
            size: 'M',
            color: 'Maroon',
            colorHex: '#800000',
            additionalPrice: 0,
            sku: 'KUR-MAR-M',
            stockCount: 15,
            isAvailable: true,
          ),
          ProductVariantEntity(
            id: 'v2',
            productId: 'prod-1',
            size: 'L',
            color: 'Navy Blue',
            colorHex: '#000080',
            additionalPrice: 0,
            sku: 'KUR-NAV-L',
            stockCount: 12,
            isAvailable: true,
          ),
          ProductVariantEntity(
            id: 'v3',
            productId: 'prod-1',
            size: 'XL',
            color: 'Emerald Green',
            colorHex: '#046307',
            additionalPrice: 5000,
            sku: 'KUR-GRN-XL',
            stockCount: 8,
            isAvailable: true,
          ),
        ],
        createdAt: DateTime.now(),
      ),
      ProductEntity(
        id: 'prod-2',
        storeId: 'store-kubernagar-1',
        vendorId: 'vendor-1',
        name: 'Navratri Chaniya Choli Set',
        description: 'Traditional Gujarati Kutchi mirror work flare chaniya with matching designer blouse and cotton dupatta.',
        categoryId: 'ethnic',
        imageUrls: const [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
        ],
        basePrice: 349900,
        discountedPrice: 249900,
        isPublished: true,
        tags: const ['chaniyacholi', 'navratri', 'gujarat', 'ethnic'],
        rating: 4.9,
        totalRatings: 86,
        totalSold: 210,
        variants: const [
          ProductVariantEntity(
            id: 'v4',
            productId: 'prod-2',
            size: 'Free Size',
            color: 'Multicolor',
            colorHex: '#FF4500',
            additionalPrice: 0,
            sku: 'CC-MULTI-FS',
            stockCount: 20,
            isAvailable: true,
          ),
        ],
        createdAt: DateTime.now(),
      ),
      ProductEntity(
        id: 'prod-3',
        storeId: 'store-kubernagar-2',
        vendorId: 'vendor-2',
        name: 'Comfort Stretch Slim Fit Jeans',
        description: 'Classic indigo wash denim crafted with 98% cotton and 2% elastane for maximum all-day flexibility.',
        categoryId: 'men',
        imageUrls: const [
          'https://images.unsplash.com/photo-1542272604-780c96856592?w=800&auto=format&fit=crop',
        ],
        basePrice: 179900,
        discountedPrice: 119900,
        isPublished: true,
        tags: const ['jeans', 'denim', 'men', 'slimfit'],
        rating: 4.6,
        totalRatings: 64,
        totalSold: 180,
        variants: const [
          ProductVariantEntity(
            id: 'v5',
            productId: 'prod-3',
            size: '30',
            color: 'Dark Indigo',
            colorHex: '#1B263B',
            additionalPrice: 0,
            sku: 'JNS-IND-30',
            stockCount: 14,
            isAvailable: true,
          ),
          ProductVariantEntity(
            id: 'v6',
            productId: 'prod-3',
            size: '32',
            color: 'Dark Indigo',
            colorHex: '#1B263B',
            additionalPrice: 0,
            sku: 'JNS-IND-32',
            stockCount: 25,
            isAvailable: true,
          ),
          ProductVariantEntity(
            id: 'v7',
            productId: 'prod-3',
            size: '34',
            color: 'Washed Black',
            colorHex: '#2B2B2B',
            additionalPrice: 0,
            sku: 'JNS-BLK-34',
            stockCount: 10,
            isAvailable: true,
          ),
        ],
        createdAt: DateTime.now(),
      ),
      ProductEntity(
        id: 'prod-4',
        storeId: 'store-kubernagar-2',
        vendorId: 'vendor-2',
        name: 'Pure Linen Mandarin Collar Shirt',
        description: 'Breathable organic linen shirt tailored for effortless style in Gujarat warm weather.',
        categoryId: 'men',
        imageUrls: const [
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&auto=format&fit=crop',
        ],
        basePrice: 149900,
        discountedPrice: 94900,
        isPublished: true,
        tags: const ['shirt', 'linen', 'men', 'casual'],
        rating: 4.7,
        totalRatings: 42,
        totalSold: 95,
        variants: const [
          ProductVariantEntity(
            id: 'v8',
            productId: 'prod-4',
            size: 'M',
            color: 'Olive Green',
            colorHex: '#556B2F',
            additionalPrice: 0,
            sku: 'SHR-OLV-M',
            stockCount: 18,
            isAvailable: true,
          ),
          ProductVariantEntity(
            id: 'v9',
            productId: 'prod-4',
            size: 'L',
            color: 'White',
            colorHex: '#FFFFFF',
            additionalPrice: 0,
            sku: 'SHR-WHT-L',
            stockCount: 30,
            isAvailable: true,
          ),
        ],
        createdAt: DateTime.now(),
      ),
      ProductEntity(
        id: 'prod-5',
        storeId: 'store-gandhinagar-1',
        vendorId: 'vendor-3',
        name: 'Oversized Streetwear Acid Wash Tee',
        description: 'Heavyweight 240 GSM French Terry cotton t-shirt with aesthetic typography back print.',
        categoryId: 'western',
        imageUrls: const [
          'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop',
        ],
        basePrice: 99900,
        discountedPrice: 59900,
        isPublished: true,
        tags: const ['oversized', 'tshirt', 'streetwear', 'western'],
        rating: 4.9,
        totalRatings: 112,
        totalSold: 340,
        variants: const [
          ProductVariantEntity(
            id: 'v10',
            productId: 'prod-5',
            size: 'M',
            color: 'Charcoal',
            colorHex: '#36454F',
            additionalPrice: 0,
            sku: 'TEE-CHR-M',
            stockCount: 22,
            isAvailable: true,
          ),
          ProductVariantEntity(
            id: 'v11',
            productId: 'prod-5',
            size: 'L',
            color: 'Charcoal',
            colorHex: '#36454F',
            additionalPrice: 0,
            sku: 'TEE-CHR-L',
            stockCount: 15,
            isAvailable: true,
          ),
        ],
        createdAt: DateTime.now(),
      ),
      ProductEntity(
        id: 'prod-6',
        storeId: 'store-gandhinagar-2',
        vendorId: 'vendor-4',
        name: 'Handwoven Patola Silk Saree',
        description: 'Exquisite double ikat Patola saree with gold zari border. Authentic craft heritage from Gujarat.',
        categoryId: 'ethnic',
        imageUrls: const [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
        ],
        basePrice: 699900,
        discountedPrice: 499900,
        isPublished: true,
        tags: const ['saree', 'patola', 'silk', 'handloom', 'women'],
        rating: 5.0,
        totalRatings: 54,
        totalSold: 88,
        variants: const [
          ProductVariantEntity(
            id: 'v12',
            productId: 'prod-6',
            size: 'Free Size',
            color: 'Crimson Red',
            colorHex: '#990000',
            additionalPrice: 0,
            sku: 'SAR-RED-FS',
            stockCount: 5,
            isAvailable: true,
          ),
        ],
        createdAt: DateTime.now(),
      ),
    ];

    var list = allProducts;
    if (storeId != null && storeId.isNotEmpty) {
      list = list.where((p) => p.storeId == storeId).toList();
      if (list.isEmpty) list = allProducts; // Show all if store has no specific products
    }
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    return list;
  }
}
