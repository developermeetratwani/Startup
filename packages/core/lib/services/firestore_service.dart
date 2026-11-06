import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _db;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  DocumentReference<Map<String, dynamic>> doc(String path) =>
      _db.doc(path);

  /// Get a single document
  Future<(Map<String, dynamic>?, Failure?)> getDoc(String path) async {
    try {
      final snap = await _db.doc(path).get();
      if (!snap.exists) return (null, NotFoundFailure());
      return (snap.data(), null);
    } catch (e) {
      AppLogger.error('getDoc[$path]', e.toString());
      return (null, ServerFailure());
    }
  }

  /// Set a document (merge = true by default)
  Future<Failure?> setDoc(
    String path,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await _db.doc(path).set(data, SetOptions(merge: merge));
      return null;
    } catch (e) {
      AppLogger.error('setDoc[$path]', e.toString());
      return ServerFailure();
    }
  }

  /// Update specific fields
  Future<Failure?> updateDoc(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      AppLogger.error('updateDoc[$path]', e.toString());
      return ServerFailure();
    }
  }

  /// Add a document to a collection
  Future<(String?, Failure?)> addDoc(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      final ref = await _db.collection(collectionPath).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return (ref.id, null);
    } catch (e) {
      AppLogger.error('addDoc[$collectionPath]', e.toString());
      return (null, ServerFailure());
    }
  }

  /// Watch a document for realtime updates
  Stream<Map<String, dynamic>?> watchDoc(String path) {
    return _db.doc(path).snapshots().map((snap) {
      if (!snap.exists) return null;
      return {'id': snap.id, ...?snap.data()};
    });
  }

  /// Watch a query
  Stream<List<Map<String, dynamic>>> watchCollection(
    Query<Map<String, dynamic>> query,
  ) {
    return query.snapshots().map((snap) {
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    });
  }

  /// Run a Firestore transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) updateFunction,
  ) {
    return _db.runTransaction(updateFunction);
  }

  Timestamp get serverTimestamp => Timestamp.now();
  FieldValue get serverTimestampValue => FieldValue.serverTimestamp();
}
