import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:iman/src/core/database/shared_preferences_provider.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(sharedPreferencesProvider);

    final prayers = [
      _PrayerNotificationData('صلاة الفجر', 'fajr'),
      _PrayerNotificationData('شروق الشمس', 'sunrise', isPrayer: false),
      _PrayerNotificationData('صلاة الظهر', 'dhuhr'),
      _PrayerNotificationData('صلاة العصر', 'asr'),
      _PrayerNotificationData('صلاة المغرب', 'maghrib'),
      _PrayerNotificationData('صلاة العشاء', 'isha'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'تنبيهات الصلاة والأذان',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20.0),
        itemCount: prayers.length,
        separatorBuilder: (context, index) => Divider(color: theme.dividerColor, height: 1),
        itemBuilder: (context, index) {
          final prayer = prayers[index];
          final currentAlert = prefs.getInt('prayer_alert_${prayer.key}') ?? (prayer.isPrayer ? 1 : 0);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Alert type selectors
                Row(
                  children: [
                    _buildAlertOption(
                      context,
                      theme,
                      icon: Icons.notifications_off,
                      label: 'صامت',
                      isSelected: currentAlert == 0,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await prefs.setInt('prayer_alert_${prayer.key}', 0);
                        ref.invalidate(sharedPreferencesProvider);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildAlertOption(
                      context,
                      theme,
                      icon: Icons.notifications,
                      label: 'رنين',
                      isSelected: currentAlert == 1,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await prefs.setInt('prayer_alert_${prayer.key}', 1);
                        ref.invalidate(sharedPreferencesProvider);
                      },
                    ),
                    if (prayer.isPrayer) ...[
                      const SizedBox(width: 8),
                      _buildAlertOption(
                        context,
                        theme,
                        icon: Icons.notifications_active,
                        label: 'أذان',
                        isSelected: currentAlert == 2,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await prefs.setInt('prayer_alert_${prayer.key}', 2);
                          ref.invalidate(sharedPreferencesProvider);
                        },
                      ),
                    ],
                  ],
                ),
                
                // Prayer Name
                ArabicText(
                  prayer.title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertOption(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.disabledColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : theme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ArabicText(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerNotificationData {
  final String title;
  final String key;
  final bool isPrayer;

  _PrayerNotificationData(this.title, this.key, {this.isPrayer = true});
}
