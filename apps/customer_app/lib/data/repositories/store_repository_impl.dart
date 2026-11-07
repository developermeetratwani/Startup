import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';
import 'dart:math' as math;

class StoreRepositoryImpl implements StoreRepository {
  final FirebaseFirestore? _customFirestore;
  FirebaseFirestore? _firestoreInstance;

  StoreRepositoryImpl({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return _firestoreInstance ??= FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<(List<StoreEntity>?, Failure?)> getNearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 15.0,
    String? categoryId,
    int limit = 20,
  }) async {
    final fs = _firestore;
    if (fs == null) {
      return (_getMockStores(latitude, longitude, categoryId, radiusKm), null);
    }
    try {
      Query<Map<String, dynamic>> query = fs
          .collection('stores')
          .where('isActive', isEqualTo: true)
          .where('isDeleted', isEqualTo: false);

      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        query = query.where('categoryIds', arrayContains: categoryId);
      }

      final snapshot = await query.limit(limit * 2).get();
      final stores = <StoreEntity>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final loc = data['location'] as Map<String, dynamic>?;
        if (loc == null) continue;

        final storeLat = (loc['latitude'] as num?)?.toDouble() ?? 0.0;
        final storeLng = (loc['longitude'] as num?)?.toDouble() ?? 0.0;

        final dist = _calculateDistanceKm(latitude, longitude, storeLat, storeLng);
        if (dist <= radiusKm || radiusKm <= 0) {
          stores.add(_mapToStoreEntity(doc.id, data, storeLat, storeLng, loc));
        }
      }

