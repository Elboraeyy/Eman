// آمن للتحديثات الفورية — التحديث والتعديل يأتي تلقائيًا للجميع عبر Shorebird ✅
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'src/core/database/app_database.dart';
import 'src/core/database/database_provider.dart';
import 'src/core/database/database_initializer.dart';
import 'src/core/database/shared_preferences_provider.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background audio safely
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.elboraeyy.iman.channel.audio',
      androidNotificationChannelName: 'Iman Audio Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    );
  } catch (e) {
    debugPrint('JustAudioBackground init warning: $e');
  }

  // Initialize date formatting for Arabic
  try {
    await initializeDateFormatting('ar', null);
  } catch (e) {
    debugPrint('DateFormatting init warning: $e');
  }

  // Create database instance and populate data if empty (offline Quran, Hadith, Adhkar)
  final db = AppDatabase();
  try {
    final initializer = DatabaseInitializer(db);
    await initializer.initializeDatabase();
  } catch (e) {
    debugPrint('Database initialization warning: $e');
  }

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'إيمان',
      debugShowCheckedModeBanner: false,
      
      // Themes
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      
      // Navigation
      routerConfig: appRouter,
      
      // Localization Support (RTL by default for Arabic UI)
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
      ],
    );
  }
}
