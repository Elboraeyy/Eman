import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/core/responsive/app_insets.dart';
import '../../data/repositories/tracker_repository_provider.dart';
import 'tracker_screen.dart';

class DayHistoryItem {
  final DateTime date;
  final String dateStr;
  final int completedTasksCount;
  final int totalTasksCount;
  final int quranPages;
  final int tasbihCount;
  final int adhkarCount;

  DayHistoryItem({
    required this.date,
    required this.dateStr,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.quranPages,
    required this.tasbihCount,
    required this.adhkarCount,
  });
}

final historyDaysProvider = FutureProvider<List<DayHistoryItem>>((ref) async {
  final repo = ref.watch(trackerRepositoryProvider);
  final allTasks = await repo.getAllTasks();
  final now = DateTime.now();
  final list = <DayHistoryItem>[];

  for (var i = 0; i < 14; i++) {
    final d = now.subtract(Duration(days: i));
    final dStr = DateFormat('yyyy-MM-dd').format(d);
    final completions = await repo.getCompletionsForDate(dStr);
    final stats = await repo.getUserStatsForDate(dStr);
    final completedCount = completions.where((c) => c.completed).length;

    list.add(DayHistoryItem(
      date: d,
      dateStr: dStr,
      completedTasksCount: completedCount,
      totalTasksCount: allTasks.length,
      quranPages: stats?.quranPagesRead ?? 0,
      tasbihCount: stats?.tasbihCount ?? 0,
      adhkarCount: stats?.adhkarCompleted ?? 0,
    ));
  }
  return list;
});

