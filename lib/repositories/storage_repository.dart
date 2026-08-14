import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

class StorageRepository {
  final FirebaseStorage? _storage;

  StorageRepository({FirebaseStorage? storage})
      : _storage = storage ?? _tryGetStorage();

  static FirebaseStorage? _tryGetStorage() {
    try {
      return FirebaseStorage.instance;
    } catch (_) {
      return null;
    }
  }

  /// Upload file to Firebase Storage (e.g. certificates, profile photos, submissions)
  Future<String?> uploadFile({
    required String path,
    required File file,
  }) async {
    final storage = _storage;
    if (storage == null) return null;
    try {
      final ref = storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage upload error: $e');
      return null;
    }
  }

  /// Upload raw bytes (for Web platform compatibility)
  Future<String?> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? mimeType,
  }) async {
    final storage = _storage;
    if (storage == null) return null;
    try {
      final ref = storage.ref().child(path);
      final metadata = SettableMetadata(contentType: mimeType ?? 'application/octet-stream');
      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage uploadBytes error: $e');
      return null;
    }
  }
}
