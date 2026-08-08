import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:clg_application/main.dart';

void main() {
  testWidgets('UnisphereApp smoke test', (WidgetTester tester) async {
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy',
      );
    } catch (_) {}

    await tester.pumpWidget(
      const ProviderScope(
        child: UnisphereApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(UnisphereApp), findsOneWidget);
  });
}