class TaskHistoryScreen extends ConsumerWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(overallStatsSummaryProvider);
    final weeklyAsync = ref.watch(weeklyStatsProvider);
    final historyAsync = ref.watch(historyDaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'سجل الطاعات والإنجازات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(overallStatsSummaryProvider);
          ref.invalidate(weeklyStatsProvider);
          ref.invalidate(historyDaysProvider);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 120 + context.navBarInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Achievement Summary Card
              summaryAsync.when(
                data: (summary) => _buildAchievementCard(theme, summary),
                loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // 2. Weekly Progress Chart Section
              ArabicText(
                'نسبة الالتزام اليومي (آخر 7 أيام)',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              weeklyAsync.when(
                data: (stats) => _buildWeeklyChart(theme, stats),
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // 3. Badges Section
              ArabicText(
                'أوسمة الفخر والالتزام',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              summaryAsync.when(
                data: (summary) => _buildBadgesRow(theme, summary),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // 4. Legacy Timeline
              ArabicText(
                'سجل الأيام السابقة (آخر أسبوعين)',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              historyAsync.when(
                data: (historyList) => _buildLegacyTimeline(theme, historyList),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                error: (err, _) => Center(child: ArabicText('تعذر تحميل السجل: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(ThemeData theme, Map<String, dynamic> summary) {
    final currentStreak = (summary['currentStreak'] as int?) ?? 0;
    final bestStreak = (summary['bestStreak'] as int?) ?? 0;
    final totalCompleted = (summary['totalCompletedTasks'] as int?) ?? 0;
    final quranPages = (summary['totalQuranPages'] as int?) ?? 0;
    final tasbih = (summary['totalTasbih'] as int?) ?? 0;

    final estimatedPoints = (totalCompleted * 10) + (quranPages * 5) + (tasbih / 10).round();
    final level = (totalCompleted / 10).floor() + 1;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: const Color(0xFFF59E0B),
              size: 54,
            ),
            const SizedBox(height: 8),
            ArabicText(
              'رصيد الإنجاز الإيماني التقديري',
              style: GoogleFonts.cairo(fontSize: 12, color: theme.hintColor),
            ),
            const SizedBox(height: 4),
            ArabicText(
              '$estimatedPoints نقطة بركة',
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(child: _buildStatItem('$currentStreak أيام', 'سلسلة متواصلة', theme)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatItem('المستوى $level', 'رتبة الطاعة', theme)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatItem('$bestStreak أيام', 'أعلى التزام', theme)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade().scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1), duration: 350.ms);
  }

  Widget _buildStatItem(String value, String label, ThemeData theme) {
    return Column(
      children: [
        ArabicText(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: theme.colorScheme.primary,
          ),
        ),
        ArabicText(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(fontSize: 11, color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(ThemeData theme, Map<String, double> stats) {
    if (stats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: ArabicText('لا توجد بيانات كافية للأسبوع.', style: GoogleFonts.cairo())),
        ),
      );
    }

    final entries = stats.entries.toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: entries.map((entry) {
            final val = entry.value.clamp(0.0, 1.0);
            final isFull = val >= 0.95;
            final date = DateTime.tryParse(entry.key);
            final dayName = date != null ? DateFormat('E', 'ar').format(date) : '';

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: (70 * val) > 6 ? (70 * val) : 6,
                    decoration: BoxDecoration(
                      color: isFull
                          ? const Color(0xFF10B981)
                          : (val > 0.3 ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ArabicText(
                    dayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ).animate().fade(delay: 100.ms);
  }

  Widget _buildBadgesRow(ThemeData theme, Map<String, dynamic> summary) {
    final quranPages = (summary['totalQuranPages'] as int?) ?? 0;
    final tasbih = (summary['totalTasbih'] as int?) ?? 0;
    final streak = (summary['currentStreak'] as int?) ?? 0;

    final badges = [
      _BadgeData('صديق القرآن', Icons.menu_book_rounded, quranPages >= 10),
      _BadgeData('الذاكرين', Icons.fingerprint_rounded, tasbih >= 100),
      _BadgeData('صاحب الهمة', Icons.local_fire_department_rounded, streak >= 3),
    ];

    return Row(
      children: badges.map((badge) {
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.isUnlocked
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.disabledColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: badge.isUnlocked ? theme.colorScheme.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  badge.icon,
                  color: badge.isUnlocked ? theme.colorScheme.primary : theme.disabledColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              ArabicText(
                badge.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: badge.isUnlocked ? theme.colorScheme.primary : theme.disabledColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fade(delay: 200.ms);
  }

  Widget _buildLegacyTimeline(ThemeData theme, List<DayHistoryItem> historyList) {
    return Column(
      children: historyList.map((item) {
        final isToday = item.dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());
        final isYesterday = item.dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
        
        String dateLabel;
        if (isToday) {
          dateLabel = 'اليوم';
        } else if (isYesterday) {
          dateLabel = 'أمس';
        } else {
          dateLabel = DateFormat('EEEE, d MMMM', 'ar').format(item.date);
        }

        final details = <String>[];
        if (item.completedTasksCount > 0) details.add('${item.completedTasksCount} طاعات');
        if (item.quranPages > 0) details.add('${item.quranPages} صفحات قرآن');
        if (item.tasbihCount > 0) details.add('${item.tasbihCount} تسبيحة');
        if (item.adhkarCount > 0) details.add('${item.adhkarCount} أذكار');

        final detailsText = details.isNotEmpty ? details.join(' • ') : 'لم يتم تسجيل طاعات في هذا اليوم';

        final hasActivity = item.completedTasksCount > 0 || item.quranPages > 0 || item.tasbihCount > 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: hasActivity ? theme.colorScheme.primary.withValues(alpha: 0.25) : theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: hasActivity ? theme.colorScheme.primary.withValues(alpha: 0.12) : theme.disabledColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActivity ? Icons.check_circle_outline_rounded : Icons.history_rounded,
                color: hasActivity ? theme.colorScheme.primary : theme.disabledColor,
                size: 20,
              ),
            ),
            title: ArabicText(
              dateLabel,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: ArabicText(
              detailsText,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: hasActivity ? theme.textTheme.bodyMedium?.color : theme.hintColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BadgeData {
  final String name;
  final IconData icon;
  final bool isUnlocked;

  _BadgeData(this.name, this.icon, this.isUnlocked);
}
