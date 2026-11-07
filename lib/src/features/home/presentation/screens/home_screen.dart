import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:iman/src/features/hadith/data/repositories/hadith_repository_provider.dart';
import 'package:iman/src/features/hadith/domain/entities/hadith_entities.dart';
import 'package:iman/src/features/prayer_times/domain/entities/prayer_entities.dart';
import 'package:iman/src/features/prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../../../quran/presentation/controllers/quran_progress_controller.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iman/src/core/database/shared_preferences_provider.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:iman/src/features/tracker/presentation/screens/tracker_screen.dart';

// Hadith of the day provider
final hadithOfTheDayProvider = FutureProvider<Hadith?>((ref) async {
  final repo = ref.watch(hadithRepositoryProvider);
  // Fetch core hadiths from category 1 (أهم الأحاديث / جوامع الدّين)
  final hadiths = await repo.getHadithsByCategory(1);
  if (hadiths.isEmpty) return null;
  final today = DateTime.now();
  final dayIndex = (today.year * 365 + today.month * 30 + today.day) % hadiths.length;
  return hadiths[dayIndex];
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocationPermission();
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final prompted = prefs.getBool('location_permission_prompted') ?? false;
    
    if (!prompted) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showLocationPermissionBottomSheet(context);
        }
      } else {
        await prefs.setBool('location_permission_prompted', true);
      }
    }
  }

  void _showLocationPermissionBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.gps_fixed,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              ArabicText(
                'تفعيل تحديد الموقع',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              ArabicText(
                'يحتاج تطبيق إيمان إلى صلاحية الوصول للموقع لكي يتمكن من تحديد مواقيت الصلاة واتجاه القبلة بدقة متناهية بناءً على مكانك الحالي.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  height: 1.6,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final permission = await Geolocator.requestPermission();
                  final prefs = ref.read(sharedPreferencesProvider);
                  await prefs.setBool('location_permission_prompted', true);
                  
                  if (permission == LocationPermission.whileInUse ||
                      permission == LocationPermission.always) {
                    ref.invalidate(locationProvider);
                  }
                },
                child: ArabicText(
                  'السماح بالوصول للموقع',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final prefs = ref.read(sharedPreferencesProvider);
                  await prefs.setBool('location_permission_prompted', true);
                },
                child: ArabicText(
                  'استخدام الموقع الافتراضي (القاهرة)',
                  style: GoogleFonts.cairo(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getArabicGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'صباح الخير والبركة';
    } else if (hour >= 12 && hour < 17) {
      return 'طاب يومك بذكر الله';
    } else {
      return 'مساء الخير والرحمة';
    }
  }

  String _getIslamicDateArabic() {
    final date = DateTime.now();
    final formatter = DateFormat('EEEE، d MMMM yyyy', 'ar');
    final gregDate = formatter.format(date);
    
    // Calculate Hijri date
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.now();
    final hijriDate = hijri.toFormat('dd MMMM yyyy');
    
    return '$gregDate | $hijriDate هـ';
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final hadithAsync = ref.watch(hadithOfTheDayProvider);
    final lastReadPage = ref.watch(lastReadPageNotifierProvider);
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Background Layer (Burgundy + Islamic Pattern + Header Content)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 270, // Fixed height for background header
              child: Container(
                color: theme.colorScheme.primary, // Burgundy
                child: Stack(
                  children: [
                    // Pattern painter
                    Positioned.fill(
                      child: CustomPaint(
                        painter: IslamicPatternPainter(
                          color: Colors.white.withValues(alpha: 0.075),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ArabicText(
                                        _getArabicGreeting(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      ArabicText(
                                        'مرحباً بك في إيمان',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                locationAsync.when(
                                  data: (loc) => InkWell(
                                    onTap: () => ref.invalidate(locationProvider),
                                    borderRadius: BorderRadius.circular(30),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.mapPin, size: 14, color: Colors.white),
                                            const SizedBox(width: 6),
                                            ArabicText(
                                              loc?.cityName ?? 'القاهرة',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  loading: () => InkWell(
                                    onTap: null,
                                    borderRadius: BorderRadius.circular(30),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            ArabicText(
                                              'جاري التحديد...',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  error: (err, stack) => InkWell(
                                    onTap: () => ref.invalidate(locationProvider),
                                    borderRadius: BorderRadius.circular(30),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade900.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.red.shade300.withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.alertTriangle, size: 14, color: Colors.white),
                                            const SizedBox(width: 6),
                                            ArabicText(
                                              'فشل التحديد',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fade(duration: 500.ms).slideY(begin: -0.05, end: 0),
                            const SizedBox(height: 8),
                            ArabicText(
                              _getIslamicDateArabic(),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: theme.colorScheme.secondary, // Gold
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fade(delay: 100.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Foreground Layer (Scrollable Rounded Sheet)
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(locationProvider);
                  ref.invalidate(todayPrayerTimesProvider);
                  ref.invalidate(hadithOfTheDayProvider);
                  ref.invalidate(lastReadPageNotifierProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Transparent spacer to reveal the background layer header
                      const SizedBox(height: 180),
                      // Rounded Foreground container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. Continue Reading (واصل القراءة) Card
                            if (lastReadPage > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: _buildContinueReadingCard(context, lastReadPage, theme),
                              ),

                            // 3. Prayer Times Card with isolated countdown
                            prayerTimesAsync.when(
                              data: (pt) {
                                if (pt == null) return const SizedBox();
                                return PrayerCountdownCard(pt: pt);
                              },
                              loading: () => _buildShimmerCard(180, theme),
                              error: (err, _) => Center(child: ArabicText('خطأ في تحميل مواقيت الصلاة: $err')),
                            ),

                            const SizedBox(height: 20),

                            // Daily Worship Tracker Progress Card
                            _buildDailyTrackerBanner(context, theme, ref),

                            const SizedBox(height: 28),

                            // 4. Quick Actions Grid
                            ArabicText(
                              'أبواب الطاعات',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActionsGrid(context, theme, prayerTimesAsync.asData?.value),

                            const SizedBox(height: 28),

                            // 5. Hadith of the Day
                            ArabicText(
                              'حديث اليوم',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            hadithAsync.when(
                              data: (hadith) {
                                if (hadith == null) return const SizedBox();
                                return _buildHadithCard(context, hadith, theme);
                              },
                              loading: () => _buildShimmerCard(120, theme),
                              error: (err, _) => Center(child: ArabicText('خطأ في تحميل الحديث: $err')),
                            ),
                            // Safe area bottom padding for floating navbar
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(BuildContext context, int page, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        onTap: () => context.push('/quran/mushaf/$page'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.bookOpen,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      'واصل القراءة',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    ArabicText(
                      'آخر صفحة قمت بزيارتها هي الصفحة $page',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? LucideIcons.chevronLeft
                    : LucideIcons.chevronRight,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildDailyTrackerBanner(BuildContext context, ThemeData theme, WidgetRef ref) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final tasksAsync = ref.watch(tasksListProvider);
    final completionsAsync = ref.watch(completionsForDateProvider(todayStr));
    final summaryAsync = ref.watch(overallStatsSummaryProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) return const SizedBox.shrink();
        final completions = completionsAsync.value ?? [];
        final completedCount = completions.where((c) => c.completed).length;
        final totalCount = tasks.length;
        final ratio = totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);
        final streak = (summaryAsync.value?['currentStreak'] as int?) ?? 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.18)),
          ),
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: InkWell(
            onTap: () => context.go('/tracker/tasks'),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: ratio,
                          strokeWidth: 5,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                      ArabicText(
                        '${(ratio * 100).toInt()}%',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ArabicText(
                              'طاعات اليوم',
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (streak > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.local_fire_department_rounded, size: 12, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 2),
                                    ArabicText(
                                      '$streak',
                                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        ArabicText(
                          '$completedCount من $totalCount عبادات منجزة اليوم',
                          style: GoogleFonts.cairo(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ArabicText(
                          'متابعة',
                          style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 10, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, ThemeData theme, PrayerTimes? prayerTimes) {
    final quranAction = _ActionItem('القرآن الكريم', 'assets/Icon/quran-rehal-svgrepo-com.svg', '/quran', const Color(0xFFFFF8E1), subtitle: 'تلاوة وتفسير');
    final adhkarAction = _ActionItem('الأذكار والأدعية', 'assets/Icon/muslim-man-praying-svgrepo-com.svg', '/adhkar', const Color(0xFFFFF8E1), subtitle: 'حصن المسلم اليومي');
    final hadithAction = _ActionItem('الأحاديث', LucideIcons.scroll, '/hadith', const Color(0xFFFFF8E1), subtitle: 'رياض الصالحين');
    final prayerAction = _ActionItem('مواقيت الصلاة', LucideIcons.clock, '/prayer/times', const Color(0xFFFFF8E1), subtitle: 'أوقات الصلوات');
    final tasbihAction = _ActionItem('المسبحة', 'assets/Icon/prayer-beads-svgrepo-com.svg', '/adhkar/tasbih/list', const Color(0xFFFFF8E1), subtitle: 'عداد التسبيح');
    final qiblaAction = _ActionItem('اتجاه القبلة', LucideIcons.compass, '/qibla', const Color(0xFFFFF8E1), subtitle: 'تحديد اتجاه الكعبة');
    
    // New Actions
    final audiosAction = _ActionItem('الصوتيات', LucideIcons.headphones, '/audios', const Color(0xFFFFF8E1), subtitle: 'تلاوات صوتية مميزة');
    final sunanAction = _ActionItem('السنن النبوية', LucideIcons.sparkles, '/sunan', const Color(0xFFFFF8E1), subtitle: 'سنن ومستحبات');
    final storiesAction = _ActionItem('قصص وعبر', LucideIcons.bookOpen, '/stories', const Color(0xFFFFF8E1), subtitle: 'قصص قرآنية ونبوية');

    return Column(
      children: [
        // Row 1: Quran, Hadith, Tasbih (three equal columns in RTL)
        Row(
          children: [
            Expanded(child: _buildItemCard(context, quranAction, theme, height: 100, delay: 100)),
            const SizedBox(width: 12),
            Expanded(child: _buildItemCard(context, hadithAction, theme, height: 100, delay: 150)),
            const SizedBox(width: 12),
            Expanded(child: _buildItemCard(context, tasbihAction, theme, height: 100, delay: 200)),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Two main sections (Right Column with Adhkar/Audios/Qibla/Sunan, Left Column with Prayer/Stories)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Right Column (flex 2) -> renders on the right in RTL
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Adhkar wide card
                  _buildWideItemCard(context, adhkarAction, theme, subtitle: adhkarAction.subtitle ?? '', height: 100, delay: 350),
                  const SizedBox(height: 12),
                  
                  // Row under Adhkar: Right (Audios), Left/Middle (Qibla, Sunan)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Right Column (Audios) -> renders on the right in RTL
                      Expanded(
                        child: _buildTallItemCard(context, audiosAction, theme, height: 212, prayerTimes: null, delay: 500),
                      ),
                      const SizedBox(width: 12),
                      // Middle Column (Qibla, Sunan) -> renders in the middle in RTL
                      Expanded(
                        child: Column(
                          children: [
                            _buildItemCard(context, qiblaAction, theme, height: 100, delay: 400),
                            const SizedBox(height: 12),
                            _buildItemCard(context, sunanAction, theme, height: 100, delay: 450),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Left Column (flex 1) -> renders on the left in RTL
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildTallItemCard(context, prayerAction, theme, height: 212, prayerTimes: prayerTimes, delay: 250),
                  const SizedBox(height: 12),
                  _buildItemCard(context, storiesAction, theme, height: 100, delay: 300),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon(dynamic iconData, ThemeData theme) {
    if (iconData is IconData) {
      return Icon(
        iconData,
        color: theme.colorScheme.primary,
        size: 24,
      );
    } else if (iconData is String) {
      return SvgPicture.asset(
        iconData,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
      );
    }
    return const SizedBox(width: 24, height: 24);
  }

  Widget _buildItemCard(
    BuildContext context,
    _ActionItem action,
    ThemeData theme, {
    required double height,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: action.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: _buildIcon(action.icon, theme),
                ),
                const SizedBox(height: 8),
                ArabicText(
                  action.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: delay.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 250.ms).fade();
  }

  Widget _buildWideItemCard(
    BuildContext context,
    _ActionItem action,
    ThemeData theme, {
    required String subtitle,
    required double height,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ArabicText(
                        action.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      ArabicText(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: action.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: _buildIcon(action.icon, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: delay.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 250.ms).fade();
  }

  Widget _buildTallItemCard(
    BuildContext context,
    _ActionItem action,
    ThemeData theme, {
    required double height,
    required PrayerTimes? prayerTimes,
    required int delay,
  }) {
    String nextPrayerName = '';
    String nextPrayerTime = '';
    if (prayerTimes != null) {
      final now = DateTime.now();
      final list = [
        _PrayerTimeInfo('الفجر', prayerTimes.fajr, LucideIcons.sunrise),
        _PrayerTimeInfo('الشروق', prayerTimes.sunrise, LucideIcons.sun),
        _PrayerTimeInfo('الظهر', prayerTimes.dhuhr, LucideIcons.sun),
        _PrayerTimeInfo('العصر', prayerTimes.asr, LucideIcons.cloud),
        _PrayerTimeInfo('المغرب', prayerTimes.maghrib, LucideIcons.sunset),
        _PrayerTimeInfo('العشاء', prayerTimes.isha, LucideIcons.moon),
      ];
      _PrayerTimeInfo? next;
      for (final p in list) {
        if (now.isBefore(p.time)) {
          next = p;
          break;
        }
      }
      if (next == null) {
        nextPrayerName = 'الفجر';
        nextPrayerTime = DateFormat('hh:mm a', 'ar').format(prayerTimes.fajr.add(const Duration(days: 1)));
      } else {
        nextPrayerName = next.name;
        nextPrayerTime = DateFormat('hh:mm a', 'ar').format(next.time);
      }
    }

    final isAudios = action.title == 'الصوتيات';

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: isAudios
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: action.bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: _buildIcon(action.icon, theme),
                      ),
                      const SizedBox(height: 8),
                      ArabicText(
                        action.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 32,
                        height: 1.5,
                        color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      _buildAudioSubItem(theme, LucideIcons.bookOpen, 'قرآن'),
                      const SizedBox(height: 6),
                      _buildAudioSubItem(theme, LucideIcons.radio, 'إذاعة'),
                      const SizedBox(height: 6),
                      _buildAudioSubItem(theme, LucideIcons.mic, 'بودكاست'),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: action.bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: _buildIcon(action.icon, theme),
                          ),
                          const SizedBox(height: 12),
                          ArabicText(
                            action.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      if (prayerTimes != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ArabicText(
                                'التالي: $nextPrayerName',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              ArabicText(
                                nextPrayerTime,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ArabicText(
                          action.subtitle ?? 'مواقيت الصلاة اليومية',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    ).animate(delay: delay.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 250.ms).fade();
  }

  Widget _buildAudioSubItem(ThemeData theme, IconData icon, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ArabicText(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(BuildContext context, Hadith hadith, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.push('/hadith/detail/${hadith.id}');
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.quote, color: theme.colorScheme.secondary, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ArabicText(
                      hadith.narrator,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ArabicText(
                hadith.text,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  height: 1.6,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              if (hadith.source.isNotEmpty) ...[
                const Divider(height: 24),
                ArabicText(
                  'المصدر: ${hadith.source}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildShimmerCard(double height, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
    ).animate(onPlay: (c) => c.repeat())
     .shimmer(color: theme.colorScheme.primary.withValues(alpha: 0.05), duration: 1500.ms);
  }
}

// Dedicated Widget to Isolate Prayer Countdown Timer Rebuilds
class PrayerCountdownCard extends ConsumerStatefulWidget {
  final PrayerTimes pt;

  const PrayerCountdownCard({
    super.key,
    required this.pt,
  });

  @override
  ConsumerState<PrayerCountdownCard> createState() => _PrayerCountdownCardState();
}

class _PrayerCountdownCardState extends ConsumerState<PrayerCountdownCard> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine the next prayer
    final list = [
      _PrayerTimeInfo('الفجر', widget.pt.fajr, LucideIcons.sunrise),
      _PrayerTimeInfo('الشروق', widget.pt.sunrise, LucideIcons.sun),
      _PrayerTimeInfo('الظهر', widget.pt.dhuhr, LucideIcons.sun),
      _PrayerTimeInfo('العصر', widget.pt.asr, LucideIcons.cloud),
      _PrayerTimeInfo('المغرب', widget.pt.maghrib, LucideIcons.sunset),
      _PrayerTimeInfo('العشاء', widget.pt.isha, LucideIcons.moon),
    ];

    _PrayerTimeInfo? nextPrayer;
    for (final p in list) {
      if (_now.isBefore(p.time)) {
        nextPrayer = p;
        break;
      }
    }

    final bool isTomorrow = nextPrayer == null;
    final displayNextPrayer = nextPrayer ?? _PrayerTimeInfo('الفجر', widget.pt.fajr.add(const Duration(days: 1)), Icons.wb_twilight);

    final difference = displayNextPrayer.time.difference(_now);
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    final countdownStr = '$hours:$minutes:$seconds';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            const Color(0xFF5E000B), // Deep Burgundy
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      displayNextPrayer.icon,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    ArabicText(
                      '${displayNextPrayer.name == 'الشروق' ? '' : 'صلاة '}${displayNextPrayer.name}${isTomorrow ? ' (غداً)' : ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ArabicText(
                  'المتبقي',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ArabicText(
                  DateFormat('hh:mm a', 'ar').format(displayNextPrayer.time),
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                ArabicText(
                  countdownStr,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: list.map((p) {
                final isCurrent = nextPrayer != null && list.indexOf(p) == (list.indexOf(nextPrayer) - 1);
                return Column(
                  children: [
                    ArabicText(
                      p.name,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isCurrent ? theme.colorScheme.secondary : Colors.white70,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ArabicText(
                      DateFormat('hh:mm', 'ar').format(p.time),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isCurrent ? Colors.white : Colors.white60,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class _PrayerTimeInfo {
  final String name;
  final DateTime time;
  final IconData icon;

  _PrayerTimeInfo(this.name, this.time, this.icon);
}

class _ActionItem {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final String route;
  final Color bgColor;

  _ActionItem(this.title, this.icon, this.route, this.bgColor, {this.subtitle});
}

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double starSize = 80.0;
    const double spacing = 100.0;

    for (double x = -starSize; x < size.width + starSize; x += spacing) {
      for (double y = -starSize; y < size.height + starSize; y += spacing) {
        _drawIslamicStar(canvas, Offset(x, y), starSize / 2, paint);
      }
    }
  }

  void _drawIslamicStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path1 = Path();
    final path2 = Path();

    // Square 1
    path1.moveTo(center.dx + radius, center.dy + radius);
    path1.lineTo(center.dx - radius, center.dy + radius);
    path1.lineTo(center.dx - radius, center.dy - radius);
    path1.lineTo(center.dx + radius, center.dy - radius);
    path1.close();

    // Square 2 (rotated by 45 degrees)
    final double diagonal = radius * 1.414;
    path2.moveTo(center.dx + diagonal, center.dy);
    path2.lineTo(center.dx, center.dy + diagonal);
    path2.lineTo(center.dx - diagonal, center.dy);
    path2.lineTo(center.dx, center.dy - diagonal);
    path2.close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
