import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere/main.dart';

void main() {
  testWidgets('UnisphereApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UnisphereApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(UnisphereApp), findsOneWidget);
  });
}

