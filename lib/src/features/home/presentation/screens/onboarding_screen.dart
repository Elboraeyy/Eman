import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/database/shared_preferences_provider.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/core/widgets/surah_name_frame.dart';
import 'package:iman/src/features/home/presentation/screens/home_screen.dart'
    show IslamicPatternPainter;

/// شاشة الأونبوردينج — امتداد مباشر لزَين الـ Splash والهوم:
/// خلفية كريمي دافية (FAF8F5) + توهّج نبيتي ناعم + نقش النجمة الثمانية
/// (نفس [IslamicPatternPainter] المستخدم في هيدر الهوم) + أصول حقيقية
/// من التطبيق (اللوغو، فريم اسم السورة، البسملة) لعرض الخصائص في مشاهد
/// مصغّرة (Mini UI) تحكي لغة التطبيق نفسها.
///
/// ملاحظة هندسية: عناصر الصفحات مبتعملش setState خالص — المؤشرات والأزرار
/// بتتحدث من [AnimatedBuilder] نفس [_pageController]، فالكارت بيتبنى مرة واحدة
/// بس لما يدخل الشاشة، وبتالي أنيميشن الدخول بيتكرر كل مرة ترجعلها صفحة.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _completing = false;

  int _current(int value) {
    if (!_pageController.hasClients) return 0;
    final page = _pageController.page;
    if (page == null) return 0;
    return page.round().clamp(0, value);
  }

  Future<void> _completeOnboarding() async {
    if (_completing) return;
    _completing = true;
    HapticFeedback.lightImpact();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.textTheme.bodyMedium?.color ?? const Color(0xFF7D5852);
    final burgundy = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5), // نفس خلفية الـ Splash
        body: Stack(
          children: [
            // ===================== الخلفية =====================
            // توهّج نبيتي ناعم فوق (مطابق تمامًا لواحد الـ Splash)
            Positioned(
              top: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: burgundy.withValues(alpha: 0.04),
                ),
              ),
            ),
            // توهّج جولدي هادي في أسفل الشاشة
            PositionedDirectional(
              bottom: -90,
              start: -50,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withValues(alpha: 0.07),
                ),
              ),
            ),
            // نقش النجمة الثمانية — نفس رسم الهوم، بدرجة خفيفة مع تدرّج اختفاء
            PositionedDirectional(
              top: -40,
              start: 0,
              end: 0,
              height: MediaQuery.of(context).size.height * 0.52,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.62, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: CustomPaint(
                  painter: IslamicPatternPainter(
                    color: burgundy.withValues(alpha: 0.035),
                  ),
                ),
              ),
            ),

            // ===================== المحتوى =====================
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // شريط علوي: زر رجوع (يظهر من الصفحة التانية) + تخطي
                  _HeaderBar(
                    controller: _pageController,
                    currentIndex: () => _current(_pages.length - 1),
                    onBack: () {
                      HapticFeedback.selectionClick();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    onSkip: _completeOnboarding,
                  ),
                  // صفحات الأونبوردينج
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (_) => HapticFeedback.selectionClick(),
                      itemBuilder: (context, index) => _buildPage(
                        context,
                        theme,
                        index,
                        bodyColor: bodyColor,
                      ),
                    ),
                  ),
                  // المؤشرات + زر الصفحة التالية
                  _FooterControls(
                    controller: _pageController,
                    pageCount: _pages.length,
                    currentIndex: () => _current(_pages.length - 1),
                    onNext: () {
                      HapticFeedback.selectionClick();
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    onFinish: _completeOnboarding,
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== بناء الصفحة =====================
  Widget _buildPage(
    BuildContext context,
    ThemeData theme,
    int index, {
    required Color bodyColor,
  }) {
    final page = _pages[index];
    final artHeight = (MediaQuery.of(context).size.height * 0.32)
        .clamp(210.0, 250.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الرسم التوضيحي — دخول حركي + طفو خفيف مستمر
          // (FittedBox يصغّر المشهد تلقائيًا عشان ما يفيضش على الشاشات القصيرة)
          (floatLoop(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildArt(index, theme, bodyColor: bodyColor),
            ),
          ))
              .animate(delay: 80.ms)
              .fade(duration: 560.ms, curve: Curves.easeOutCubic)
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                duration: 640.ms,
                curve: Curves.easeOutBack,
              ),
          SizedBox(height: artHeight < 230 ? 26 : 36),
          // العنوان
          ArabicText(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 24,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          )
              .animate(delay: 180.ms)
              .fade(duration: 520.ms, curve: Curves.easeOutCubic)
              .slideY(
                begin: 0.25,
                end: 0,
                duration: 520.ms,
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 12),
          // الوصف
          ArabicText(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 15,
              height: 1.7,
              color: bodyColor.withValues(alpha: 0.9),
            ),
          )
              .animate(delay: 280.ms)
              .fade(duration: 520.ms, curve: Curves.easeOutCubic)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 520.ms,
                curve: Curves.easeOutCubic,
              ),
        ],
      ),
    );
  }

  // ===================== رسومات الصفحات =====================
  Widget _buildArt(
    int index,
    ThemeData theme, {
    required Color bodyColor,
  }) {
    switch (index) {
      case 0:
        return _WelcomeArt(
          burgundy: theme.colorScheme.primary,
          gold: theme.colorScheme.secondary,
        );
      case 1:
        return _SalahArt(
          burgundy: theme.colorScheme.primary,
          gold: theme.colorScheme.secondary,
          ink: theme.colorScheme.onSurface,
          body: bodyColor,
        );
      case 2:
        return _MushafArt(
          burgundy: theme.colorScheme.primary,
          gold: theme.colorScheme.secondary,
          ink: theme.colorScheme.onSurface,
          body: bodyColor,
        );
      default:
        return _WirdArt(
          burgundy: theme.colorScheme.primary,
          gold: theme.colorScheme.secondary,
          ink: theme.colorScheme.onSurface,
          body: bodyColor,
        );
    }
  }
}

