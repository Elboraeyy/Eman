import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../controllers/qibla_controller.dart';

class CompassScreen extends ConsumerWidget {
  const CompassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اتجاه القبلة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (qiblaState.usingFallbackCity)
            TextButton.icon(
              onPressed: () {
                ref.read(qiblaProvider.notifier).enableGps();
              },
              icon: const Icon(Icons.gps_fixed, size: 16),
              label: Text(
                'تفعيل الـ GPS',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
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
                    Text(
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
                    const SizedBox(height: 24),

                    // 2. Compass Stack
                    Center(
                      child: SizedBox(
                        width: 290,
                        height: 290,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Aligned Glow Effect
                            if (qiblaState.isAligned)
                              Container(
                                width: 290,
                                height: 290,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                               .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms),

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
                                    ? theme.colorScheme.primary
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

                    // 3. Guidance Panel
                    _buildGuidanceCard(qiblaState, theme),
                    const SizedBox(height: 24),

                    // 4. Distance & Angle Cards (Side by side)
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

                    // 5. Change City Manually Button
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const _CitySelectorBottomSheet(),
                        );
                      },
                      icon: const Icon(Icons.location_city_outlined),
                      label: Text(
                        'تغيير المدينة يدوياً',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                        side: BorderSide(color: theme.colorScheme.secondary),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ضع الهاتف في وضع مسطح وتجنب وضعه بالقرب من الأجهزة المغناطيسية لضمان دقة القراءة.',
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
                Text(
                  state.cityName,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  '${state.latitude.toStringAsFixed(4)}° N, ${state.longitude.toStringAsFixed(4)}° E',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: state.usingFallbackCity
                  ? theme.colorScheme.secondary.withValues(alpha: 0.12)
                  : theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: state.usingFallbackCity
                    ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                    : theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
          ),
            child: Text(
              state.usingFallbackCity ? 'تحديد يدوي' : 'تحديد تلقائي',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: state.usingFallbackCity
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
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
      color = theme.colorScheme.primary;
      strokeColor = theme.colorScheme.primary;
    } else {
      // If angle is between 0 and 180, turn right. If 180 and 360, turn left.
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
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAligned ? theme.colorScheme.primary : strokeColor,
          width: isAligned ? 2 : 1,
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
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
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isAligned ? theme.colorScheme.primary : theme.textTheme.titleLarge?.color,
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
              Text(
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
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
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

    // 1. Draw elegant outer geometric background circle
    final outerRingPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerRingPaint);

    final borderPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Subtle inner golden thin ring
    canvas.drawCircle(center, radius - 15, Paint()
      ..color = goldColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);

    // 2. Draw Qibla Direction Sector (Golden Glow Wedge pointing to Mecca)
    // A 16-degree gold highlight wedge centered on the qiblaAngle
    final qiblaRad = (qiblaAngle - 90) * math.pi / 180; // offset by -90 for canvas coordinate system
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

    // Draw lines bordering the wedge
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

    // 3. Draw Degree ticks
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

    // 4. Draw Cardinal Letters in Arabic (ش, ق, ج, غ)
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

      // Position the letter beautifully inside the ticks
      final x = center.dx + (radius - 28) * math.cos(angle) - (textPainter.width / 2);
      final y = center.dy + (radius - 28) * math.sin(angle) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(x, y));
    }
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

    // Use active color based on alignment: green if aligned, gold otherwise
    final activeColor = isAligned ? primaryColor : goldColor;

    // Premium needle: dual-shaded pointer pointing North
    // Left side (lighter shade)
    final pathLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx, center.dy - radius + 32)
      ..close();

    final paintLeft = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    // Right side (darker shade for 3D effect)
    final pathRight = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..lineTo(center.dx, center.dy - radius + 32)
      ..close();

    final paintRight = Paint()
      ..color = activeColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    // Southern tail (opposing end) - left side
    final pathSouthLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx, center.dy + radius - 45)
      ..close();

    final paintSouthLeft = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Southern tail - right side (darker)
    final pathSouthRight = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..lineTo(center.dx, center.dy + radius - 45)
      ..close();

    final paintSouthRight = Paint()
      ..color = Colors.grey.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    // Draw Shadows under the needle
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

    // Draw needle halves
    canvas.drawPath(pathLeft, paintLeft);
    canvas.drawPath(pathRight, paintRight);
    canvas.drawPath(pathSouthLeft, paintSouthLeft);
    canvas.drawPath(pathSouthRight, paintSouthRight);

    // Draw elegant decorative star or circle on the needle shaft
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

class _CitySelectorBottomSheet extends ConsumerStatefulWidget {
  const _CitySelectorBottomSheet();

  @override
  ConsumerState<_CitySelectorBottomSheet> createState() => _CitySelectorBottomSheetState();
}

class _CitySelectorBottomSheetState extends ConsumerState<_CitySelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCities = fallbackCities.where((city) {
      return city.name.contains(_query) ||
          city.latitude.toString().contains(_query) ||
          city.longitude.toString().contains(_query);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'اختر مدينتك يدوياً',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            onChanged: (val) {
              setState(() {
                _query = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن مدينة...',
              hintStyle: GoogleFonts.cairo(fontSize: 14),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredCities.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد نتائج مطابقة',
                      style: GoogleFonts.cairo(color: theme.disabledColor),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredCities.length,
                    separatorBuilder: (context, index) => Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      return ListTile(
                        title: Text(
                          city.name,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '${city.latitude.toStringAsFixed(2)}° N, ${city.longitude.toStringAsFixed(2)}° E',
                          style: GoogleFonts.robotoMono(fontSize: 12),
                        ),
                        trailing: Icon(
                          Icons.location_on_outlined,
                          color: theme.colorScheme.secondary,
                        ),
                        onTap: () {
                          ref.read(qiblaProvider.notifier).selectManualCity(city);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
