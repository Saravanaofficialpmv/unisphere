import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/firebase_options.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();

  FirebaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  FirebaseAuth? get auth => Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
  FirebaseFirestore? get firestore => Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
  FirebaseStorage? get storage => Firebase.apps.isNotEmpty ? FirebaseStorage.instance : null;

  /// Initialize Firebase app safely across platforms
  Future<bool> initialize() async {
    if (_initialized && Firebase.apps.isNotEmpty) return true;

    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } catch (e) {
          debugPrint('Platform specific options failed, trying default initializeApp: $e');
          await Firebase.initializeApp();
        }
      }
      _initialized = true;
      debugPrint('Firebase initialized successfully.');
      // Asynchronously seed initial data if collections are empty
      FirebaseFirestoreService().seedInitialDataIfEmpty();
      return true;
    } catch (e) {
      debugPrint('Firebase initialization warning: $e');
      _initialized = false;
      return false;
    }
  }

  // Firestore Collection References
  CollectionReference? get usersCollection => firestore?.collection('users');
  CollectionReference? get announcementsCollection => firestore?.collection('announcements');
  CollectionReference? get assignmentsCollection => firestore?.collection('assignments');
  CollectionReference? get submissionsCollection => firestore?.collection('submissions');
  CollectionReference? get marksCollection => firestore?.collection('marks');
  CollectionReference? get attendanceCollection => firestore?.collection('attendance');
  CollectionReference? get hackathonsCollection => firestore?.collection('hackathons');
  CollectionReference? get examsCollection => firestore?.collection('exams');
  CollectionReference? get leavesCollection => firestore?.collection('leaves');
}
