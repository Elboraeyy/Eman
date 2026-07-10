import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/shared_preferences_provider.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      final prefs = ref.read(sharedPreferencesProvider);
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (onboardingCompleted) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft gradient matching app palette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Center logo & texts
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo frame
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mosque,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
                .animate()
                .fade(duration: 1200.ms, curve: Curves.fastOutSlowIn)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 1200.ms, curve: Curves.fastOutSlowIn),
                
                const SizedBox(height: 32),
                
                // App Title
                ArabicText(
                  'زاد مسلم',
                  style: GoogleFonts.amiri(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                )
                .animate()
                .fade(delay: 300.ms, duration: 1000.ms),
                
                const SizedBox(height: 8),
                
                // Tagline
                ArabicText(
                  'الدليل الإسلامي الشامل',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                )
                .animate()
                .fade(delay: 600.ms, duration: 1000.ms),
              ],
            ),
          ),
          
          // Bottom loading indicator
          Positioned(
            bottom: 64,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          )
          .animate()
          .fade(delay: 800.ms, duration: 600.ms),
        ],
      ),
    );
  }
}
