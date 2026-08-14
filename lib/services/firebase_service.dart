import 'dart:async';
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

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  /// Initialize Firebase app safely across platforms
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
      debugPrint('Firebase initialized successfully.');
      // Asynchronously seed initial data in microtask without blocking initialization flow
      unawaited(FirebaseFirestoreService().seedInitialDataIfEmpty());
      return true;
    } catch (e) {
      debugPrint('Firebase initialization warning: $e');
      // Set to true so app continues cleanly with fallback/demo modes if needed
      _initialized = false;
      return false;
    }
  }

  // Firestore Collection References
  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get announcementsCollection => firestore.collection('announcements');
  CollectionReference get assignmentsCollection => firestore.collection('assignments');
  CollectionReference get submissionsCollection => firestore.collection('submissions');
  CollectionReference get marksCollection => firestore.collection('marks');
  CollectionReference get attendanceCollection => firestore.collection('attendance');
  CollectionReference get hackathonsCollection => firestore.collection('hackathons');
  CollectionReference get examsCollection => firestore.collection('exams');
  CollectionReference get leavesCollection => firestore.collection('leaves');
}
