import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/models/hackathon_registration_model.dart';

final hackathonRepositoryProvider = Provider<HackathonRepository>((ref) {
  return HackathonRepository();
});

class HackathonRepository {
  final FirebaseFirestore? _firestore;

  HackathonRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Watch real-time active hackathons
  Stream<List<HackathonModel>> watchHackathons() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    return firestore
        .collection('hackathons')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return HackathonModel.fromMap(data);
            }).toList())
        .handleError((e) {
      debugPrint('Firestore hackathons stream error: $e');
      return <HackathonModel>[];
    });
  }

  /// Watch student's hackathon registrations
  Stream<List<HackathonRegistrationModel>> watchStudentRegistrations(String studentUid) {
    final firestore = _firestore;
    if (studentUid.isEmpty || firestore == null) return Stream.value([]);

    return firestore
        .collection('hackathonRegistrations')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs
                .map((doc) => HackathonRegistrationModel.fromMap(doc.data(), doc.id))
                .where((reg) => reg.studentId == studentUid || reg.leaderId == studentUid || reg.teamMembers.contains(studentUid))
                .toList();
          }
          return <HackathonRegistrationModel>[];
        })
        .handleError((e) {
      debugPrint('Firestore hackathonRegistrations stream error: $e');
      return <HackathonRegistrationModel>[];
    });
  }


  /// Fetch featured hackathon from Firestore
  Future<HackathonModel?> fetchFeaturedHackathon() async {
    final firestore = _firestore;
    if (firestore == null) return null;
    try {
      final snapshot = await firestore
          .collection('hackathons')
          .where('status', isEqualTo: 'upcoming')
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return HackathonModel.fromMap(data);
      }
    } catch (e) {
      debugPrint('Firestore fetchFeaturedHackathon error: $e');
    }
    return null;
  }

  /// Fetch hackathons paginated/filtered
  Future<List<HackathonModel>> fetchHackathons({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      Query query = firestore.collection('hackathons');
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      final snapshot = await query.limit(limit * page).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HackathonModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchHackathons error: $e');
      return [];
    }
  }

  /// Register team for hackathon
  Future<Map<String, dynamic>> registerTeam(String hackathonId, Map<String, dynamic> data) async {
    final firestore = _firestore;
    if (firestore == null) return {'success': false};
    try {
      final id = 'REG-${DateTime.now().millisecondsSinceEpoch}';
      await firestore.collection('hackathon_registrations').doc(id).set({
        'hackathon_id': hackathonId,
        'registered_at': DateTime.now().toIso8601String(),
        ...data,
      });
      return {'success': true, 'id': id};
    } catch (e) {
      debugPrint('Firestore registerTeam error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Register student team for a hackathon
  Future<void> registerForHackathon(HackathonRegistrationModel registration) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore
          .collection('hackathon_registrations')
          .doc(registration.id)
          .set(registration.toMap());
    } catch (e) {
      debugPrint('Firestore registerForHackathon error: $e');
    }
  }
}
