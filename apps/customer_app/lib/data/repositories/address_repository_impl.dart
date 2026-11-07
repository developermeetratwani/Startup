import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore? _customFirestore;
  FirebaseFirestore? _firestoreInstance;

  AddressRepositoryImpl({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return _firestoreInstance ??= FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _firestore?.collection('addresses');

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
      id: 'addr-sbr-01',
      userId: 'cust-ahmedabad-01',
      label: 'Sindhu Bhavan Road (SBR)',
      line1: '402, Titanium One, Sindhu Bhavan Road, Bodakdev',
      line2: 'Opposite Taj Skyline, SG Highway',
      city: 'Ahmedabad',
      state: 'Gujarat',
      pincode: '380054',
      latitude: 23.0402,
      longitude: 72.5028,
      isDefault: false,
    ),
  ];

  @override
  Future<(List<AddressEntity>?, Failure?)> getAddresses(String userId) async {
    final col = _collection;
    if (col == null) return (_fallbackAddresses, null);
    try {
      final snap = await col.where('userId', isEqualTo: userId).get();
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
      final col = _collection;
      if (col == null) return Stream.value(_fallbackAddresses);
      return col
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
    final col = _collection;
    if (col == null) return ('addr-local-${DateTime.now().millisecondsSinceEpoch}', null);
    try {
      final docRef = await col.add({
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
    final col = _collection;
    if (col == null) return null;
    try {
      await col.doc(address.id).update({
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
    final col = _collection;
    if (col == null) return null;
    try {
      await col.doc(addressId).delete();
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> setDefaultAddress(String userId, String addressId) async {
    final col = _collection;
    final fs = _firestore;
    if (col == null || fs == null) return null;
    try {
      final snap = await col.where('userId', isEqualTo: userId).get();
      final batch = fs.batch();
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
