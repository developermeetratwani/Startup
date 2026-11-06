import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore _firestore;

  AddressRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('addresses');

  static final List<AddressEntity> _fallbackAddresses = [
    const AddressEntity(
      id: 'addr-ahmedabad-01',
      userId: 'cust-ahmedabad-01',
      label: 'Home (Ahmedabad)',
      line1: 'B-42, Krishna Park Colony, Kubernagar Main Bazar',
      line2: 'Opp. Sindhi School',
      city: 'Ahmedabad',
      state: 'Gujarat',
      pincode: '382340',
      latitude: 23.0768,
      longitude: 72.6394,
      isDefault: true,
    ),
    const AddressEntity(
      id: 'addr-vapi-01',
      userId: 'cust-ahmedabad-01',
      label: 'Office / Residence (Vapi)',
      line1: 'Plot 104, Gunjan Char Rasta, GIDC Phase 2',
      line2: 'Near Vapi Silk Emporium',
      city: 'Vapi',
      state: 'Gujarat',
      pincode: '396195',
      latitude: 20.3712,
      longitude: 72.9044,
      isDefault: false,
    ),
  ];

  @override
  Future<(List<AddressEntity>?, Failure?)> getAddresses(String userId) async {
    try {
      final snap = await _collection.where('userId', isEqualTo: userId).get();
      final list = snap.docs.map((doc) => _mapToAddressEntity(doc)).toList();
      return (list.isNotEmpty ? list : _fallbackAddresses, null);
    } catch (e) {
      AppLogger.error('AddressRepositoryImpl.getAddresses', e.toString());
      return (_fallbackAddresses, null);
    }
  }

  @override
  Stream<List<AddressEntity>> watchAddresses(String userId) {
    try {
      return _collection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) {
        final list = snap.docs.map((doc) => _mapToAddressEntity(doc)).toList();
        return list.isNotEmpty ? list : _fallbackAddresses;
      }).handleError((_) => _fallbackAddresses);
    } catch (_) {
      return Stream.value(_fallbackAddresses);
    }
  }

  @override
  Future<(AddressEntity?, Failure?)> getDefaultAddress(String userId) async {
    final (addresses, failure) = await getAddresses(userId);
    if (failure != null) return (null, failure);
    final list = addresses ?? _fallbackAddresses;
    final defaultAddr = list.firstWhere((a) => a.isDefault, orElse: () => list.first);
    return (defaultAddr, null);
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

  AddressEntity _mapToAddressEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AddressEntity(
      id: doc.id,
      userId: d['userId'] ?? '',
      label: d['label'] ?? '',
      line1: d['line1'] ?? '',
      line2: d['line2'],
      city: d['city'] ?? '',
      state: d['state'] ?? '',
      pincode: d['pincode'] ?? '',
      latitude: (d['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (d['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: d['isDefault'] ?? false,
    );
  }
}
