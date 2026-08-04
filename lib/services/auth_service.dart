import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/models/user_model.dart';

abstract class AuthService {
  Stream<UserModel?> get authStateChanges;
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
  UserModel? get currentUser;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return SupabaseAuthService(Supabase.instance.client);
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
  UserModel? get currentUser => _mockUser; 

  @override
  Future<void> signInWithEmail(String email, String password) async {
    // DEMO BYPASS
    if (email == 'admin@unisphere.edu' && password == 'AdminPass123!') {
      _mockUser = UserModel(uid: 'DEMO-ADM', email: email, name: 'Demo Admin', role: UserRole.admin);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (email == 'hod@unisphere.edu' && password == 'HodPass123!') {
      _mockUser = UserModel(uid: 'DEMO-HOD', email: email, name: 'Dr. R. Kumar', role: UserRole.hod);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (email == 'staff@unisphere.edu' && password == 'StaffPass123!') {
      _mockUser = UserModel(uid: 'DEMO-STF', email: email, name: 'Demo Staff', role: UserRole.staff);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (email == 'saravanapmvofficial@gmail.com' && password == 'Sivamani9698pmv\$') {
      _mockUser = UserModel(uid: 'DEMO-STU', email: email, name: 'Demo Student', role: UserRole.student);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }
    if (email == 'parent@unisphere.edu' && password == 'ParentPass123!') {
      _mockUser = UserModel(uid: 'DEMO-PRT', email: email, name: 'Demo Parent', role: UserRole.parent);
      _currentUser = _mockUser;
      _stateController.add(_mockUser);
      return;
    }

    // REAL SIGN IN
    await _supabase.auth.signInWithPassword(email: email, password: password);
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
