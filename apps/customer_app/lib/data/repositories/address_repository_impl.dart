import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore _firestore;

  AddressRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('addresses');

  @override
  Future<(List<AddressEntity>?, Failure?)> getAddresses(String userId) async {
    try {
      final snap = await _collection.where('userId', isEqualTo: userId).get();
      final list = snap.docs.map((doc) => _mapToAddressEntity(doc)).toList();
      return (list, null);
    } catch (e) {
      AppLogger.error('AddressRepositoryImpl.getAddresses', e.toString());
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<AddressEntity>> watchAddresses(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _mapToAddressEntity(doc)).toList());
  }

  @override
  Future<(String?, Failure?)> addAddress(AddressEntity address) async {
    try {
      final docRef = await _collection.add({
        'userId': address.userId,
        'label': address.label,
        'line1': address.line1,
        'line2': address.line2,
        'city': address.city,
        'state': address.state,
        'pincode': address.pincode,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'isDefault': address.isDefault,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (address.isDefault) {
        await setDefaultAddress(address.userId, docRef.id);
      }
      return (docRef.id, null);
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> updateAddress(AddressEntity address) async {
    try {
      await _collection.doc(address.id).update({
        'label': address.label,
        'line1': address.line1,
        'line2': address.line2,
        'city': address.city,
        'state': address.state,
        'pincode': address.pincode,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'isDefault': address.isDefault,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> deleteAddress(String addressId) async {
    try {
      await _collection.doc(addressId).delete();
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> setDefaultAddress(String userId, String addressId) async {
    try {
      final snap = await _collection.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (var doc in snap.docs) {
        batch.update(doc.reference, {'isDefault': doc.id == addressId});
      }
      await batch.commit();
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<(AddressEntity?, Failure?)> getDefaultAddress(String userId) async {
    try {
      final snap = await _collection
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return (null, null);
      return (_mapToAddressEntity(snap.docs.first), null);
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  AddressEntity _mapToAddressEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AddressEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      label: data['label'] ?? 'Home',
      line1: data['line1'] ?? '',
      line2: data['line2'],
      city: data['city'] ?? '',
      state: data['state'] ?? 'Gujarat',
      pincode: data['pincode'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: data['isDefault'] ?? false,
    );
  }
}
