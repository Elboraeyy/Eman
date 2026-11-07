import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/audios_screen.dart';
import '../../features/home/presentation/screens/sunan_screen.dart';
import '../../features/home/presentation/screens/stories_screen.dart';
import '../../features/home/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/onboarding_screen.dart';
import '../../features/quran/presentation/screens/quran_index_screen.dart';
import '../../features/quran/presentation/screens/mushaf_screen.dart';
import '../../features/quran/presentation/screens/surah_detail_screen.dart';
import '../../features/quran/presentation/screens/tafsir_menu_screen.dart';
import '../../features/quran/presentation/screens/tafsir_surah_list_screen.dart';
import '../../features/quran/presentation/screens/tafsir_detail_screen.dart';
import '../../features/quran/presentation/screens/quran_search_screen.dart';
import '../../features/hadith/presentation/screens/hadith_index_screen.dart';
import '../../features/hadith/presentation/screens/hadith_detail_screen.dart';
import '../../features/hadith/presentation/screens/hadith_books_list_screen.dart';
import '../../features/hadith/presentation/screens/hadith_book_detail_screen.dart';
import '../../features/adhkar/presentation/screens/adhkar_index_screen.dart';
import '../../features/adhkar/presentation/screens/tasbih_list_screen.dart';
import '../../features/adhkar/presentation/screens/tasbih_counting_screen.dart';
import '../../features/tracker/presentation/screens/tracker_screen.dart';
import '../../features/tracker/presentation/screens/task_customization_screen.dart';
import '../../features/tracker/presentation/screens/task_history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/favorites_screen.dart';
import '../../features/settings/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/terms_screen.dart';
import '../../features/settings/presentation/screens/contact_screen.dart';
import '../../features/prayer_times/presentation/screens/compass_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: <RouteBase>[
    // Full screen pre-home routes
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),

    // Main Shell Tab Routes
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainShell(state: state, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: '/tracker/stats',
          builder: (BuildContext context, GoRouterState state) {
            return const TrackerScreen(mode: 'stats');
          },
        ),
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/tracker/tasks',
          builder: (BuildContext context, GoRouterState state) {
            return const TrackerScreen(mode: 'tasks');
          },
        ),
        GoRoute(
          path: '/quran',
          builder: (BuildContext context, GoRouterState state) {
            return const QuranIndexScreen();
          },
        ),
      ],
    ),
    
    // Full Screen Routes (Outside Shell Bottom Bar)
    GoRoute(
      path: '/hadith',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const HadithIndexScreen();
      },
    ),
    GoRoute(
      path: '/hadith/books',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const HadithBooksListScreen();
      },
    ),
    GoRoute(
      path: '/hadith/book/:bookId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final bookIdStr = state.pathParameters['bookId'] ?? '1';
        final bookId = int.tryParse(bookIdStr) ?? 1;
        return HadithBookDetailScreen(bookId: bookId);
      },
    ),
    GoRoute(
      path: '/hadith/detail/:hadithId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final hadithIdStr = state.pathParameters['hadithId'] ?? '1';
        final hadithId = int.tryParse(hadithIdStr) ?? 1;
        return HadithDetailScreen(hadithId: hadithId);
      },
    ),
    GoRoute(
      path: '/adhkar',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const AdhkarIndexScreen();
      },
    ),
    GoRoute(
      path: '/adhkar/tasbih/list',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const TasbihListScreen();
      },
    ),
    GoRoute(
      path: '/adhkar/tasbih/counting/:tasbihId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final tasbihIdStr = state.pathParameters['tasbihId'] ?? '1';
        final tasbihId = int.tryParse(tasbihIdStr) ?? 1;
        return TasbihCountingScreen(tasbihId: tasbihId);
      },
    ),
    GoRoute(
      path: '/quran/surah/:surahNumber',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final surahNumStr = state.pathParameters['surahNumber'] ?? '1';
        final surahNum = int.tryParse(surahNumStr) ?? 1;
        return SurahDetailScreen(surahNumber: surahNum);
      },
    ),
    GoRoute(
      path: '/quran/mushaf/:startPage',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final startPageStr = state.pathParameters['startPage'] ?? '1';
        final startPage = int.tryParse(startPageStr) ?? 1;
        return MushafScreen(startPage: startPage);
      },
    ),
    GoRoute(
      path: '/quran/tafsir/menu',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const TafsirMenuScreen();
      },
    ),
    GoRoute(
      path: '/quran/tafsir/surahs',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const TafsirSurahListScreen();
      },
    ),
    GoRoute(
      path: '/quran/tafsir/detail/:surahNumber',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final surahNumStr = state.pathParameters['surahNumber'] ?? '1';
        final surahNum = int.tryParse(surahNumStr) ?? 1;
        return TafsirDetailScreen(surahNumber: surahNum);
      },
    ),

    GoRoute(
      path: '/quran/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const QuranSearchScreen();
      },
    ),
    GoRoute(
      path: '/qibla',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const CompassScreen();
      },
    ),
    GoRoute(
      path: '/prayer/times',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const PrayerTimesScreen();
      },
    ),
    GoRoute(
      path: '/audios',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const AudiosScreen();
      },
    ),
    GoRoute(
      path: '/sunan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const SunanScreen();
      },
    ),
    GoRoute(
      path: '/stories',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const StoriesScreen();
      },
    ),
    GoRoute(
      path: '/tracker/customization',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const TaskCustomizationScreen();
      },
    ),
    GoRoute(
      path: '/tracker/history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const TaskHistoryScreen();
      },
    ),
    GoRoute(
      path: '/settings/favorites',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const FavoritesScreen();
      },
    ),
    GoRoute(
      path: '/settings/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationsScreen();
      },
    ),
    GoRoute(
      path: '/settings/about',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const AboutScreen();
      },
    ),
    GoRoute(
      path: '/settings/privacy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const PrivacyPolicyScreen();
      },
    ),
    GoRoute(
      path: '/settings/terms',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const TermsScreen();
      },
    ),
    GoRoute(
      path: '/settings/contact',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const ContactScreen();
      },
    ),
  ],
);
