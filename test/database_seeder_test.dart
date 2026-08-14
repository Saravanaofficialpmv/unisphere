import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere/services/database_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseSeeder Configuration & Structure Tests', () {
    test('DatabaseSeeder class and static methods are present', () {
      expect(DatabaseSeeder.seedAllData, isA<Function>());
    });
  });
}
