import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/shared_preferences_provider.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

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
    Timer(const Duration(milliseconds: 2300), () {
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
    const bgColor = Color(0xFFFAF8F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient soft glow
          Positioned(
            top: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Center: Logo and Animated Slogan
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Modern Geometric Logo
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                .animate()
                .fade(duration: 900.ms, curve: Curves.easeOutCubic)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.0, 1.0),
                  duration: 900.ms,
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: 28),

                // Selected Slogan
                ArabicText(
                  'إِيـمَــــــــانٌ يَـزْدَاد .. وَطَـاعَــــــــةٌ تُـثْـمِـر',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                )
                .animate()
                .fade(delay: 350.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
