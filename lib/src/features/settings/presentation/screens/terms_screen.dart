import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'الشروط والأحكام',
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
              title: 'قبول الشروط',
              body:
                  'باستخدامك تطبيق «إيمان» فأنت توافق على الشروط المذكورة في هذه الصفحة. إن لم توافق عليها فلا تستخدم التطبيق، وقد نُحدِّث هذه الشروط من وقتٍ لآخر مع تطوّره.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'ترخيص الاستخدام',
              body:
                  'نمنحك ترخيصًا مجانيًا شخصيًا وغير حصري لاستخدام التطبيق على أجهزتك لأغراض دينية وشخصية. ويُمنع نسخه أو تعديله أو بيعه أو إعادة نشره باسم آخر، أو استخدامه في أي نشاط غير مشروع.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'المحتوى ومصادره',
              body:
                  'يتيح التطبيق نصوص القرآن الكريم والأحاديث والأذكار من مصادر معتمدة ومعروفة، إضافةً إلى تلاوات لعدد من القرّاء. القرآن الكريم نصٌّ مقدس، ونتعامل مع كل آية فيه بحرص شديد عند نقلها وعرضها.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'مواقيت الصلاة والقبلة',
              body:
                  'تُحسب مواقيت الصلاة وفق طرقٍ معتمدة لدى هيئات إسلامية موثوقة، واتجاه القبلة يُحدَّد بواسطة بيانات الموقع والبوصلة. الحسابات تبقى تقديرية بطبيعتها، فننصحك دائمًا بمقارنتها بموعد الأذان أو التقويم الرسمي في مدينتك.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'إخلاء المسؤولية',
              body:
                  'يُقدَّم التطبيق كما هو، من غير أي ضمان صريح أو ضمني. ولا نتحمل مسؤولية أي ضرر أو خسارة تنتج عن قصورٍ في أدائه، أو عن الاعتماد على محتواه دون مراجعة مستقلة.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'الملكية الفكرية',
              body:
                  'واجهة التطبيق وتصميمه وتنظيم محتواه ملكٌ لمطوّر «إيمان»، ولا يجوز نسخهما أو استخدامهما تجاريًا دون إذن. أما النصوص المقدسة كالقرآن والسنة فهي متاحة للعموم، وقد عرضناها هنا لنشر الخير.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'حقوق المستخدم عبر أبل',
              body:
                  'عند تحميل التطبيق من «متجر تطبيقات آبل» (Apple App Store)، يُعدُّ هذا الترخيص شخصيًا وغير قابل للنقل، وتقتصر مسؤولية آبل على إتاحة التطبيق عبر متجرها فقط، وليس عن محتواه أو جودته أو نتائج استخدامه.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'تعديل الشروط وإنهاء الخدمة',
              body:
                  'قد نُحدِّث هذه الشروط من وقت لآخر، أو نوقف بعض خصائص التطبيق لأسباب تقنية. وكل تعديل على الشروط يُنشر في هذه الصفحة، ويُعدُّ استمرارك في استخدام التطبيق موافقةً عليه.',
            ),
            const SizedBox(height: 12),
            _Card(
              theme: theme,
              title: 'تواصل معنا',
              body:
                  'أي سؤال حول هذه الشروط؟ راسلنا على الدعم الفني عبر البريد الموجود في صفحة «تواصل معنا».',
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
  final String title;
  final String body;

  const _Card({required this.theme, required this.title, required this.body});

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
            ArabicText(
              title,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            ArabicText(
              body,
              style: GoogleFonts.cairo(
                fontSize: 13,
                height: 1.7,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