// ===================================================================
// بيانات الصفحات
// ===================================================================
class _OnbPage {
  final String title;
  final String description;
  const _OnbPage(this.title, this.description);
}

const List<_OnbPage> _pages = [
  _OnbPage(
    'أهلًا بك في «إيمان»',
    'رفيقك اليومي إلى الثبات على طاعة الله؛ ينظّم وردك، ويرافقك في مصحفك وصلاتك وذكرك.',
  ),
  _OnbPage(
    'صلاتك في موعدها',
    'مواقيت دقيقة تعتمد على موقعك تلقائيًا، مع اتجاه القبلة بدقة، وتنبيهات لطيفة لا تُفوتك صلاة.',
  ),
  _OnbPage(
    'نورٌ بكل صفحة',
    'مصحف واضح بتلاواته وتفاسيره، وأذكار ومسبحة إلكترونية.. ليظل قلبك دائمًا في ذكر الله.',
  ),
  _OnbPage(
    'وردك اليومي في متناول يدك',
    'خطة يومية بسيطة لترسيخ عاداتك، وإحصائيات واضحة تُريك تقدمك.. فتثبت على الطاعة يومًا بعد يوم.',
  ),
];

// ===================================================================
// طفو خفيف مستمر (حركة ناعمة للي فوق وللتحت بدون ما تلاقي نفسها)
// ===================================================================
Widget floatLoop({required Widget child}) {
  return child
      .animate(onPlay: (controller) => controller.repeat(reverse: true))
      .moveY(
        begin: -4,
        end: 4,
        duration: 2400.ms,
        curve: Curves.easeInOut,
      );
}

