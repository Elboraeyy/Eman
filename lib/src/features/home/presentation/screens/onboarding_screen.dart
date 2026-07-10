import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/shared_preferences_provider.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "بدء رحلتك بثقة... زاد مسلم",
      description: "تطبيق يساعدك على الثبات على الطاعة، وتنظيم عبادتك بسهولة ويسر دون عناء.",
      icon: Icons.verified_user_outlined,
    ),
    OnboardingPageData(
      title: "عبادتك... في وقتها",
      description: "مواقيت صلاة دقيقة تعتمد على موقعك الجغرافي، مع تنبيهات مخصصة وذكر دائم.",
      icon: Icons.access_time,
    ),
    OnboardingPageData(
      title: "طُمأنينة قلبك",
      description: "أذكار متنوعة حصن للمسلم، وقرآن كريم بتلاوات وتفاسير متكاملة تبقي قلبك متصلاً بالله.",
      icon: Icons.spa_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: ArabicText(
              'تخطي',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration frame
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Center(
                          child: Icon(
                            page.icon,
                            size: 110,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 48),
                      
                      ArabicText(
                        page.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      ArabicText(
                        page.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          height: 1.6,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                      ).animate().fade(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Bottom controls
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: Column(
              children: [
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isSelected = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8,
                      width: isSelected ? 24 : 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 32),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: ArabicText(
                      isLastPage ? 'استكشف الآن' : 'التالي',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
