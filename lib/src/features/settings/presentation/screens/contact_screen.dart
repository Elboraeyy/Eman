import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

/// البريد الرسمي للدعم — غيّره إلى بريدك الحقيقي قبل النشر
const String kSupportEmail = 'support@iman.app';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'تواصل معنا',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // علبة البريد
            Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: theme.dividerColor, width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mail_outline,
                          size: 34,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ArabicText(
                      'نحن سعداء بسماع منك',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ArabicText(
                      'ملاحظة؟ اقتراح؟ إبلاغ عن خطأ في تلاوةٍ أو نصٍّ؟ راسلنا وسنعاود الرد عليك في أقرب وقت.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.7,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // صندوق البريد
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ArabicText(
                                kSupportEmail,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: kSupportEmail));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: ArabicText(
                                    'تم نسخ بريد الدعم',
                                    style: GoogleFonts.cairo(fontSize: 13),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.copy,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            tooltip: 'نسخ',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // زر إرسال الملاحظة عبر المشاركة
            Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: theme.dividerColor, width: 0.8),
              ),
              child: ListTile(
                onTap: () {
                  SharePlus.instance.share(ShareParams(
                    text: 'سلام عليكم!\nأرغب في مشاركتكم ملاحظةً حول تطبيق إيمان: ',
                  ));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                title: ArabicText(
                  'إرسال ملاحظة سريعة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: ArabicText(
                  'شارك ملاحظتك عبر أي تطبيقٍ على جهازك',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ArabicText(
              'وفّقك الله لما تحبّه وترضاه',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
