import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/parent_model.dart';

final parentServiceProvider = Provider<ParentService>((ref) {
  return ParentService();
});

class ParentService {
  final FirebaseFirestore? _firestore;

  ParentService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get parent profile by parentId or student UID reference
  Future<ParentModel?> getParentById(String parentId) async {
    final firestore = _firestore;
    if (parentId.isEmpty || firestore == null) return null;
    try {
      final doc = await firestore.collection('parents').doc(parentId).get();
      if (doc.exists && doc.data() != null) {
        return ParentModel.fromMap(doc.data()!, doc.id);
      }

      // Fallback lookup by studentId array
      final snap = await firestore.collection('parents').where('studentIds', arrayContains: parentId).limit(1).get();
      if (snap.docs.isNotEmpty) {
        return ParentModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
      }
    } catch (e) {
      debugPrint('ParentService getParentById error: $e');
    }
    return null;
  }

  /// Save or update parent profile under parents/{parentId}
  Future<void> saveParent(ParentModel parent) async {
    final firestore = _firestore;
    if (firestore == null || parent.parentId.isEmpty) return;
    try {
      final data = parent.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('parents').doc(parent.parentId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ParentService saveParent error: $e');
    }
  }
}
