import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<(String?, Failure?)> uploadFile({
    required String storagePath,
    required File file,
    String? contentType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(storagePath);
      final metadata = contentType != null
          ? SettableMetadata(contentType: contentType)
          : null;
      final task = ref.putFile(file, metadata);

      if (onProgress != null) {
        task.snapshotEvents.listen((snap) {
          final progress = snap.bytesTransferred / snap.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await task;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return (downloadUrl, null);
    } catch (e) {
      AppLogger.error('StorageService.uploadFile', e.toString());
      return (null, ServerFailure('Upload failed. Please try again.'));
    }
  }

  Future<Failure?> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
      return null;
    } catch (e) {
      AppLogger.error('StorageService.deleteFile', e.toString());
      return ServerFailure('Delete failed.');
    }
  }
}
