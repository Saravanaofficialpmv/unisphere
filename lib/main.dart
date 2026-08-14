import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/theme/app_theme.dart';
import 'package:unisphere/navigation/app_router.dart';
import 'package:unisphere/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: UnisphereApp(),
    ),
  );

  // Initialize Firebase & seed mock data in the background without blocking UI startup
  try {
    await FirebaseService.instance.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
}

class UnisphereApp extends ConsumerWidget {
  const UnisphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'UNISPHERE SRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

class SupabaseErrorScreen extends StatelessWidget {
  const SupabaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'Supabase Configuration Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please update main.dart with your project URL and Anon Key from the Supabase dashboard.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => main(),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                  child: const Text('Retry Connection'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    // Force the app to launch with Mock services
                    // Note: We need to ensure providers support this
                    runApp(const ProviderScope(child: UnisphereApp()));
                  },
                  style: OutlinedButton.styleFrom(minimumSize: const Size(200, 50)),
                  child: const Text('Launch Demo Mode'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