      // Return mock stores if database has no stores yet
      if (stores.isEmpty) {
        return (_getMockStores(latitude, longitude, categoryId, radiusKm), null);
      }
      return (stores, null);
    } catch (e) {
      AppLogger.error('StoreRepositoryImpl.getNearbyStores', e.toString());
      return (_getMockStores(latitude, longitude, categoryId, radiusKm), null);
    }
  }

  @override
  Future<(StoreEntity?, Failure?)> getStoreById(String storeId) async {
    final fs = _firestore;
    if (fs == null) {
      final mock = _getMockStores(0, 0, null, 0).firstWhere(
        (s) => s.id == storeId,
        orElse: () => _getMockStores(0, 0, null, 0).first,
      );
      return (mock, null);
    }
    try {
      final doc = await fs.collection('stores').doc(storeId).get();
      if (!doc.exists) {
        final mock = _getMockStores(0, 0, null, 0).firstWhere(
          (s) => s.id == storeId,
          orElse: () => _getMockStores(0, 0, null, 0).first,
        );
        return (mock, null);
      }
      final data = doc.data()!;
      final loc = data['location'] as Map<String, dynamic>? ?? {};
      return (_mapToStoreEntity(
        doc.id,
        data,
        (loc['latitude'] as num?)?.toDouble() ?? 0.0,
        (loc['longitude'] as num?)?.toDouble() ?? 0.0,
        loc,
      ), null);
    } catch (e) {
      final mock = _getMockStores(0, 0, null, 0).firstWhere(
        (s) => s.id == storeId,
        orElse: () => _getMockStores(0, 0, null, 0).first,
      );
      return (mock, null);
    }
  }

  @override
  Future<(StoreEntity?, Failure?)> getStoreByVendorId(String vendorId) async {
    final fs = _firestore;
    if (fs == null) {
      final mock = _getMockStores(0, 0, null, 0).firstWhere(
        (s) => s.vendorId == vendorId,
        orElse: () => _getMockStores(0, 0, null, 0).first,
      );
      return (mock, null);
    }
    try {
      final snap = await fs
          .collection('stores')
          .where('vendorId', isEqualTo: vendorId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        final mock = _getMockStores(0, 0, null, 0).firstWhere(
          (s) => s.vendorId == vendorId,
          orElse: () => _getMockStores(0, 0, null, 0).first,
        );
        return (mock, null);
      }
      final doc = snap.docs.first;
      final data = doc.data();
      final loc = data['location'] as Map<String, dynamic>? ?? {};
      return (_mapToStoreEntity(
        doc.id,
        data,
        (loc['latitude'] as num?)?.toDouble() ?? 0.0,
        (loc['longitude'] as num?)?.toDouble() ?? 0.0,
        loc,
      ), null);
    } catch (e) {
      final mock = _getMockStores(0, 0, null, 0).firstWhere(
        (s) => s.vendorId == vendorId,
        orElse: () => _getMockStores(0, 0, null, 0).first,
      );
      return (mock, null);
    }
  }

  @override
  Stream<StoreEntity?> watchStore(String storeId) {
    final fs = _firestore;
    if (fs == null) {
      final allMocks = _getMockStores(0, 0, null, 0);
      return Stream.value(allMocks.firstWhere(
        (s) => s.id == storeId,
        orElse: () => allMocks.first,
      ));
    }
    return fs.collection('stores').doc(storeId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final loc = data['location'] as Map<String, dynamic>? ?? {};
        return _mapToStoreEntity(
          doc.id,
          data,
          (loc['latitude'] as num?)?.toDouble() ?? 0.0,
          (loc['longitude'] as num?)?.toDouble() ?? 0.0,
          loc,
        );
      }
      final allMocks = _getMockStores(0, 0, null, 0);
      return allMocks.firstWhere(
        (s) => s.id == storeId,
        orElse: () => allMocks.first,
      );
    }).handleError((_) {
      final allMocks = _getMockStores(0, 0, null, 0);
      return allMocks.firstWhere(
        (s) => s.id == storeId,
        orElse: () => allMocks.first,
      );
    });
  }

  @override
  Future<Failure?> updateStore({
    required String storeId,
    required Map<String, dynamic> fields,
  }) async {
    final fs = _firestore;
    if (fs == null) return null;
    try {
      await fs.collection('stores').doc(storeId).set({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> setStoreOpenStatus({
    required String storeId,
    required bool isOpen,
  }) async {
    return updateStore(storeId: storeId, fields: {'isOpen': isOpen});
  }

  StoreEntity _mapToStoreEntity(
    String id,
    Map<String, dynamic> data,
    double lat,
    double lng,
    Map<String, dynamic> loc,
  ) {
    return StoreEntity(
      id: id,
      vendorId: data['vendorId'] ?? '',
      name: data['name'] ?? 'Store',
      description: data['description'] ?? '',
      bannerImageUrl: data['bannerImageUrl'],
      logoImageUrl: data['logoImageUrl'],
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      location: GeoLocation(
        latitude: lat,
        longitude: lng,
        geohash: loc['geohash'] ?? '',
        address: loc['address'] ?? '',
        city: loc['city'] ?? 'Ahmedabad',
        pincode: loc['pincode'] ?? '380001',
      ),
      isOpen: data['isOpen'] ?? true,
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
      totalRatings: (data['totalRatings'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  List<StoreEntity> _getMockStores(double lat, double lng, String? categoryId, double radiusKm) {
    final list = [
      StoreEntity(
        id: 'store-kubernagar-1',
        vendorId: 'vendor-1',
        name: 'Shreeji Ethnic & Bridal Studio',
        description: 'Authentic Chaniya Choli, Kurtis & Designer Bridal Wear in Kubernagar Market',
        bannerImageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
        logoImageUrl: null,
        categoryIds: const ['women', 'ethnic'],
        location: const GeoLocation(
          latitude: 23.0768,
          longitude: 72.6346,
          geohash: 'ts5g',
          address: 'Shop 12-14, Main Market, Kubernagar',
          city: 'Ahmedabad',
          pincode: '382340',
        ),
        isOpen: true,
        isActive: true,
        rating: 4.8,
        totalRatings: 142,
        createdAt: DateTime.now(),
      ),
      StoreEntity(
        id: 'store-kubernagar-2',
        vendorId: 'vendor-2',
        name: 'Vogue Mens Club & Denim',
        description: 'Premium casual shirts, branded jeans and formal wear for men',
        bannerImageUrl: 'https://images.unsplash.com/photo-1490114538077-0a7f8cb49891?w=800&auto=format&fit=crop',
        logoImageUrl: null,
        categoryIds: const ['men', 'western'],
        location: const GeoLocation(
          latitude: 23.0780,
          longitude: 72.6360,
          geohash: 'ts5g',
          address: 'Near Sindhi Colony, Kubernagar',
          city: 'Ahmedabad',
          pincode: '382340',
        ),
        isOpen: true,
        isActive: true,
        rating: 4.6,
        totalRatings: 98,
        createdAt: DateTime.now(),
      ),
      StoreEntity(
        id: 'store-gandhinagar-1',
        vendorId: 'vendor-3',
        name: 'Infocity Fashion Hub',
        description: 'Trendy western wear, oversized tees, hoodies and chic dresses',
        bannerImageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop',
        logoImageUrl: null,
        categoryIds: const ['women', 'western', 'men'],
        location: const GeoLocation(
          latitude: 23.2156,
          longitude: 72.6369,
          geohash: 'ts5s',
          address: 'Supermall 1, Infocity, Sector 21',
          city: 'Gandhinagar',
          pincode: '382007',
        ),
        isOpen: true,
        isActive: true,
        rating: 4.9,
        totalRatings: 215,
        createdAt: DateTime.now(),
      ),
      StoreEntity(
        id: 'store-gandhinagar-2',
        vendorId: 'vendor-4',
        name: 'Kalamandir Handlooms & Sarees',
        description: 'Pure Silk, Patola and Bandhani Sarees curated from master weavers',
        bannerImageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&auto=format&fit=crop',
        logoImageUrl: null,
        categoryIds: const ['women', 'ethnic'],
        location: const GeoLocation(
          latitude: 23.2200,
          longitude: 72.6450,
          geohash: 'ts5s',
          address: 'Shop 5, Sector 16 Market',
          city: 'Gandhinagar',
          pincode: '382016',
        ),
        isOpen: true,
        isActive: true,
        rating: 4.7,
        totalRatings: 73,
        createdAt: DateTime.now(),
      ),
      StoreEntity(
        id: 'store-sbr-1',
        vendorId: 'vendor-5',
        name: 'Sindhu Bhavan Couture & Ethnic Lounge',
        description: 'High-street Indo-western lehengas, bespoke designer suits & couture wear on SBR',
        bannerImageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800&auto=format&fit=crop',
        logoImageUrl: null,
        categoryIds: const ['men', 'western', 'ethnic'],
        location: const GeoLocation(
          latitude: 23.0402,
          longitude: 72.5028,
          geohash: 'ts5e',
          address: 'Shivalik Shilp, Sindhu Bhavan Road, Bodakdev',
          city: 'Ahmedabad',
          pincode: '380054',
        ),
        isOpen: true,
        isActive: true,
        rating: 4.8,
        totalRatings: 112,
        createdAt: DateTime.now(),
      ),
      StoreEntity(
        id: 'store-sbr-2',
        vendorId: 'vendor-6',
        name: 'SBR Mens Luxury Atelier',
        description: 'Luxury sherwanis, tuxedos, and customized linen blazers on Sindhu Bhavan Road',
        bannerImageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
        logoImageUrl: null,
        categoryIds: const ['men', 'ethnic'],
        location: const GeoLocation(
          latitude: 23.0418,
          longitude: 72.5050,
          geohash: 'ts5e',
          address: 'Opposite Taj Skyline, Sindhu Bhavan Road, Bodakdev',
          city: 'Ahmedabad',
          pincode: '380054',
        ),
        isOpen: true,
        isActive: true,
        rating: 4.9,
        totalRatings: 156,
        createdAt: DateTime.now(),
      ),
    ];

    var filtered = list;

    // Filter by radius if location is provided
    if (lat != 0 && lng != 0 && radiusKm > 0) {
      final nearby = list.where((s) {
        final d = _calculateDistanceKm(lat, lng, s.location.latitude, s.location.longitude);
        return d <= radiusKm;
      }).toList();
      if (nearby.isNotEmpty) {
        filtered = nearby;
      }
    }

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      filtered = filtered.where((s) => s.categoryIds.contains(categoryId)).toList();
    }
    return filtered;
  }
}
