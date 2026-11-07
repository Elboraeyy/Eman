import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iman/src/core/database/app_database.dart';
import 'package:iman/src/core/database/database_initializer.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock method channel for loading assets and path provider in tests
  setUpAll(() {
    // Mock flutter/assets
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List());
      
      // Load file from local project directory
      final file = File(key);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return ByteData.sublistView(bytes);
      }
      return null;
    });

    // Mock plugins.flutter.io/path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async {
        return '.';
      },
    );
  });

  test('Test Hadith Database Initialization', () async {
    // Open in-memory SQLite database
    final db = AppDatabase();
    final initializer = DatabaseInitializer(db);

    debugPrint('Starting database initialization test...');
    try {
      await initializer.initializeDatabase();
      debugPrint('Database initialization finished successfully!');
      
      // Verify Categories
      final cats = await db.select(db.hadithCategories).get();
      debugPrint('Total Categories seeded: ${cats.length}');
      for (var c in cats.take(3)) {
        debugPrint('Category: ID=${c.id}, Title=${c.title}');
      }

      // Verify Books
      final books = await db.select(db.hadithBooks).get();
      debugPrint('Total Books seeded: ${books.length}');
      for (var b in books.take(3)) {
        debugPrint('Book: ID=${b.id}, Title=${b.title}');
      }

      // Verify Hadiths
      final hadiths = await db.select(db.hadiths).get();
      debugPrint('Total Hadiths seeded: ${hadiths.length}');
      for (var h in hadiths.take(3)) {
        debugPrint('Hadith: ID=${h.id}, TextLength=${h.textContent.length}, BookID=${h.bookId}, CatID=${h.categoryId}');
      }

      expect(cats, isNotEmpty);
      expect(books, isNotEmpty);
      expect(hadiths, isNotEmpty);
    } catch (e, stack) {
      debugPrint('Exception thrown during initialization: $e');
      debugPrint(stack.toString());
      fail('Database initialization failed!');
    } finally {
      await db.close();
    }
  });
}
