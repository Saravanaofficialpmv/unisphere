import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clg_application/services/auth_service.dart';
import 'package:clg_application/models/user_model.dart';
import 'package:clg_application/screens/auth/auth_screen.dart';
import 'package:clg_application/screens/auth/request_submitted_screen.dart';
import 'package:clg_application/screens/student/student_dashboard.dart';
import 'package:clg_application/screens/staff/staff_dashboard.dart';
import 'package:clg_application/screens/parent/parent_dashboard.dart';
import 'package:clg_application/screens/onboarding/onboarding_screen.dart';

import 'package:clg_application/screens/admin/admin_shell.dart';
import 'package:clg_application/screens/hod/hod_shell.dart';
import 'package:clg_application/screens/student/cgpa_details_screen.dart';

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.value;
      final isAuth = user != null;

      debugPrint('Router: isLoading=$isLoading, isAuth=$isAuth, path=${state.matchedLocation}');

      if (isLoading) return null;

      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';
      final isSignup = state.matchedLocation == '/signup';
      final isRequestSubmitted = state.matchedLocation == '/request-submitted';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!isAuth) {
        if (isSplash) return '/onboarding';
        if (isLogin || isOnboarding || isSignup || isRequestSubmitted) return null;
        return '/onboarding';
      }

      if (isAuth && (isLogin || isSplash || isOnboarding)) {
        switch (user.role) {
          case UserRole.admin:
            return '/admin';
          case UserRole.hod:
            return '/hod';
          case UserRole.student:
            return '/student';
          case UserRole.staff:
            return '/staff';
          case UserRole.parent:
            return '/parent';
          default:
            return '/login';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return AuthScreen(
            isInitialSignUp: true,
            initialFirstName: queryParams['firstName'],
            initialLastName: queryParams['lastName'],
            initialRole: queryParams['role'],
          );
        },
      ),
      GoRoute(
        path: '/request-submitted',
        builder: (context, state) => const RequestSubmittedScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminShell(),
      ),
      GoRoute(
        path: '/hod',
        builder: (context, state) => const HodShell(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffDashboard(),
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: '/cgpa-details',
        builder: (context, state) => const CgpaDetailsScreen(),
      ),
    ],
  );
});
