import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../controllers/qibla_controller.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

class CompassScreen extends ConsumerWidget {
  const CompassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'اتجاه القبلة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(qiblaState.hapticEnabled ? Icons.vibration : Icons.portable_wifi_off_outlined),
            tooltip: qiblaState.hapticEnabled ? 'تعطيل الاهتزاز عند المحاذاة' : 'تفعيل الاهتزاز عند المحاذاة',
            color: qiblaState.hapticEnabled ? theme.colorScheme.primary : theme.disabledColor,
            onPressed: () {
              ref.read(qiblaProvider.notifier).toggleHaptic();
            },
          ),
          if (qiblaState.usingFallbackCity)
            IconButton(
              icon: const Icon(Icons.gps_fixed),
              tooltip: 'تحديث الموقع من الـ GPS',
              onPressed: () {
                ref.read(qiblaProvider.notifier).enableGps();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: qiblaState.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    ArabicText(
                      'جاري تحديد الموقع وحساب القبلة...',
                      style: GoogleFonts.cairo(fontSize: 16, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // 1. Location Banner (Premium Header)
                    _buildLocationHeaderCard(qiblaState, theme),
                    const SizedBox(height: 16),

                    // 2. Calibration Instructions Banner
                    _buildCalibrationBanner(theme),
                    const SizedBox(height: 24),

                    // 3. Compass Stack
                    Center(
                      child: SizedBox(
                        width: 290,
                        height: 290,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Aligned Glow Effect (Emerald Green)
                            if (qiblaState.isAligned)
                              Container(
                                width: 290,
                                height: 290,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                               .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms),

                            // Proximity/Alignment Ring
                            CustomPaint(
                              size: const Size(290, 290),
                              painter: CompassProximityRingPainter(
                                needleAngle: qiblaState.needleAngle,
                                isAligned: qiblaState.isAligned,
                                goldColor: theme.colorScheme.secondary,
                                emeraldColor: const Color(0xFF2E7D32),
                              ),
                            ),

                            // Outer Compass Dial (N, S, E, W & degree ticks)
                            Transform.rotate(
                              angle: -qiblaState.heading * math.pi / 180,
                              child: CustomPaint(
                                size: const Size(280, 280),
                                painter: CompassDialPainter(
                                  qiblaAngle: qiblaState.qiblaAngle,
                                  primaryColor: theme.colorScheme.primary,
                                  goldColor: theme.colorScheme.secondary,
                                  textColor: const Color(0xFF3B1E1E), // Deep Brown Text
                                ),
                              ),
                            ),

                            // Rotating Needle (Pointing to Mecca)
                            Transform.rotate(
                              angle: qiblaState.needleAngle * math.pi / 180,
                              child: CustomPaint(
                                size: const Size(280, 280),
                                painter: CompassNeedlePainter(
                                  isAligned: qiblaState.isAligned,
                                  primaryColor: theme.colorScheme.primary,
                                  goldColor: theme.colorScheme.secondary,
                                ),
                              ),
                            ),

                            // Center Pin & Kaaba Emblem
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: qiblaState.isAligned
                                    ? const Color(0xFF2E7D32)
                                    : theme.colorScheme.secondary,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.mosque,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. Guidance Panel
                    _buildGuidanceCard(qiblaState, theme),
                    const SizedBox(height: 24),

                    // 5. Distance & Angle Cards (Side by side)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: 'زاوية القبلة',
                            value: '${qiblaState.qiblaAngle.toStringAsFixed(1)}°',
                            subtitle: 'من الشمال',
                            icon: Icons.explore_outlined,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'المسافة للكعبة',
                            value: _formatDistance(qiblaState.distanceToKaaba),
                            subtitle: 'كيلومتر تقريباً',
                            icon: Icons.map_outlined,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ArabicText(
                      'تجنب وضع الهاتف بالقرب من الأجهزة المغناطيسية لضمان دقة القراءة.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCalibrationBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: ArabicText(
              'للحصول على قراءة دقيقة، ضع الهاتف بشكل مسطح وحركه بمسار شكل رقم 8 (⒏) لضبط البوصلة.',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeaderCard(QiblaState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              state.usingFallbackCity ? Icons.location_city : Icons.my_location,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArabicText(
                  state.cityName,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                ArabicText(
                  '${state.latitude.toStringAsFixed(4)}° N, ${state.longitude.toStringAsFixed(4)}° E',
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
    );
  }

  Widget _buildGuidanceCard(QiblaState qiblaState, ThemeData theme) {
    final isAligned = qiblaState.isAligned;
    final needleAngle = qiblaState.needleAngle;

    String text;
    IconData icon;
    Color color;
    Color strokeColor;

    if (isAligned) {
      text = 'أنت موازي للقبلة تماماً الآن 🕋';
      icon = Icons.check_circle;
      color = const Color(0xFF2E7D32);
      strokeColor = const Color(0xFF2E7D32);
    } else {
      if (needleAngle > 0 && needleAngle <= 180) {
        text = 'أدر الهاتف لليمين بـ ${needleAngle.toStringAsFixed(0)}° ↻';
        icon = Icons.rotate_right;
      } else {
        text = 'أدر الهاتف لليسار بـ ${(360 - needleAngle).toStringAsFixed(0)}° ↺';
        icon = Icons.rotate_left;
      }
      color = theme.colorScheme.secondary;
      strokeColor = theme.dividerColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isAligned
            ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAligned ? const Color(0xFF2E7D32) : strokeColor,
          width: isAligned ? 2 : 1,
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          ArabicText(
            text,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isAligned ? const Color(0xFF2E7D32) : theme.textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    ).animate(target: isAligned ? 1 : 0)
     .shake(duration: 400.ms, hz: 4);
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ArabicText(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ArabicText(
            value,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          ArabicText(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double distance) {
    final NumberFormat formatter = NumberFormat('#,###', 'ar');
    return formatter.format(distance.round());
  }
}

class CompassProximityRingPainter extends CustomPainter {
  final double needleAngle;
  final bool isAligned;
  final Color goldColor;
  final Color emeraldColor;

  CompassProximityRingPainter({
    required this.needleAngle,
    required this.isAligned,
    required this.goldColor,
    required this.emeraldColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final angleDiff = needleAngle > 180 ? 360 - needleAngle : needleAngle;
    final proximity = (1.0 - (angleDiff / 180.0)).clamp(0.0, 1.0);

    final color = Color.lerp(goldColor, emeraldColor, math.pow(proximity, 3).toDouble()) ?? goldColor;

    final ringPaint = Paint()
      ..color = color.withValues(alpha: isAligned ? 0.8 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 5.0 : 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final sweepAngle = proximity * 2 * math.pi;
    final startAngle = -math.pi / 2 - (sweepAngle / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      startAngle,
      sweepAngle,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CompassProximityRingPainter oldDelegate) {
    return oldDelegate.needleAngle != needleAngle || oldDelegate.isAligned != isAligned;
  }
}

class CompassDialPainter extends CustomPainter {
  final double qiblaAngle;
  final Color primaryColor;
  final Color goldColor;
  final Color textColor;

  CompassDialPainter({
    required this.qiblaAngle,
    required this.primaryColor,
    required this.goldColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerRingPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerRingPaint);

    final borderPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);

    canvas.drawCircle(center, radius - 15, Paint()
      ..color = goldColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);

    final qiblaRad = (qiblaAngle - 90) * math.pi / 180;
    final sectorSweep = 16 * math.pi / 180;
    final sectorPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      qiblaRad - (sectorSweep / 2),
      sectorSweep,
      true,
      sectorPaint,
    );

    final wedgeBorderPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final lineLength = radius - 15;
    final startAngle = qiblaRad - (sectorSweep / 2);
    final endAngle = qiblaRad + (sectorSweep / 2);

    canvas.drawLine(
      center,
      Offset(center.dx + lineLength * math.cos(startAngle), center.dy + lineLength * math.sin(startAngle)),
      wedgeBorderPaint,
    );
    canvas.drawLine(
      center,
      Offset(center.dx + lineLength * math.cos(endAngle), center.dy + lineLength * math.sin(endAngle)),
      wedgeBorderPaint,
    );

    final ticksPaint = Paint()
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;
      final tickLength = isCardinal ? 14.0 : (isMajor ? 8.0 : 4.0);

      ticksPaint.color = isCardinal 
          ? goldColor 
          : (isMajor ? textColor.withValues(alpha: 0.5) : textColor.withValues(alpha: 0.25));
      ticksPaint.strokeWidth = isCardinal ? 2.5 : (isMajor ? 1.5 : 0.8);

      final start = Offset(
        center.dx + (radius - tickLength - 3) * math.cos(angle),
        center.dy + (radius - tickLength - 3) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 3) * math.cos(angle),
        center.dy + (radius - 3) * math.sin(angle),
      );
      canvas.drawLine(start, end, ticksPaint);
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.rtl,
    );

    final List<Map<String, dynamic>> cardinals = [
      {'label': 'ش', 'angle': 270.0, 'color': Colors.redAccent, 'isMajor': true},
      {'label': 'ق', 'angle': 0.0, 'color': goldColor, 'isMajor': false},
      {'label': 'ج', 'angle': 90.0, 'color': textColor.withValues(alpha: 0.6), 'isMajor': false},
      {'label': 'غ', 'angle': 180.0, 'color': textColor.withValues(alpha: 0.6), 'isMajor': false},
    ];

    for (final card in cardinals) {
      final angle = (card['angle'] as double) * math.pi / 180;
      textPainter.text = TextSpan(
        text: card['label'] as String,
        style: GoogleFonts.cairo(
          fontSize: card['isMajor'] as bool ? 18 : 15,
          fontWeight: FontWeight.w900,
          color: card['color'] as Color,
        ),
      );
      textPainter.layout();

      final x = center.dx + (radius - 28) * math.cos(angle) - (textPainter.width / 2);
      final y = center.dy + (radius - 28) * math.sin(angle) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(x, y));
    }

    // 5. Draw a small Kaaba at the Qibla Angle on the dial
    final kaabaCenter = Offset(
      center.dx + (radius - 20) * math.cos(qiblaRad),
      center.dy + (radius - 20) * math.sin(qiblaRad),
    );

    // Draw Kaaba shadow
    canvas.drawRect(
      Rect.fromCenter(center: kaabaCenter + const Offset(0, 1.5), width: 22, height: 22),
      Paint()
        ..color = Colors.black12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Draw Kaaba body (Black cube)
    final kaabaPaint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawRect(
      Rect.fromCenter(center: kaabaCenter, width: 20, height: 20),
      kaabaPaint,
    );

    // Draw Kaaba gold Kiswah belt
    final beltPaint = Paint()
      ..color = goldColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(kaabaCenter.dx - 10, kaabaCenter.dy - 3),
      Offset(kaabaCenter.dx + 10, kaabaCenter.dy - 3),
      beltPaint,
    );

    // Draw Kaaba white door
    final doorPaint = Paint()..color = const Color(0xFFE5D3B3); // Warm Kiswah door color
    canvas.drawRect(
      Rect.fromLTRB(
        kaabaCenter.dx - 3,
        kaabaCenter.dy + 2,
        kaabaCenter.dx + 3,
        kaabaCenter.dy + 10,
      ),
      doorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompassNeedlePainter extends CustomPainter {
  final bool isAligned;
  final Color primaryColor;
  final Color goldColor;

  CompassNeedlePainter({
    required this.isAligned,
    required this.primaryColor,
    required this.goldColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final activeColor = isAligned ? const Color(0xFF2E7D32) : goldColor;

    final pathLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx, center.dy - radius + 32)
      ..close();

    final paintLeft = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final pathRight = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..lineTo(center.dx, center.dy - radius + 32)
      ..close();

    final paintRight = Paint()
      ..color = activeColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final pathSouthLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx, center.dy + radius - 45)
      ..close();

    final paintSouthLeft = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final pathSouthRight = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..lineTo(center.dx, center.dy + radius - 45)
      ..close();

    final paintSouthRight = Paint()
      ..color = Colors.grey.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final shadowPath = Path()
      ..moveTo(center.dx, center.dy + 3)
      ..lineTo(center.dx - 10, center.dy + 3)
      ..lineTo(center.dx, center.dy - radius + 35)
      ..lineTo(center.dx + 10, center.dy + 3)
      ..lineTo(center.dx, center.dy + radius - 42)
      ..close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(pathLeft, paintLeft);
    canvas.drawPath(pathRight, paintRight);
    canvas.drawPath(pathSouthLeft, paintSouthLeft);
    canvas.drawPath(pathSouthRight, paintSouthRight);

    final centerCirclePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(center.dx, center.dy - radius + 75), 6, centerCirclePaint);

    final innerCirclePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy - radius + 75), 3, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CompassNeedlePainter oldDelegate) {
    return oldDelegate.isAligned != isAligned ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.goldColor != goldColor;
  }
}