// ===================================================================
// شريط علوي: رجوع + تخطي (يتبني كل سكرول بس المحتوى مش بيتأثر)
// ===================================================================
class _HeaderBar extends StatelessWidget {
  final PageController controller;
  final int Function() currentIndex;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _HeaderBar({
    required this.controller,
    required this.currentIndex,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.textTheme.bodyMedium?.color ?? const Color(0xFF7D5852);
    final burgundy = theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final index = currentIndex();
        final showBack = index > 0;
        final showSkip = index < 3;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              // (في RTL أول عنصر = يمين الشاشة) زر الرجوع
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: showBack ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !showBack,
                  child: GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: bodyColor.withValues(alpha: 0.12)),
                      ),
                      child: Icon(
                        // في الـ RTL زر الرجوع بيشاور يمين
                        LucideIcons.chevronRight,
                        size: 18,
                        color: burgundy,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // زر التخطي
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: showSkip ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !showSkip,
                  child: GestureDetector(
                    onTap: onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: bodyColor.withValues(alpha: 0.12)),
                      ),
                      child: ArabicText(
                        'تخطي',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: bodyColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===================================================================
// المؤشرات + زر «التالي / ابدأ رحلتك»
// ===================================================================
class _FooterControls extends StatelessWidget {
  final PageController controller;
  final int pageCount;
  final int Function() currentIndex;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _FooterControls({
    required this.controller,
    required this.pageCount,
    required this.currentIndex,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final burgundy = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final index = currentIndex();
        final isLast = index == pageCount - 1;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // نقاط المؤشر — نقط الجولد للصفحات الجاية، نقط نبيتي للنشطة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pageCount, (i) {
                  final active = i == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 26 : 8,
                    decoration: BoxDecoration(
                      color: active
                          ? burgundy
                          : gold.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 26),
              // زر الإجراء الرئيسي — نفس ستايل الثيم (Stadium + نبيتي)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLast ? onFinish : onNext,
                  style: ElevatedButton.styleFrom(
                    elevation: isLast ? 8 : 0,
                    shadowColor: burgundy.withValues(alpha: 0.35),
                    backgroundColor: burgundy,
                    foregroundColor: Colors.white,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Row(
                      key: ValueKey(isLast),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLast) ...[
                          const Icon(
                            LucideIcons.sparkles,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                        ],
                        ArabicText(
                          isLast ? 'ابدأ رحلتك' : 'التالي',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===================================================================
// عناصر مشتركة للمشاهد (Mini UI)
// ===================================================================

/// كارت مشهد أبيض — نفس لغة كروت التطبيق (حواف ناعمة + بردر شعري + ظل نبيتي)
class _SceneCard extends StatelessWidget {
  final Widget child;
  final double width;
  const _SceneCard({required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.textTheme.bodyMedium?.color ?? const Color(0xFF7D5852);

    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: bodyColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.07),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// شيب دائري صغير للمشاهد (يميل/يطفو حوالين الكارت الرئيسي)
class _OrbitChip extends StatelessWidget {
  final Widget child;
  final double size;
  final Color background;
  final Border? border;

  const _OrbitChip({
    required this.child,
    required this.size,
    required this.background,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

/// شريط تقدم مصغر — بيبدأ من اليمين (RTL) زي باقي التطبيق
class _MiniProgressBar extends StatelessWidget {
  final double pct;
  final Color fill;
  final Color track;
  const _MiniProgressBar({
    required this.pct,
    required this.fill,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: pct.clamp(0.0, 1.0),
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نجمة ثمانية — نفس هندسة نقش الهوم لكن نجمة واحدة معزولة (زخرفة)
class _StarPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _StarPainter(this.color, {this.strokeWidth = 1.2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;

    // مربع 1
    final square = Path()
      ..moveTo(center.dx + radius, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy - radius)
      ..close();
    // مربع 2 (بتدوير 45°)
    final diag = radius * 1.414;
    final diamond = Path()
      ..moveTo(center.dx + diag, center.dy)
      ..lineTo(center.dx, center.dy + diag)
      ..lineTo(center.dx - diag, center.dy)
      ..lineTo(center.dx, center.dy - diag)
      ..close();

    canvas.drawPath(square, paint);
    canvas.drawPath(diamond, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// مسبحة مصغّرة مرسومة — خرز جولد على وتر بسيط
class _BeadsPainter extends CustomPainter {
  final Color bead;
  final Color accent;
  final Color string;
  const _BeadsPainter({
    required this.bead,
    required this.accent,
    required this.string,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // الوتر (قوس 3/4)
    final stringPaint = Paint()
      ..color = string
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.65,
      4.15,
      false,
      stringPaint,
    );

    // الخرز موزّع على القوس — آخر خرزة (الفعلة) نفسها أكبر وبالنبيتي
    const count = 7;
    final startAngle = -0.65;
    final sweep = 4.15;
    final beadRadius = size.width * 0.055;
    final beadsPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = bead;
    final accentPaint = Paint()..style = PaintingStyle.fill..color = accent;

    for (var i = 0; i < count; i++) {
      final angle = startAngle + sweep * i / (count - 1);
      // خرزة فوق الوتر نفسه بقليل
      final pos = center + Offset.fromDirection(angle, radius * 0.96);
      final paint = i == count - 1 ? accentPaint : beadsPaint;
      canvas.drawCircle(
        pos,
        i == count - 1 ? beadRadius * 1.25 : beadRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BeadsPainter oldDelegate) =>
      oldDelegate.bead != bead;
}

// ===================================================================
// مشهد ١ — اللوغو والشعار (امتداد مباشر للـ Splash)
// ===================================================================
class _WelcomeArt extends StatelessWidget {
  final Color burgundy;
  final Color gold;
  const _WelcomeArt({required this.burgundy, required this.gold});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // نجمة خلفية هادية
              IgnorePointer(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _StarPainter(
                      gold.withValues(alpha: 0.22),
                      strokeWidth: 1.1,
                    ),
                  ),
                ),
              ),
              // نقط جولد زخرفية
              PositionedDirectional(
                top: 4,
                start: 30,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gold.withValues(alpha: 0.5),
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 8,
                end: 24,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: burgundy.withValues(alpha: 0.3),
                  ),
                ),
              ),
              // اللوغو — نفس حاوية الـ Splash بالظبط (20% أصغر)
              Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: burgundy.withValues(alpha: 0.06),
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
              ),
            ],
          ),
          const SizedBox(height: 18),
          // نفس الشعار التسويقي بتاع الـ Splash — استمرارية بصرية مباشرة
          ArabicText(
            'إِيـمَــــــــانٌ يَـزْدَاد .. وَطَـاعَــــــــةٌ تُـثْـمِـر',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: burgundy,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// مشهد ٢ — مواقيت الصلاة والقبلة
// ===================================================================
class _SalahArt extends StatelessWidget {
  final Color burgundy;
  final Color gold;
  final Color ink;
  final Color body;
  const _SalahArt({
    required this.burgundy,
    required this.gold,
    required this.ink,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // نجمة زخرفية خلفية
          PositionedDirectional(
            top: -12,
            end: 2,
            child: IgnorePointer(
              child: SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _StarPainter(gold.withValues(alpha: 0.16)),
                ),
              ),
            ),
          ),
          // كارت «الصلاة القادمة» بصيغة المصغّر
          _SceneCard(
            width: 214,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: burgundy.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ArabicText(
                    'الصلاة القادمة',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: burgundy,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ArabicText(
                      'العشاء',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const Spacer(),
                    ArabicText(
                      '7:42 م',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MiniProgressBar(
                  pct: 0.68,
                  fill: burgundy,
                  track: ink.withValues(alpha: 0.07),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(LucideIcons.alarmClock, size: 12, color: burgundy),
                    const SizedBox(width: 6),
                    ArabicText(
                      'بعد 3 ساعات و 42 د',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: body.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // شيب القبلة (جولد)
          PositionedDirectional(
            top: -8,
            start: -10,
            child: _OrbitChip(
              size: 46,
              background: gold.withValues(alpha: 0.16),
              child: Icon(LucideIcons.compass, size: 20, color: gold),
            ),
          ),
          // شيب تحديد الموقع
          PositionedDirectional(
            bottom: 10,
            end: -12,
            child: _OrbitChip(
              size: 44,
              background: Colors.white,
              border: Border.all(color: body.withValues(alpha: 0.12)),
              child: Icon(Icons.gps_fixed, size: 18, color: burgundy),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// مشهد ٣ — المصحف والتلاوة والمسبحة (بأصول التطبيق الحقيقية)
// ===================================================================
class _MushafArt extends StatelessWidget {
  final Color burgundy;
  final Color gold;
  final Color ink;
  final Color body;
  const _MushafArt({
    required this.burgundy,
    required this.gold,
    required this.ink,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // نجمة زخرفية خلفية
          PositionedDirectional(
            bottom: -2,
            start: -6,
            child: IgnorePointer(
              child: SizedBox(
                width: 95,
                height: 95,
                child: CustomPaint(
                  painter: _StarPainter(gold.withValues(alpha: 0.14)),
                ),
              ),
            ),
          ),
          _SceneCard(
            width: 224,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // فريم «الفاتحة» الحقيقي بتاع التطبيق — نفس واجهة المصحف
                SurahNameFrame(
                  surahName: 'الفاتحة',
                  surahNumber: 1,
                  width: 190,
                ),
                const SizedBox(height: 10),
                // البسملة الحقيقية (نفس أصول المصحف) في وسط الصفحة
                Image.asset(
                  'assets/images/basmala_new.png',
                  width: 130,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                // أسطر مصحف تجريدية (نص مُركّز في الوسط زي المصحف)
                _mushafLine(0.95, ink),
                const SizedBox(height: 8),
                _mushafLine(0.8, ink),
                const SizedBox(height: 8),
                _mushafLine(0.6, ink),
              ],
            ),
          ),
          // علامة مرجعية جولد طالعة من راس الكارت (بتاعة المصحف)
          PositionedDirectional(
            top: -6,
            start: 30,
            child: Container(
              width: 16,
              height: 34,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
            ),
          ),
          // شيب القراءة (نبيتي)
          PositionedDirectional(
            bottom: 14,
            start: -14,
            child: _OrbitChip(
              size: 46,
              background: burgundy.withValues(alpha: 0.08),
              child: Icon(LucideIcons.bookOpen, size: 20, color: burgundy),
            ),
          ),
          // شيب التلاوة (أبيض بإطار)
          PositionedDirectional(
            bottom: 16,
            end: -12,
            child: _OrbitChip(
              size: 46,
              background: Colors.white,
              border: Border.all(color: body.withValues(alpha: 0.12)),
              child: Icon(Icons.headphones_outlined, size: 20, color: gold),
            ),
          ),
          // خرزة المسبحة المرسومة (جولد)
          PositionedDirectional(
            top: -8,
            end: -10,
            child: _OrbitChip(
              size: 44,
              background: gold.withValues(alpha: 0.16),
              child: SizedBox(
                width: 34,
                height: 34,
                child: CustomPaint(
                  painter: _BeadsPainter(
                    bead: gold,
                    accent: burgundy,
                    string: gold.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mushafLine(double factor, Color color) {
    return Align(
      alignment: Alignment.topCenter,
      child: FractionallySizedBox(
        widthFactor: factor,
        child: Container(
          height: 7,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// مشهد ٤ — الورد اليومي والمهام والإحصائيات
// ===================================================================
class _WirdArt extends StatelessWidget {
  final Color burgundy;
  final Color gold;
  final Color ink;
  final Color body;
  const _WirdArt({
    required this.burgundy,
    required this.gold,
    required this.ink,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // نجمة زخرفية خلفية
          PositionedDirectional(
            top: -14,
            start: -2,
            child: IgnorePointer(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _StarPainter(gold.withValues(alpha: 0.15)),
                ),
              ),
            ),
          ),
          _SceneCard(
            width: 226,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان + شلسلة الثبات (Streak)
                Row(
                  children: [
                    ArabicText(
                      'وِردي اليوم',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.flame, size: 11, color: gold),
                          const SizedBox(width: 4),
                          ArabicText(
                            '9 أيام',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: ink.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // المهام
                _taskRow('ورد القرآن', true, ink, burgundy, body),
                const SizedBox(height: 10),
                _taskRow('أذكار المساء', true, ink, burgundy, body),
                const SizedBox(height: 10),
                _taskRow('سُنّة الفجر', false, ink, burgundy, body),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: body.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ArabicText(
                      'إنجاز اليوم',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: body,
                      ),
                    ),
                    const Spacer(),
                    ArabicText(
                      '70%',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: burgundy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _MiniProgressBar(
                  pct: 0.7,
                  fill: burgundy,
                  track: ink.withValues(alpha: 0.07),
                ),
              ],
            ),
          ),
          // شيب الإحصائيات (أبيض بإطار)
          PositionedDirectional(
            top: -6,
            end: -10,
            child: _OrbitChip(
              size: 46,
              background: Colors.white,
              border: Border.all(color: body.withValues(alpha: 0.12)),
              child: Icon(Icons.bar_chart_outlined, size: 20, color: burgundy),
            ),
          ),
          // شيب التمام (جولد)
          PositionedDirectional(
            bottom: 16,
            start: -12,
            child: _OrbitChip(
              size: 46,
              background: gold.withValues(alpha: 0.16),
              child: Icon(LucideIcons.calendarCheck, size: 20, color: gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(
    String title,
    bool done,
    Color ink,
    Color burgundy,
    Color body,
  ) {
    return Row(
      children: [
        done
            ? Icon(Icons.check_circle, size: 18, color: burgundy)
            : Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: body.withValues(alpha: 0.35),
                    width: 1.4,
                  ),
                ),
              ),
        const SizedBox(width: 10),
        ArabicText(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: done ? FontWeight.w700 : FontWeight.w600,
            color: done ? ink.withValues(alpha: 0.9) : body,
          ),
        ),
      ],
    );
  }
}
