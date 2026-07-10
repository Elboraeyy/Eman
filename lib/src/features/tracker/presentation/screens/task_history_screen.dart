import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

class TaskHistoryScreen extends ConsumerWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'إرث الإنجازات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Achievement Summary Card
            _buildAchievementCard(theme),
            
            const SizedBox(height: 32),
            
            // 2. Weekly Progress Chart Section
            ArabicText(
              'إحصائيات الأسبوع',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyChart(theme),
            
            const SizedBox(height: 32),
            
            // 3. Badges Section
            ArabicText(
              'أوسمة الفخر والالتزام',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildBadgesRow(theme),
            
            const SizedBox(height: 32),
            
            // 4. Legacy Timeline
            ArabicText(
              'سجل الخلود والعبادات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildLegacyTimeline(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              color: theme.colorScheme.secondary,
              size: 64,
            ),
            const SizedBox(height: 8),
            ArabicText(
              'رصيد الحسنات والالتزام المقدر',
              style: GoogleFonts.cairo(fontSize: 13, color: theme.disabledColor),
            ),
            const SizedBox(height: 4),
            ArabicText(
              '1,450 نقطة',
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('12 يوم', 'سلسلة متواصلة', theme),
                _buildStatItem('المستوى 4', 'مستوى العبادة', theme),
                _buildStatItem('28 يوم', 'أعلى التزام', theme),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms);
  }

  Widget _buildStatItem(String value, String label, ThemeData theme) {
    return Column(
      children: [
        ArabicText(
          value,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: theme.colorScheme.primary,
          ),
        ),
        ArabicText(
          label,
          style: GoogleFonts.cairo(fontSize: 11, color: theme.disabledColor),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(ThemeData theme) {
    final days = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    final progress = [0.8, 0.6, 0.9, 1.0, 0.5, 0.7, 0.9];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(days.length, (index) {
            final val = progress[index];
            final isFull = val == 1.0;

            return Column(
              children: [
                Container(
                  width: 12,
                  height: 80 * val,
                  decoration: BoxDecoration(
                    color: isFull ? theme.colorScheme.secondary : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                ArabicText(
                  days[index],
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
        ),
      ),
    ).animate().fade(delay: 100.ms);
  }

  Widget _buildBadgesRow(ThemeData theme) {
    final badges = [
      _BadgeData('فارس الفجر', Icons.wb_twilight, true),
      _BadgeData('صديق القرآن', Icons.menu_book, true),
      _BadgeData('المستغفرين', Icons.spa, false),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: badges.map((badge) {
        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isUnlocked
                    ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                    : theme.disabledColor.withValues(alpha: 0.05),
                border: Border.all(
                  color: badge.isUnlocked ? theme.colorScheme.secondary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                badge.icon,
                color: badge.isUnlocked ? theme.colorScheme.secondary : theme.disabledColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            ArabicText(
              badge.name,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked ? theme.colorScheme.primary : theme.disabledColor,
              ),
            ),
          ],
        );
      }).toList(),
    ).animate().fade(delay: 200.ms);
  }

  Widget _buildLegacyTimeline(ThemeData theme) {
    final items = [
      _TimelineItem('اليوم', 'أنجزت جميع الصلوات الخمس المفروضة في أوقاتها.'),
      _TimelineItem('أمس', 'قرأت جزءاً كاملاً من القرآن وقمت بإتمام ورد الأذكار.'),
      _TimelineItem('منذ 3 أيام', 'حققت سلسلة 7 أيام متواصلة لصلاة الفجر في جماعة.'),
    ];

    return Column(
      children: items.map((item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Container(
                  width: 2,
                  height: 48,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ArabicText(
                    item.time,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  ArabicText(
                    item.title,
                    style: GoogleFonts.cairo(fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    ).animate().fade(delay: 300.ms);
  }
}

class _BadgeData {
  final String name;
  final IconData icon;
  final bool isUnlocked;

  _BadgeData(this.name, this.icon, this.isUnlocked);
}

class _TimelineItem {
  final String time;
  final String title;

  _TimelineItem(this.time, this.title);
}
