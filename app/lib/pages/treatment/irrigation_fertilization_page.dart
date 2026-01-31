import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:app/components/user_navbar.dart'; 

class IrrigationFertilizationPage extends StatefulWidget {
  const IrrigationFertilizationPage({super.key});

  @override
  State<IrrigationFertilizationPage> createState() =>
      _IrrigationFertilizationPageState();
}

class _IrrigationFertilizationPageState
    extends State<IrrigationFertilizationPage> {
  bool isDarkMode = true;

  // --- THEME COLORS ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF101810);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color criticalRed = Color(0xFFE57373);
  static const Color backgroundLight = Color.fromARGB(255, 246, 248, 246);

  @override
  Widget build(BuildContext context) {
    final Color currentBg = isDarkMode ? deepForest : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : deepForest;
    final Color cardColor = isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: currentBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildRoundButton(
              Icons.arrow_back_ios_new,
              textColor,
              onTap: () {
                // Switches tab to HOME (index 0) using the existing UserNavbar state
                UserNavbar.of(context)?.setIndex(0);
              },
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.precision_manufacturing, color: sproutGreen),
              const SizedBox(width: 8),
              Text(
                'TREATMENT',
                style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildRoundButton(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                textColor,
                onTap: () => setState(() => isDarkMode = !isDarkMode),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: sproutGreen.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ironGrey,
                  dividerColor: Colors.transparent,
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
                  _buildMainContent(isFertilization: false, textColor: textColor, cardColor: cardColor, borderColor: borderColor),
                  _buildMainContent(isFertilization: true, textColor: textColor, cardColor: cardColor, borderColor: borderColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildMainContent({required bool isFertilization, required Color textColor, required Color cardColor, required Color borderColor}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ROBOT TANK LEVELS', style: TextStyle(color: ironGrey, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTankGauge(label: 'H20 RESERVOIR', percent: 0.78, color: const Color(0xFF1E88E5), textColor: textColor),
                    _buildTankGauge(label: 'BIO-FERTILIZER', percent: 0.34, color: sproutGreen, textColor: textColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          isFertilization ? _buildNPKStatus(cardColor, borderColor, textColor) : _buildIrrigationMetrics(cardColor, borderColor, textColor),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: sproutGreen.withValues(alpha: 0.8),
              minimumSize: const Size(double.infinity, 70),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(isFertilization ? 'TARGETED NUTRIENT RELEASE' : 'TARGETED WATER RELEASE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTankGauge({required String label, required double percent, required Color color, required Color textColor}) {
    return Column(
      children: [
        SizedBox(
          height: 180, width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: const Size(120, 180), painter: TankPainter(percent: percent, liquidColor: color, isDarkMode: isDarkMode)),
              Text('${(percent * 100).toInt()}%', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIrrigationMetrics(Color cardColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('WEEKLY USAGE', style: TextStyle(color: ironGrey, fontWeight: FontWeight.bold)),
            Text('1.2L', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),
          SizedBox(height: 120, width: double.infinity, child: CustomPaint(painter: WavePainter(sproutGreen, isDarkMode))),
        ],
      ),
    );
  }

  Widget _buildNPKStatus(Color cardColor, Color borderColor, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusRing('N', 'CRITICAL', criticalRed, textColor),
        _buildStatusRing('P', 'OPTIMAL', harvestGold, textColor),
        _buildStatusRing('K', 'STABLE', sproutGreen, textColor),
      ],
    );
  }

  Widget _buildStatusRing(String letter, String status, Color color, Color textColor) {
    return Column(
      children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 80, height: 80, child: CustomPaint(painter: GlowRingPainter(color: color, progress: 0.7, isDarkMode: isDarkMode))),
          Text(letter, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- CUSTOM PAINTERS ---

class TankPainter extends CustomPainter {
  final double percent;
  final Color liquidColor;
  final bool isDarkMode;
  TankPainter({required this.percent, required this.liquidColor, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect containerRect = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(size.width / 2));
    final shellPaint = Paint()..color = isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)..style = PaintingStyle.fill;
    canvas.drawRRect(containerRect, shellPaint);

    double fillHeight = size.height * (1 - percent);
    final liquidPaint = Paint()..shader = ui.Gradient.linear(Offset(size.width / 2, fillHeight), Offset(size.width / 2, size.height), [liquidColor.withValues(alpha: 0.5), liquidColor.withValues(alpha: 0.1)]);
    
    canvas.save();
    canvas.clipRRect(containerRect);
    canvas.drawRect(Rect.fromLTRB(0, fillHeight, size.width, size.height), liquidPaint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GlowRingPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isDarkMode;
  GlowRingPainter({required this.color, required this.progress, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final trackPaint = Paint()..color = isDarkMode ? Colors.white10 : Colors.black12..style = PaintingStyle.stroke..strokeWidth = 6;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;
  WavePainter(this.color, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final ui.Path path = ui.Path();
    path.moveTo(0, height * 0.7);
    path.quadraticBezierTo(width * 0.25, height * 0.2, width * 0.5, height * 0.5);
    path.quadraticBezierTo(width * 0.75, height * 0.8, width, height * 0.3);

    final Paint linePaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}