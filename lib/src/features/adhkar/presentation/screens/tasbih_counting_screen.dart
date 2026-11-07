import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/adhkar_repository_provider.dart';
import '../../domain/entities/adhkar_entities.dart';
import 'tasbih_list_screen.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/features/tracker/data/repositories/tracker_repository_provider.dart';

final singleTasbihProvider = FutureProvider.family<Tasbih?, int>((ref, id) async {
  final repo = ref.watch(adhkarRepositoryProvider);
  return await repo.getTasbihById(id);
});

class TasbihCountingScreen extends ConsumerStatefulWidget {
  final int tasbihId;
  const TasbihCountingScreen({super.key, required this.tasbihId});

  @override
  ConsumerState<TasbihCountingScreen> createState() => _TasbihCountingScreenState();
}

class _TasbihCountingScreenState extends ConsumerState<TasbihCountingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasbihAsync = ref.watch(singleTasbihProvider(widget.tasbihId));

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'المسبحة الإلكترونية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: tasbihAsync.when(
        data: (tasbih) {
          if (tasbih == null) return const Center(child: ArabicText('الذكر غير موجود.'));

          final progress = (tasbih.count / tasbih.target).clamp(0.0, 1.0);
          final isCompleted = tasbih.count >= tasbih.target;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.primary.withValues(alpha: 0.03),
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Phrase Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ArabicText(
                      tasbih.phrase,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        height: 1.5,
                      ),
                    ),
                  ).animate().fade().slideY(begin: -0.1, end: 0),
                ),
                
                const Spacer(),
                
                // Interactive Counter Button
                _buildLiquidCounter(tasbih, progress, isCompleted, theme),
                
                const Spacer(),

                // Control Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _resetCount(tasbih.id),
                          icon: const Icon(Icons.refresh),
                          label: ArabicText('تصفير', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.settings_backup_restore, color: theme.colorScheme.secondary),
                          onPressed: () {
                            // Logic to set a custom target could go here
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: ArabicText('خطأ: $err')),
      ),
    );
  }

  Widget _buildLiquidCounter(Tasbih tasbih, double progress, bool isCompleted, ThemeData theme) {
    return GestureDetector(
      onTap: () => _incrementCount(tasbih),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Aura
          if (isCompleted)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2000.ms),

          // Liquid Progress Container
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(280, 280),
                painter: LiquidPainter(
                  progress: progress,
                  waveValue: _waveController.value,
                  color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.secondary,
                  bubbleColor: Colors.white.withValues(alpha: 0.2),
                ),
              );
            },
          ),

          // Inner Tapping Circle (Glassmorphism effect)
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ArabicText(
                  tasbih.count.toString(),
                  style: GoogleFonts.cairo(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? Colors.white : theme.colorScheme.onSurface,
                    shadows: [
                      if (progress > 0.5)
                        const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                ).animate(key: ValueKey(tasbih.count)).scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1.0, 1.0),
                      duration: 150.ms,
                      curve: Curves.elasticOut,
                    ),
                ArabicText(
                  '${((progress) * 100).toInt()}%',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.white70 : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Completion Overlay Icon
          if (isCompleted)
            Positioned(
              top: 40,
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28)
                  .animate(onPlay: (c) => c.repeat())
                  .scale(duration: 1000.ms, curve: Curves.easeInOut)
                  .fade(),
            ),
        ],
      ),
    ).animate(key: ValueKey(tasbih.count))
     .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.96, 0.96), duration: 80.ms, curve: Curves.easeOut)
     .then()
     .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.0, 1.0), duration: 150.ms, curve: Curves.elasticOut);
  }

  Future<void> _incrementCount(Tasbih tasbih) async {
    final nextCount = tasbih.count + 1;
    
    // Haptics
    if (nextCount == tasbih.target) {
      HapticFeedback.heavyImpact();
    } else if (nextCount % 10 == 0) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    final repo = ref.read(adhkarRepositoryProvider);
    await repo.incrementTasbih(tasbih.id);
    try {
      ref.read(trackerRepositoryProvider).recordTasbihCount(1);
    } catch (_) {}
    ref.invalidate(singleTasbihProvider(widget.tasbihId));
    ref.invalidate(tasbihListProvider);
    ref.invalidate(tasbihLifetimeCountProvider);
  }

  Future<void> _resetCount(int id) async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(adhkarRepositoryProvider);
    await repo.resetTasbih(id);
    ref.invalidate(singleTasbihProvider(widget.tasbihId));
    ref.invalidate(tasbihListProvider);
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ArabicText('دليل المسبحة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: ArabicText(
          '• اضغط في أي مكان داخل الدائرة للتسبيح.\n'
          '• ستشعر باهتزاز عند كل تسبيحة، واهتزاز أقوى عند إتمام العدد المطلوب.\n'
          '• اللون يتغير تدريجياً ويملأ الدائرة كلما اقتربت من هدفك.',
          style: GoogleFonts.cairo(height: 1.6),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const ArabicText('حسناً'),
          )
        ],
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double progress;
  final double waveValue;
  final Color color;
  final Color bubbleColor;

  LiquidPainter({
    required this.progress,
    required this.waveValue,
    required this.color,
    required this.bubbleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw Border/Frame
    final framePaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, framePaint);

    // 2. Clip for liquid
    final circlePath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(circlePath);

    // 3. Draw Background color for the empty part
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = color.withValues(alpha: 0.05));

    // 4. Draw Wave
    final wavePath = Path();
    final double fillLevel = size.height * (1 - progress);
    const double waveAmplitude = 12.0;
    const double waveFrequency = 1.5;

    wavePath.moveTo(0, fillLevel);
    for (double x = 0; x <= size.width; x++) {
      final double y = fillLevel + math.sin((x / size.width * waveFrequency * 2 * math.pi) + (waveValue * 2 * math.pi)) * waveAmplitude;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    final liquidPaint = Paint()..color = color;
    canvas.drawPath(wavePath, liquidPaint);

    // 5. Draw some subtle bubbles/shines
    final bubblePaint = Paint()..color = bubbleColor;
    if (progress > 0.1) {
      canvas.drawCircle(Offset(size.width * 0.3, fillLevel + 30), 8, bubblePaint);
      canvas.drawCircle(Offset(size.width * 0.7, fillLevel + 50), 12, bubblePaint);
      canvas.drawCircle(Offset(size.width * 0.5, fillLevel + 20), 5, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) => true;
}
