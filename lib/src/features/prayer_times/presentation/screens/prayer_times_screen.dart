import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/services.dart';
import 'package:zad/src/core/database/shared_preferences_provider.dart';
import 'package:zad/src/features/prayer_times/data/repositories/prayer_repository_provider.dart';
import '../../domain/entities/prayer_entities.dart';
import '../controllers/prayer_times_controller.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

// NotifierProvider to manage the active selected date for prayer times
class SelectedPrayerDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  @override
  set state(DateTime value) => super.state = value;
}

final selectedPrayerDateProvider = NotifierProvider<SelectedPrayerDateNotifier, DateTime>(SelectedPrayerDateNotifier.new);

// Provider to get prayer times for the selected date
final selectedDatePrayerTimesProvider = FutureProvider<PrayerTimes?>((ref) async {
  final date = ref.watch(selectedPrayerDateProvider);
  final locationAsync = ref.watch(locationProvider);
  final location = locationAsync.value;
  final repo = ref.watch(prayerRepositoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final method = prefs.getInt('prayer_calculation_method') ?? 5;

  final double lat = location?.latitude ?? 30.044420;
  final double lng = location?.longitude ?? 31.235712;

  return await repo.getPrayerTimesForDate(
    latitude: lat,
    longitude: lng,
    date: date,
    method: method,
  );
});

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  Timer? _timer;
  Duration _timeUntilNext = Duration.zero;
  String _nextPrayerName = '...';
  DateTime? _nextPrayerTime;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateCountdown();
    });
  }

  void _calculateCountdown() {
    final todayTimes = ref.read(todayPrayerTimesProvider).value;
    if (todayTimes == null) return;

    final now = DateTime.now();
    final list = [
      _PrayerTimeInfo('الفجر', todayTimes.fajr, Icons.wb_cloudy),
      _PrayerTimeInfo('الشروق', todayTimes.sunrise, Icons.wb_sunny),
      _PrayerTimeInfo('الظهر', todayTimes.dhuhr, Icons.wb_sunny_outlined),
      _PrayerTimeInfo('العصر', todayTimes.asr, Icons.wb_cloudy_outlined),
      _PrayerTimeInfo('المغرب', todayTimes.maghrib, Icons.mosque),
      _PrayerTimeInfo('العشاء', todayTimes.isha, Icons.nightlight_round),
    ];

    _PrayerTimeInfo? next;
    bool isTomorrow = false;

    for (final p in list) {
      if (p.time.isAfter(now)) {
        next = p;
        break;
      }
    }

    if (next == null) {
      // Next prayer is Fajr tomorrow
      next = _PrayerTimeInfo('الفجر', todayTimes.fajr.add(const Duration(days: 1)), Icons.wb_cloudy);
      isTomorrow = true;
    }

    final diff = next.time.difference(now);

    if (mounted) {
      setState(() {
        _timeUntilNext = diff;
        _nextPrayerName = next!.name + (isTomorrow ? ' (غداً)' : '');
        _nextPrayerTime = next.time;
      });
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedPrayerDateProvider);
    final prayerTimesAsync = ref.watch(selectedDatePrayerTimesProvider);
    final locationAsync = ref.watch(locationProvider);
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'مواقيت الصلاة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showCalculationMethodDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Countdown Card (Only for today)
            if (isToday && _nextPrayerTime != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
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
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        ArabicText(
                          locationAsync.value?.cityName ?? 'القاهرة',
                          style: GoogleFonts.cairo(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        ArabicText(
                          'صلاة $_nextPrayerName القادمة خلال',
                          style: GoogleFonts.cairo(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        ArabicText(
                          _formatDuration(_timeUntilNext),
                          style: GoogleFonts.cairo(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade().slideY(begin: -0.1, end: 0)
            else
              const SizedBox(height: 12),

            // Date Navigator Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 18, color: theme.colorScheme.primary),
                    onPressed: () {
                      ref.read(selectedPrayerDateProvider.notifier).state =
                          selectedDate.add(const Duration(days: 1));
                    },
                  ),
                  Column(
                    children: [
                      ArabicText(
                        DateFormat('EEEE، d MMMM yyyy', 'ar').format(selectedDate),
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (!isToday)
                        GestureDetector(
                          onTap: () {
                            ref.read(selectedPrayerDateProvider.notifier).state = DateTime.now();
                          },
                          child: ArabicText(
                            'العودة لليوم',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 18, color: theme.colorScheme.primary),
                    onPressed: () {
                      ref.read(selectedPrayerDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 1));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Prayer Times List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: prayerTimesAsync.when(
                data: (times) {
                  if (times == null) {
                    return Center(
                      child: ArabicText(
                        'تعذر تحميل مواقيت الصلاة لهذه الإحداثيات.',
                        style: GoogleFonts.cairo(),
                      ),
                    );
                  }

                  final list = [
                    _PrayerUiItem('الفجر', times.fajr, Icons.wb_cloudy, 'fajr'),
                    _PrayerUiItem('الشروق', times.sunrise, Icons.wb_sunny, 'sunrise', isPrayer: false),
                    _PrayerUiItem('الظهر', times.dhuhr, Icons.wb_sunny_outlined, 'dhuhr'),
                    _PrayerUiItem('العصر', times.asr, Icons.wb_cloudy_outlined, 'asr'),
                    _PrayerUiItem('المغرب', times.maghrib, Icons.mosque, 'maghrib'),
                    _PrayerUiItem('العشاء', times.isha, Icons.nightlight_round, 'isha'),
                  ];

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final isCurrent = isToday &&
                          _nextPrayerTime != null &&
                          _nextPrayerName.contains(item.name);

                      return _buildPrayerTimeCard(context, item, isCurrent, theme);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: ArabicText('خطأ في تحميل الأوقات: $err')),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(BuildContext context, _PrayerUiItem item, bool isCurrent, ThemeData theme) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final alertPref = prefs.getInt('prayer_alert_${item.key}') ?? (item.isPrayer ? 1 : 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: isCurrent
          ? theme.colorScheme.primary.withValues(alpha: 0.06)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isCurrent
              ? theme.colorScheme.secondary.withValues(alpha: 0.6)
              : theme.dividerColor,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  alertPref == 2
                      ? Icons.notifications_active
                      : alertPref == 1
                          ? Icons.notifications
                          : Icons.notifications_off,
                  color: alertPref > 0
                      ? theme.colorScheme.secondary
                      : theme.disabledColor.withValues(alpha: 0.5),
                  size: 20,
                ),
                const SizedBox(width: 14),
                ArabicText(
                  DateFormat('hh:mm a', 'ar').format(item.time),
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ArabicText(
                      item.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (isCurrent)
                      ArabicText(
                        'الصلاة القادمة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Icon(
                    item.icon,
                    color: isCurrent ? theme.colorScheme.primary : theme.disabledColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(target: isCurrent ? 1 : 0).shimmer(duration: 1200.ms, delay: 200.ms);
  }

  void _showCalculationMethodDialog(BuildContext context) {
    final prefs = ref.read(sharedPreferencesProvider);
    final currentMethod = prefs.getInt('prayer_calculation_method') ?? 5;

    final methods = {
      1: 'جامعة العلوم الإسلامية بكراتشي',
      2: 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
      3: 'رابطة العالم الإسلامي (MWL)',
      4: 'جامعة أم القرى، مكة المكرمة',
      5: 'الهيئة المصرية العامة للمساحة',
      9: 'دولة الكويت',
      10: 'دولة قطر',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ArabicText(
          'طريقة حساب مواقيت الصلاة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: methods.entries.map((entry) {
              return RadioListTile<int>(
                title: ArabicText(
                  entry.value,
                  style: GoogleFonts.cairo(fontSize: 13),
                  textAlign: TextAlign.right,
                ),
                value: entry.key,
                groupValue: currentMethod,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) async {
                  if (val != null) {
                    await prefs.setInt('prayer_calculation_method', val);
                    ref.invalidate(todayPrayerTimesProvider);
                    ref.invalidate(selectedDatePrayerTimesProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PrayerTimeInfo {
  final String name;
  final DateTime time;
  final IconData icon;

  _PrayerTimeInfo(this.name, this.time, this.icon);
}

class _PrayerUiItem {
  final String name;
  final DateTime time;
  final IconData icon;
  final String key;
  final bool isPrayer;

  _PrayerUiItem(this.name, this.time, this.icon, this.key, {this.isPrayer = true});
}
