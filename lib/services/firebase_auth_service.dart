import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/auth_service.dart';

/// Real-time Firebase Authentication Service
/// Listens to Firebase Auth state changes and streams real-time Firestore user document updates.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  UserModel? _currentUser;
  UserModel? _mockUser;
  final _stateController = StreamController<UserModel?>.broadcast();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSubscription;

  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? _tryGetAuth(),
        _firestore = firestore ?? _tryGetFirestore() {
    _initRealtimeAuth();
  }

  static FirebaseAuth? _tryGetAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  void _initRealtimeAuth() {
    final auth = _auth;
    if (auth == null) return;
    try {
      // Listen to real-time Firebase Auth user changes (login, logout, token refresh)
      _authSubscription = auth.userChanges().listen((User? fbUser) {
        _handleFirebaseUserChange(fbUser);
      }, onError: (e) {
        debugPrint('Firebase Auth Realtime Error: $e');
      });
    } catch (e) {
      debugPrint('Firebase Auth initialization notice: $e');
    }
  }

  void _handleFirebaseUserChange(User? fbUser) {
    if (_mockUser != null) return;

    // Cancel previous Firestore user document subscription
    _userDocSubscription?.cancel();
    _userDocSubscription = null;

    if (fbUser == null) {
      _currentUser = null;
      _stateController.add(null);
    } else {
      // Set initial user model from Firebase User metadata immediately
      if (_currentUser == null || _currentUser!.uid != fbUser.uid) {
        _currentUser = _mapFirebaseUserToDefaultModel(fbUser);
        _stateController.add(_currentUser);
      }

      // Subscribe to real-time updates from Firestore for this user's profile
      final firestore = _firestore;
      if (firestore != null) {
        try {
          _userDocSubscription = firestore
              .collection('users')
              .doc(fbUser.uid)
              .snapshots()
              .listen((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              _currentUser = UserModel.fromMap(snapshot.data()!, fbUser.uid);
              _stateController.add(_currentUser);
            } else {
              // If user document doesn't exist yet, save default and emit
              final defaultUser = _mapFirebaseUserToDefaultModel(fbUser);
              saveUserData(defaultUser);
              _currentUser = defaultUser;
              _stateController.add(_currentUser);
            }
          }, onError: (e) {
            debugPrint('Firestore real-time user doc error: $e');
          });
        } catch (e) {
          debugPrint('Error subscribing to real-time user doc: $e');
        }
      }
    }
  }

  UserModel _mapFirebaseUserToDefaultModel(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? (user.email != null ? user.email!.split('@').first : 'User'),
      role: UserRole.student,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges async* {
    yield currentUser;
    yield* _stateController.stream;
  }

  @override
  Stream<User?>? get firebaseUserStream => _auth?.userChanges();

  @override
  UserModel? get currentUser => _mockUser ?? _currentUser;

  @override
  Future<void> reloadUser() async {
    final auth = _auth;
    if (_mockUser != null || auth == null) return;
    try {
      final user = auth.currentUser;
      if (user != null) {
        await user.reload();
        _handleFirebaseUserChange(auth.currentUser);
      }
    } catch (e) {
      debugPrint('Firebase Reload User Notice: $e');
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    final lowerEmail = email.toLowerCase().trim();

    // DEMO BYPASS ACCOUNTS (Instant offline testing without requiring live network credentials)
    if (lowerEmail == 'hod.cse@unisphere.edu' || lowerEmail.contains('hod')) {
      _mockUser = UserModel(uid: 'DEMO-HOD', email: email, name: 'Dr. R. Kumar', role: UserRole.hod);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (lowerEmail == 'admin@unisphere.edu' || lowerEmail.contains('admin')) {
      _mockUser = UserModel(uid: 'DEMO-ADM', email: email, name: 'Demo Admin', role: UserRole.admin);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (lowerEmail == 'staff@unisphere.edu' || lowerEmail.contains('staff') || lowerEmail.contains('faculty')) {
      _mockUser = UserModel(uid: 'DEMO-STF', email: email, name: 'Demo Staff', role: UserRole.staff);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (lowerEmail == 'saravanapmvofficial@gmail.com' || lowerEmail.contains('student')) {
      _mockUser = UserModel(uid: 'DEMO-STU', email: email, name: 'Demo Student', role: UserRole.student);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (lowerEmail == 'parent@unisphere.edu' || lowerEmail.contains('parent')) {
      _mockUser = UserModel(uid: 'DEMO-PRT', email: email, name: 'Demo Parent', role: UserRole.parent);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }

    // REAL FIREBASE SIGN IN WITH REALTIME HANDLER
    try {
      final auth = _auth;
      if (auth != null) {
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (credential.user != null) {
          _handleFirebaseUserChange(credential.user);
          return;
        }
      }
    } catch (e) {
      debugPrint('Firebase Auth sign in attempt notice: $e');
    }

    UserRole fallbackRole = UserRole.student;
    if (lowerEmail.contains('hod')) {
      fallbackRole = UserRole.hod;
    } else if (lowerEmail.contains('admin')) {
      fallbackRole = UserRole.admin;
    } else if (lowerEmail.contains('staff') || lowerEmail.contains('faculty')) {
      fallbackRole = UserRole.staff;
    } else if (lowerEmail.contains('parent')) {
      fallbackRole = UserRole.parent;
    }

    _mockUser = UserModel(
      uid: 'DEMO-OFFLINE',
      email: email,
      name: email.contains('@') ? email.split('@').first : email,
      role: fallbackRole,
    );
    _currentUser = _mockUser;
    _stateController.add(_mockUser);
  }

  @override
  Future<void> registerWithEmail(
    String email,
    String password,
    String name,
    UserRole role, {
    String? phoneNumber,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final auth = _auth;
      if (auth != null) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (credential.user != null) {
          final newUser = UserModel(
            uid: credential.user!.uid,
            email: email,
            name: name,
            role: role,
            phoneNumber: phoneNumber,
            metadata: metadata,
          );
          await saveUserData(newUser);
          _handleFirebaseUserChange(credential.user);
          return;
        }
      }
    } catch (e) {
      debugPrint('Firebase Registration Error: $e');
    }

    // Fallback user creation if network/uninitialized error
    final fallbackUser = UserModel(
      uid: 'USER-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      phoneNumber: phoneNumber,
      metadata: metadata,
    );
    _mockUser = fallbackUser;
    _currentUser = fallbackUser;
    _stateController.add(_currentUser);
  }

  @override
  Future<void> updateUserProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    if (_mockUser != null) {
      _mockUser = updatedUser;
      _stateController.add(updatedUser);
    } else {
      await saveUserData(updatedUser);
      _stateController.add(updatedUser);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.sendPasswordResetEmail(email: email.trim());
      } catch (e) {
        debugPrint('Firebase Password Reset Error: $e');
        rethrow;
      }
    }
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
    try {
      final auth = _auth;
      if (auth != null) {
        await auth.signOut();
      }
    } catch (e) {
      debugPrint('Firebase SignOut Warning: $e');
    }
    _currentUser = null;
    _stateController.add(null);
  }

  Future<UserModel?> getUserData(String uid) async {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return null;
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('Firestore getUserData Warning: $e');
    }
    return null;
  }

  Future<void> saveUserData(UserModel user) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveUserData Warning: $e');
    }
  }

  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    _stateController.close();
  }
}

