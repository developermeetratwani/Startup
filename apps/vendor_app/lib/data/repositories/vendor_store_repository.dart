import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class VendorStoreRepository {
  final FirebaseFirestore _firestore;

  VendorStoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<StoreEntity?> watchStoreByVendorId(String vendorId) {
    return _firestore
        .collection('stores')
        .where('vendorId', isEqualTo: vendorId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      final data = doc.data();
      final loc = data['location'] as Map<String, dynamic>? ?? {};

      return StoreEntity(
        id: doc.id,
        vendorId: vendorId,
        name: data['name'] ?? 'My Store',
        description: data['description'] ?? '',
        bannerImageUrl: data['bannerImageUrl'],
        logoImageUrl: data['logoImageUrl'],
        categoryIds: List<String>.from(data['categoryIds'] ?? []),
        location: GeoLocation(
          latitude: (loc['latitude'] as num?)?.toDouble() ?? 23.0768,
          longitude: (loc['longitude'] as num?)?.toDouble() ?? 72.6346,
          geohash: loc['geohash'] ?? '',
          address: loc['address'] ?? 'Main Bazaar, Kubernagar',
          city: loc['city'] ?? 'Ahmedabad',
          pincode: loc['pincode'] ?? '382340',
        ),
        isOpen: data['isOpen'] ?? true,
        isActive: data['isActive'] ?? true,
        rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
        totalRatings: (data['totalRatings'] as num?)?.toInt() ?? 12,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    });
  }

  Future<void> updateStoreStatus({
    required String storeId,
    required bool isOpen,
  }) async {
    try {
      await _firestore.collection('stores').doc(storeId).set({
        'id': storeId,
        'isOpen': isOpen,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('updateStoreStatus', e.toString());
    }
  }

    Future<void> updateStoreProfile({
    required String storeId,
    required String name,
    required String description,
    required String address,
    required String city,
    String? bannerImageUrl,
    String? logoImageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'description': description,
        'location': {
          'address': address,
          'city': city,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (bannerImageUrl != null && bannerImageUrl.isNotEmpty) {
        data['bannerImageUrl'] = bannerImageUrl;
      }
      if (logoImageUrl != null && logoImageUrl.isNotEmpty) {
        data['logoImageUrl'] = logoImageUrl;
      }
      await _firestore.collection('stores').doc(storeId).set(data, SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('updateStoreProfile', e.toString());
    }
  }
}

