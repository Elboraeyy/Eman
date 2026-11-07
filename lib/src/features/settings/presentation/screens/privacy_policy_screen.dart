import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'سياسة الخصوصية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Card(
              theme: theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArabicText(
                    'مبدأنا الأساسي: خصوصيتك محفوظة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Body(
                    theme,
                    'تطبيق «إيمان» لا يتطلب إنشاء حساب أو تسجيل دخول، ولا يجمع أي بيانات شخصية، ولا يحتفظ بأي بيانات على خوادمنا. جميع محتويات التطبيق (القرآن الكريم، الحديث، الأذكار) متاحة من داخل جهازك، وتُخزَّن تفضيلاتك الشخصية على جهازك فقط ولا يطّلع عليها أحد.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'البيانات المُخزَّنة على جهازك',
              items: const [
                'تفضيلاتك: القارئ الافتراضي، طريقة حساب المواقيت، إعدادات التنبيهات (تُخزَّن محليًا في ذاكرة الجهاز).',
                'محتواك المحفوظ: الآيات والأحاديث التي حفظتها في قائمة المفضلة.',
                'سجلك في التطبيق: جلسات التسميع والإنجازات والمتابعة اليومية.',
                'مواقيت الصلاة: تُخزَّن نسخة مؤقتة من مواقيت منطقتك لعرضها بدون إنترنت.',
              ],
              footer:
                  'بياناتك أعلاه تبقى على جهازك، ولا نبيعها ولا نشاركها مع أي طرف ثالث، وتُحذف نهائيًا من جهازك عند حذف التطبيق أو حذف بياناته.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'إذن الموقع الجغرافي',
              items: const [
                'نستخدم إذن «الموقع الدقيق» فقط لتحديد موقعك بدقة، وذلك لحساب توقيت الصلاة واتجاه القبلة.',
                'عند حساب المواقيت تُرسَل إحداثيات موقعك (خط الطول وخط العرض) إلى خدمة حساب المواقيت الموثوقة (Aladhan) وخدمة تحديد اسم المدينة (OpenStreetMap)، وهي خدمات من أطراف ثالثة معروفة.',
                'تُرسَل هذه الإحداثيات بهدف حساب المواقيت وتحديد اسم مدينتك فقط: نحن لا نخزن موقعك ولا نتابعه ولا نرسله إلى أي جهة أخرى، ولا نستخدمه لأي غرض تجاري.',
                'يمكنك رفض الإذن أو إلغاؤه في أي وقت من إعدادات جهازك، وفي هذه الحالة يمكنك إدخال موقعك يدويًا.',
              ],
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'الإشعارات والتنبيهات',
              items: const [
                'نستخدم إذن «الإشعارات» لإرسال تنبيهات الأذان وصلاة القيام والتذكيرات التي حددتَها بنفسك داخل التطبيق.',
                'لك أن تعطّل الإشعارات في أي وقت، من إعدادات التطبيق أو من إعدادات جهازك.',
              ],
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'الأذونات والمحتوى والتلاوات',
              items: const [
                'مصدر نصوص القرآن الكريم والأحاديث والأذكار هو قاعدة بيانات محلية مدمجة داخل التطبيق من مصادر موثوقة ومعروفة.',
                'تلاوات القرآن تُجلب من خدمات بث صوتي موثوقة عند تشغيلك للتلاوة فقط.',
              ],
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'الأطفال',
              footer:
                  'التطبيق مناسب لجميع الأعمار ولا يعرض إعلانات ولا يستهدف الأطفال بأي نشاط تجاري، ولا يجمع أي بيانات منهم، لذا لا نحتاج عادةً موافقة الوالدين.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'تعديلات على هذه السياسة',
              footer:
                  'قد نجدد هذه السياسة من وقت لآخر مع تطور التطبيق، وننشر النسخة المُحدَّثة في هذه الصفحة، ونُحدِّث تاريخ «آخر تحديث» في أسفلها. يعتبر استمرارك في استخدام التطبيق موافقةً على النسخة الجديدة.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'تواصل معنا',
              footer:
                  'لأي سؤال عن سياسة الخصوصية أو عن بياناتك، راسلنا عبر البريد الموجود في صفحة «تواصل معنا» داخل التطبيق.',
            ),
            const SizedBox(height: 28),
            ArabicText(
              'آخر تحديث: نوفمبر 2026',
              style: GoogleFonts.cairo(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final ThemeData theme;
  final String? title;
  final List<String>? items;
  final String? footer;
  final Widget? child;

  const _Card({
    required this.theme,
    this.title,
    this.items,
    this.footer,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              ArabicText(
                title!,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
            ],
            ?child,
            if (items != null)
              for (final item in items!) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Icon(
                        Icons.check_circle,
                        size: 14,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _Body(theme, item)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            if (footer != null) ...[
              if (items != null) const SizedBox(height: 4),
              _Body(theme, footer!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ThemeData theme;
  final String text;

  const _Body(this.theme, this.text);

  @override
  Widget build(BuildContext context) {
    return ArabicText(
      text,
      style: GoogleFonts.cairo(
        fontSize: 13,
        height: 1.7,
        color: theme.textTheme.bodyMedium?.color,
      ),
    );
  }
}
