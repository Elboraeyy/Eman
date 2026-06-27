import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'عن التطبيق',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: BorderSide(color: theme.dividerColor, width: 0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                  child: Column(
                    children: [
                      // Logo Frame
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.mosque,
                            size: 44,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'زاد مسلم',
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Text(
                        'الإصدار 1.0.0',
                        style: GoogleFonts.robotoMono(
                          fontSize: 14,
                          color: theme.disabledColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(),
                      ),
                      
                      Text(
                        'تطبيق إسلامي شامل صُمم خصيصاً لمرافقة المسلم في عباداته اليومية من خلال واجهة مستخدم حديثة ومتميزة، وأدوات متكاملة تدعم العمل بالكامل دون اتصال بالإنترنت.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.7,
                          color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms),
              
              const SizedBox(height: 48),
              
              Text(
                'تقبل الله منا ومنكم صالح الأعمال',
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
