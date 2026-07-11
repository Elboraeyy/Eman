import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/shared_preferences_provider.dart';

import '../../../quran/presentation/controllers/audio_player_controller.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

// Prayer Calculation Method Model
class CalculationMethod {
  final int id;
  final String name;

  const CalculationMethod(this.id, this.name);
}

const List<CalculationMethod> calculationMethods = [
  CalculationMethod(1, 'جامعة العلوم الإسلامية بكراتشي'),
  CalculationMethod(2, 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)'),
  CalculationMethod(3, 'رابطة العالم الإسلامي'),
  CalculationMethod(4, 'جامعة أم القرى، مكة المكرمة'),
  CalculationMethod(5, 'الهيئة المصرية العامة للمساحة'),
  CalculationMethod(7, 'معهد الجيوفيزياء بجامعة طهران'),
  CalculationMethod(8, 'منطقة الخليج العربي'),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playbackState = ref.watch(audioPlayerProvider);
    
    // Load active calculation method from SharedPreferences
    final prefs = ref.watch(sharedPreferencesProvider);
    final activeMethodId = prefs.getInt('prayer_calculation_method') ?? 5; // Default to Egyptian Authority (5)

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'الإعدادات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Section 2: Audio/Reciters & Quran
            _buildSectionHeader('القرآن الكريم والتلاوة', theme),
            const SizedBox(height: 12),
            _buildReciterCard(playbackState, ref, theme),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'المفضلة والآيات المحفوظة',
              subtitle: 'الآيات والأحاديث التي قمت بحفظها للرجوع إليها لاحقاً',
              icon: Icons.bookmark_border,
              route: '/settings/favorites',
              theme: theme,
            ),

            const SizedBox(height: 28),

            // Section 3: Prayer settings
            _buildSectionHeader('مواقيت الصلاة والقبلة', theme),
            const SizedBox(height: 12),
            _buildCalculationMethodCard(activeMethodId, ref, theme),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'تنبيهات الصلاة والأذان',
              subtitle: 'تخصيص صوت الأذن والتنبيهات لكل صلاة على حدة',
              icon: Icons.notifications_active_outlined,
              route: '/settings/notifications',
              theme: theme,
            ),

            const SizedBox(height: 28),

            // Section 4: General Info
            _buildSectionHeader('عام ومعلومات', theme),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'عن التطبيق',
              subtitle: 'تعرف على تطبيق زاد المسلم ورسالته وإصداره',
              icon: Icons.info_outline,
              route: '/settings/about',
              theme: theme,
            ),

            const SizedBox(height: 40),
            
            // App Version Info
            Center(
              child: Column(
                children: [
                  ArabicText(
                    'تطبيق زاد المسلم',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ArabicText(
                    'الإصدار 1.0.0',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return ArabicText(
      title,
      style: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }



  Widget _buildReciterCard(AudioPlaybackState playbackState, WidgetRef ref, ThemeData theme) {
    final activeReciterId = staticReciters.any((r) => r.id == playbackState.activeReciterId)
        ? playbackState.activeReciterId
        : 'yasser_al_dossari';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArabicText(
                    'القارئ الافتراضي',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  ArabicText(
                    'سيتم استخدامه في تلاوة الآيات والسور',
                    style: GoogleFonts.cairo(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              value: activeReciterId,
              dropdownColor: theme.colorScheme.surface,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
              onChanged: (id) {
                if (id != null) {
                  ref.read(audioPlayerProvider.notifier).changeReciter(id);
                }
              },
              items: staticReciters.map((reciter) {
                return DropdownMenuItem<String>(
                  value: reciter.id,
                  child: ArabicText(
                    reciter.nameArabic,
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationMethodCard(int activeId, WidgetRef ref, ThemeData theme) {
    final activeMethod = calculationMethods.firstWhere((m) => m.id == activeId, orElse: () => calculationMethods.first);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArabicText(
                        'طريقة الحساب',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      ArabicText(
                        'المعادلة المستخدمة لحساب مواقيت الصلاة',
                        style: GoogleFonts.cairo(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ),
                DropdownButton<CalculationMethod>(
                  value: activeMethod,
                  dropdownColor: theme.colorScheme.surface,
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                  onChanged: (method) async {
                    if (method != null) {
                      final prefs = ref.read(sharedPreferencesProvider);
                      await prefs.setInt('prayer_calculation_method', method.id);
                      
                      // Invalidate prayer times provider so home screen dynamically fetches with new method!
                      ref.invalidate(todayPrayerTimesProvider);
                    }
                  },
                  items: calculationMethods.map((method) {
                    return DropdownMenuItem<CalculationMethod>(
                      value: method,
                      child: ArabicText(
                        method.name,
                        style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ArabicText(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios
                    : Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
