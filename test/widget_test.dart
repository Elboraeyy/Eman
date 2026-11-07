import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iman/main.dart';
import 'package:iman/src/core/database/app_database.dart';
import 'package:iman/src/core/database/database_provider.dart';
import 'package:iman/src/core/database/shared_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Disable GoogleFonts runtime HTTP fetching during tests to avoid network exceptions
    GoogleFonts.config.allowRuntimeFetching = false;

    // Mock flutter/assets to load files from local disk and redirect google_fonts to local TTF files
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      if (message == null) return null;
      var key = utf8.decode(message.buffer.asUint8List());
      
      if (key.contains('google_fonts/')) {
        key = 'assets/fonts/QCF_P001.TTF';
      }

      final file = File(key);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return ByteData.sublistView(bytes);
      }
      return null;
    });

    // Mock plugins.flutter.io/path_provider method channel to return a temp directory path in tests
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async {
        return '.';
      },
    );
  });


  testWidgets('Splash screen rendering smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final sharedPrefs = await SharedPreferences.getInstance();
    final db = AppDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen shows 'إيمان'
    expect(find.text('إيمان'), findsOneWidget);
    await db.close();
  });
}


