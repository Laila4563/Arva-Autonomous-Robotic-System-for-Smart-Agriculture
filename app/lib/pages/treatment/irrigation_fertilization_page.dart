import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class IrrigationFertilizationPage extends StatefulWidget {
  const IrrigationFertilizationPage({super.key});

  @override
  State<IrrigationFertilizationPage> createState() =>
      _IrrigationFertilizationPageState();
}

class _IrrigationFertilizationPageState
    extends State<IrrigationFertilizationPage> {
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF101810);
  // static const Color richBark = Color(0xFF1A1F1C);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color criticalRed = Color(0xFFE57373);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: deepForest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              const Icon(Icons.precision_manufacturing, color: sproutGreen),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'TREATMENT ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Glass TabBar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05), // Glass base
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: sproutGreen.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: sproutGreen.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ironGrey,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  tabs: const [
                    Tab(text: 'IRRIGATION'),
                    Tab(text: 'FERTILIZATION'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMainContent(isFertilization: false),
                  _buildMainContent(isFertilization: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({required bool isFertilization}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ROBOT TANK LEVELS',
            style: TextStyle(
              color: ironGrey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Glass Tank Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTankGauge(
                      label: 'H20 RESERVOIR',
                      percent: 0.78,
                      color: const Color(0xFF1E88E5),
                    ),
                    _buildTankGauge(
                      label: 'BIO-FERTILIZER',
                      percent: 0.34,
                      color: sproutGreen,
                    ),
                  ],
                ),
                if (isFertilization) ...[
                  const Divider(color: Colors.white10, height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSmallMetric('12.5', 'NITRO (N)'),
                      const SizedBox(width: 20),
                      _buildSmallMetric('4.2', 'PHOS (P)'),
                      const SizedBox(width: 20),
                      _buildSmallMetric('8.9', 'POTAS (K)'),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
          isFertilization ? _buildNPKStatus() : _buildIrrigationMetrics(),
          const SizedBox(height: 20),

          // Glass Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: sproutGreen.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: sproutGreen.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop),
                  const SizedBox(width: 10),
                  Text(
                    isFertilization
                        ? 'TARGETED NUTRIENT RELEASE'
                        : 'TARGETED WATER RELEASE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Helper methods for Metrics & Cards ---

  Widget _buildSimpleMetricCard(
    String label,
    String val,
    String change,
    Color changeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ironGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                val,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIrrigationMetrics() {
  return Column(
    children: [
      Row(
        children: [
          Expanded(child: _buildSimpleMetricCard('AVG MOISTURE', '42%', '+2.4%', sproutGreen)),
          const SizedBox(width: 12),
          Expanded(child: _buildSimpleMetricCard('PUMP PSI', '85.2', '-1.1', criticalRed)),
        ],
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WATER USAGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('WEEKLY TELEMETRY (L)', style: TextStyle(color: ironGrey, fontSize: 10)),
                  ],
                ),
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      const TextSpan(text: '1.2L\n', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // The Enhanced Glass Graph
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: WavePainter(sproutGreen),
              ),
            ),
            const SizedBox(height: 10),
            // Weekly Labels
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MON', style: TextStyle(color: ironGrey, fontSize: 10)),
                Text('WED', style: TextStyle(color: ironGrey, fontSize: 10)),
                Text('FRI', style: TextStyle(color: ironGrey, fontSize: 10)),
                Text('SUN', style: TextStyle(color: ironGrey, fontSize: 10)),
              ],
            )
          ],
        ),
      ),
    ],
  );
}

  // Reuse the TankPainter, GlowRingPainter, and other widgets provided in previous turns...
  // (Assuming they are appended below as per the requested structure)

  Widget _buildTankGauge({
    required String label,
    required double percent,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(120, 180),
                painter: TankPainter(percent: percent, liquidColor: color),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildNPKStatus() {
    return Column(
      children: [
        // 1. NPK Status Rings
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusRing('N', 'CRITICAL', criticalRed),
            _buildStatusRing('P', 'OPTIMAL', harvestGold),
            _buildStatusRing('K', 'STABLE', sproutGreen),
          ],
        ),

        const SizedBox(height: 20),

        // 2. Recommended Action Card (Now exclusive to this view)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: criticalRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: criticalRed.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.psychology, color: criticalRed),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMMENDED ACTION',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Nitrogen levels critical at Grid B4. Recommend 15% increase in dosage for immediate recovery.',
                      style: TextStyle(
                        color: ironGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRing(String letter, String status, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: GlowRingPainter(color: color, progress: 0.7),
              ),
            ),
            Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallMetric(String val, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: sproutGreen.withValues(alpha: 0.3)),
          ),
          child: Text(
            val,
            style: const TextStyle(
              color: sproutGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: ironGrey,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// --- Custom Painters ---

class TankPainter extends CustomPainter {
  final double percent;
  final Color liquidColor;
  TankPainter({required this.percent, required this.liquidColor});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect containerRect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(size.width / 2),
    );
    final shellPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill;
    canvas.drawRRect(containerRect, shellPaint);

    double fillHeight = size.height * (1 - percent);
    if (percent > 0.05) {
      final glowPaint =
          Paint()
            ..color = liquidColor.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.save();
      canvas.clipRRect(containerRect);
      canvas.drawRect(
        Rect.fromLTRB(0, fillHeight, size.width, size.height),
        glowPaint,
      );
      canvas.restore();
    }

    final liquidPaint =
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(size.width / 2, fillHeight),
            Offset(size.width / 2, size.height),
            [
              liquidColor.withValues(alpha: 0.5),
              liquidColor.withValues(alpha: 0.05),
            ],
          );

    canvas.save();
    canvas.clipRRect(containerRect);
    canvas.drawRect(
      Rect.fromLTRB(0, fillHeight, size.width, size.height),
      liquidPaint,
    );
    if (percent > 0 && percent < 1.0) {
      final linePaint =
          Paint()
            ..color = liquidColor.withValues(alpha: 0.8)
            ..strokeWidth = 2
            ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
      canvas.drawLine(
        Offset(0, fillHeight),
        Offset(size.width, fillHeight),
        linePaint,
      );
    }
    canvas.restore();

    final borderPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    canvas.drawRRect(containerRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TankPainter oldDelegate) =>
      oldDelegate.percent != percent;
}

class GlowRingPainter extends CustomPainter {
  final Color color;
  final double progress;
  GlowRingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final trackPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
    canvas.drawCircle(center, radius, trackPaint);

    final glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final progressPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final Color color;
  WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // 1. Create the Spline Path
    final ui.Path path = ui.Path();
    path.moveTo(0, height * 0.7);
    path.quadraticBezierTo(width * 0.15, height * 0.4, width * 0.3, height * 0.65);
    path.quadraticBezierTo(width * 0.45, height * 0.9, width * 0.6, height * 0.3);
    path.quadraticBezierTo(width * 0.75, height * 0.1, width * 0.85, height * 0.8);
    path.lineTo(width, height * 0.2);

    // 2. Create the filled area path for the gradient
    final ui.Path fillPath = ui.Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    // 3. Define the Glassy Gradient Fill
    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, height * 0.2),
        Offset(0, height),
        [
          color.withValues(alpha: 0.4), // Top glow
          color.withValues(alpha: 0.0), // Fades to transparent
        ],
      );

    // 4. Define the Glowing Top Line
    final Paint linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3); // Neon Glow Effect

    // 5. Draw the components
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
