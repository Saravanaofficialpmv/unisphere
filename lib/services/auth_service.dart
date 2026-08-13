import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/firebase_auth_service.dart';

abstract class AuthService {
  Stream<UserModel?> get authStateChanges;
  Future<void> signInWithEmail(String email, String password);
  Future<void> registerWithEmail(
    String email,
    String password,
    String name,
    UserRole role, {
    String? phoneNumber,
    Map<String, dynamic>? metadata,
  });
  Future<void> updateUserProfile(UserModel updatedUser);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  UserModel? get currentUser;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});

class SupabaseAuthService implements AuthService {
  final SupabaseClient _supabase;
  UserModel? _currentUser;
  final _stateController = StreamController<UserModel?>.broadcast();
  UserModel? _mockUser;

  SupabaseAuthService(this._supabase) {
    _supabase.auth.onAuthStateChange.listen((data) async {
      if (_mockUser != null) return;
      final user = data.session?.user;
      if (user == null) {
        _currentUser = null;
        _stateController.add(null);
      } else {
        final userData = await getUserData(user.id);
        _currentUser = userData;
        _stateController.add(userData);
      }
    });
    _init();
  }

  @override
  Stream<UserModel?> get authStateChanges async* {
    // Immediately emit the current user so the screen doesn't stay blank
    yield _currentUser;
    yield* _stateController.stream;
  }

  Future<void> _init() async {
    _currentUser = await _getCurrentUser();
    _stateController.add(_currentUser);
  }

  Future<UserModel?> _getCurrentUser() async {
    if (_mockUser != null) return _mockUser;
    final suUser = _supabase.auth.currentUser;
    if (suUser == null) return null;
    return await getUserData(suUser.id);
  }

  @override
  UserModel? get currentUser => _mockUser ?? _currentUser; 

  @override
  Future<void> signInWithEmail(String email, String password) async {
    final lowerEmail = email.toLowerCase().trim();

    // DEMO BYPASS
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

    // REAL SIGN IN WITH OFFLINE / DEMO FALLBACK
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      // Catch network exceptions (SocketException / Failed host lookup) or auth errors during demo
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
    _mockUser = UserModel(
      uid: 'DEMO-REG-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      phoneNumber: phoneNumber,
      metadata: metadata,
    );
    _currentUser = _mockUser;
    _stateController.add(_mockUser);
  }

  @override
  Future<void> updateUserProfile(UserModel updatedUser) async {
    _mockUser = updatedUser;
    _currentUser = updatedUser;
    _stateController.add(updatedUser);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      // Ignored for demo
    }
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
    await _supabase.auth.signOut();
    _stateController.add(null);
  }

  Future<UserModel?> getUserData(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await _supabase.from('users').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return UserModel.fromMap(response, id);
    } catch (e) {
      return null;
    }
  }
}
