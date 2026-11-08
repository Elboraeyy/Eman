import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/shared_preferences_provider.dart';

import '../../../quran/presentation/controllers/audio_player_controller.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

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
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Section 2: Audio/Reciters & Quran
            _buildSectionHeader('القرآن الكريم والتلاوة', theme),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'المفضلة والآيات المحفوظة',
              subtitle: 'الآيات والأحاديث التي قمت بحفظها للرجوع إليها لاحقاً',
              icon: Icons.bookmark_border,
              route: '/settings/favorites',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildReciterCard(context, playbackState, ref, theme),

            const SizedBox(height: 28),

            // Section 3: Prayer settings
            _buildSectionHeader('مواقيت الصلاة والقبلة', theme),
            const SizedBox(height: 12),
            _buildCalculationMethodCard(context, activeMethodId, ref, theme),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'تنبيهات الصلاة والأذان',
              subtitle: 'تخصيص صوت الأذن والتنبيهات لكل صلاة على حدة',
              icon: Icons.notifications_active_outlined,
              route: '/settings/notifications',
              theme: theme,
              onTap: () => _showAlertsSheet(context, ref, theme),
            ),

            const SizedBox(height: 28),

            // Section 4: General Info
            _buildSectionHeader('عام ومعلومات', theme),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'عن التطبيق',
              subtitle: 'تعرف على تطبيق إيمان ورسالته وإصداره',
              icon: Icons.info_outline,
              route: '/settings/about',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'تواصل معنا',
              subtitle: 'راسلنا بملاحظتك أو اقتراحك أو إبلاغنا عن خطأ',
              icon: Icons.mail_outline,
              route: '/settings/contact',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context: context,
              title: 'شارك التطبيق',
              subtitle: 'انشر الخير وشارك التطبيق مع أهلك وأصحابك',
              icon: Icons.ios_share,
              theme: theme,
              onTap: () {
                SharePlus.instance.share(ShareParams(
                  text: 'حمِّل تطبيق «إيمان» 🕌\nمصحف وأذكار وأحاديث وتسميع ومواقيت الصلاة في تطبيقٍ واحد.\n',
                ));
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context: context,
              title: 'قيِّم التطبيق',
              subtitle: 'تقييمك يساعدنا على التحسين، ويشجع غيرك على نشر الخير',
              icon: Icons.star_border,
              theme: theme,
              onTap: () async {
                try {
                  // في المتجر: يفتح نافذة التقييم داخل التطبيق (بلا مغادرة)
                  await InAppReview.instance.requestReview();
                } catch (_) {
                  // احتياطي: لو مفيش متجر (بيلد تنصيب مباشر) نشارك الرابط
                  SharePlus.instance.share(ShareParams(
                    text: 'قيّم تطبيق «إيمان» ⭐\nرابط التطبيق:\nhttps://play.google.com/store/apps/details?id=com.elboraeyy.iman',
                  ));
                }
              },
            ),

            const SizedBox(height: 28),

            // Section 5: Legal & Policies
            _buildSectionHeader('الخصوصية والسياسات', theme),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'سياسة الخصوصية',
              subtitle: 'كيف نتعامل مع بياناتك وبماذا نحفظها',
              icon: Icons.privacy_tip_outlined,
              route: '/settings/privacy',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context: context,
              title: 'الشروط والأحكام',
              subtitle: 'شروط استخدامك لتطبيق «إيمان»',
              icon: Icons.gavel_outlined,
              route: '/settings/terms',
              theme: theme,
            ),

            const SizedBox(height: 40),
            
            // App Version Info
            Center(
              child: Column(
                children: [
                  ArabicText(
                    'تطبيق إيمان',
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



  Widget _buildReciterCard(BuildContext context, AudioPlaybackState playbackState, WidgetRef ref, ThemeData theme) {
    final activeReciterId = staticReciters.any((r) => r.id == playbackState.activeReciterId)
        ? playbackState.activeReciterId
        : 'yasser_al_dossari';
    final activeReciter = staticReciters.firstWhere(
      (r) => r.id == activeReciterId,
      orElse: () => staticReciters.first,
    );

    return _buildPickerCard(
      context: context,
      theme: theme,
      icon: Icons.mic,
      title: 'القارئ الافتراضي',
      value: activeReciter.nameArabic,
      onTap: () => _showSelectionSheet(
        context: context,
        theme: theme,
        title: 'اختر القارئ الافتراضي',
        optionLabels: staticReciters.map((r) => r.nameArabic).toList(),
        activeIndex: staticReciters.indexWhere((r) => r.id == activeReciterId),
        onSelected: (index) {
          ref.read(audioPlayerProvider.notifier).changeReciter(staticReciters[index].id);
        },
      ),
    );
  }

  Widget _buildCalculationMethodCard(BuildContext context, int activeId, WidgetRef ref, ThemeData theme) {
    final activeMethod = calculationMethods.firstWhere((m) => m.id == activeId, orElse: () => calculationMethods.first);

    return _buildPickerCard(
      context: context,
      theme: theme,
      icon: Icons.calculate_outlined,
      title: 'طريقة الحساب',
      value: activeMethod.name,
      onTap: () => _showSelectionSheet(
        context: context,
        theme: theme,
        title: 'اختر طريقة الحساب',
        optionLabels: calculationMethods.map((m) => m.name).toList(),
        activeIndex: calculationMethods.indexWhere((m) => m.id == activeId),
        onSelected: (index) async {
          final prefs = ref.read(sharedPreferencesProvider);
          await prefs.setInt('prayer_calculation_method', calculationMethods[index].id);
          ref.invalidate(todayPrayerTimesProvider);
        },
      ),
    );
  }

  Widget _buildPickerCard({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
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
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    ArabicText(
                      value,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectionSheet({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required List<String> optionLabels,
    required int activeIndex,
    required ValueChanged<int> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true, // يظهر فوق شريط التنقل السفلي وليس تحته
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ArabicText(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(sheetContext).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(sheetContext).padding.bottom + 20),
                    child: Column(
                      children: [
                        for (var i = 0; i < optionLabels.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  onSelected(i);
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: i == activeIndex
                                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                        : null,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: i == activeIndex
                                          ? theme.colorScheme.primary
                                          : theme.dividerColor,
                                      width: i == activeIndex ? 1.2 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ArabicText(
                                          optionLabels[i],
                                          style: GoogleFonts.cairo(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: i == activeIndex ? theme.colorScheme.primary : null,
                                          ),
                                        ),
                                      ),
                                      if (i == activeIndex)
                                        Icon(
                                          Icons.check_circle,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
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
                Icons.open_in_new,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAlertsSheet(BuildContext context, WidgetRef ref, ThemeData theme) {
    const prayers = [
      ('صلاة الفجر', 'fajr', true),
      ('شروق الشمس', 'sunrise', false),
      ('صلاة الظهر', 'dhuhr', true),
      ('صلاة العصر', 'asr', true),
      ('صلاة المغرب', 'maghrib', true),
      ('صلاة العشاء', 'isha', true),
    ];

    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Consumer(
            builder: (context, sheetRef, _) {
              final prefs = sheetRef.watch(sharedPreferencesProvider);
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: ArabicText(
                              'تنبيهات الصلاة والأذان',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(sheetContext).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(sheetContext).padding.bottom + 20),
                        child: Column(
                          children: [
                            for (final prayer in prayers)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: theme.dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ArabicText(
                                          prayer.$1,
                                          style: GoogleFonts.cairo(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      _buildAlertChip(sheetContext, theme,
                                        icon: Icons.notifications_off,
                                        label: 'صامت',
                                        selected: (prefs.getInt('prayer_alert_${prayer.$2}') ?? (prayer.$3 ? 1 : 0)) == 0,
                                        onTap: () {
                                          prefs.setInt('prayer_alert_${prayer.$2}', 0);
                                          sheetRef.invalidate(sharedPreferencesProvider);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      _buildAlertChip(sheetContext, theme,
                                        icon: Icons.notifications,
                                        label: 'رنين',
                                        selected: (prefs.getInt('prayer_alert_${prayer.$2}') ?? (prayer.$3 ? 1 : 0)) == 1,
                                        onTap: () {
                                          prefs.setInt('prayer_alert_${prayer.$2}', 1);
                                          sheetRef.invalidate(sharedPreferencesProvider);
                                        },
                                      ),
                                      if (prayer.$3) ...[
                                        const SizedBox(width: 8),
                                        _buildAlertChip(sheetContext, theme,
                                          icon: Icons.notifications_active,
                                          label: 'أذان',
                                          selected: (prefs.getInt('prayer_alert_${prayer.$2}') ?? 1) == 2,
                                          onTap: () {
                                            prefs.setInt('prayer_alert_${prayer.$2}', 2);
                                            sheetRef.invalidate(sharedPreferencesProvider);
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAlertChip(BuildContext context, ThemeData theme, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final activeColor = theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? activeColor : theme.dividerColor,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            ArabicText(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? activeColor : theme.disabledColor,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              icon,
              size: 13,
              color: selected ? activeColor : theme.disabledColor,
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
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push(route),
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
