import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/screens/auth/auth_screen.dart';
import 'package:unisphere/screens/auth/request_submitted_screen.dart';
import 'package:unisphere/screens/student/student_dashboard.dart';
import 'package:unisphere/screens/staff/staff_dashboard.dart';
import 'package:unisphere/screens/parent/parent_dashboard.dart';
import 'package:unisphere/screens/onboarding/onboarding_screen.dart';

import 'package:unisphere/screens/admin/admin_shell.dart';
import 'package:unisphere/screens/hod/hod_shell.dart';
import 'package:unisphere/screens/student/cgpa_details_screen.dart';
import 'package:unisphere/screens/features/leetcode_detail_screen.dart';
import 'package:unisphere/screens/features/github_detail_screen.dart';
import 'package:unisphere/screens/student/modules/student_resume_screen.dart';

import 'package:unisphere/widgets/common/custom_loader.dart';

import 'dart:async';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final routerNotifierProvider = Provider<GoRouterRefreshStream>((ref) {
  return GoRouterRefreshStream(ref.watch(authServiceProvider).authStateChanges);
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerNotifierProvider);
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final user = authService.currentUser;
      final isAuth = user != null;

      debugPrint('Router: isAuth=$isAuth, path=${state.matchedLocation}');

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

      if (isAuth && (isLogin || isSignup || isSplash || isOnboarding)) {
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
        builder: (context, state) => const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Loader(
              label: 'Loading UNISPHERE...',
            ),
          ),
        ),
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
            initialId: queryParams['id'],
            initialDepartment: queryParams['department'],
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
      GoRoute(
        path: '/leetcode-details',
        builder: (context, state) => const LeetCodeDetailScreen(),
      ),
      GoRoute(
        path: '/github-details',
        builder: (context, state) => const GitHubDetailScreen(),
      ),
      GoRoute(
        path: '/resume',
        builder: (context, state) => const StudentResumeScreen(),
      ),
    ],
  );
});
