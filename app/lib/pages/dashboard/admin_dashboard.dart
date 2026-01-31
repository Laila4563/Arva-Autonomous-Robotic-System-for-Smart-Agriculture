import 'package:flutter/material.dart';
import 'dart:math' as math;

class AdminDashboard extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AdminDashboard({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // --- THEME COLORS ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0A150F);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color criticalRed = Color(0xFFE57373);
  static const Color backgroundLight = Color.fromARGB(255, 246, 248, 246);

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDarkMode;
    final Color currentBg = dark ? deepForest : backgroundLight;
    final Color cardColor = dark ? Colors.white.withValues(alpha: 0.03) : Colors.white;
    final Color borderColor = dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);
    final Color mainTextColor = dark ? Colors.white : deepForest;

    return Scaffold(
      backgroundColor: currentBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'ARVA ADMIN DASHBOARD',
              style: TextStyle(
                color: mainTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: sproutGreen, size: 8),
                const SizedBox(width: 6),
                const Text(
                  'SYSTEM HEALTH: OPTIMAL',
                  style: TextStyle(color: sproutGreen, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildRoundButton(
              dark ? Icons.light_mode : Icons.dark_mode,
              dark ? Colors.white : deepForest,
              onTap: widget.onThemeToggle,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('REGIONAL WEATHER INTELLIGENCE', mainTextColor, isLive: true),
            _buildWeatherCard(cardColor, borderColor, mainTextColor),
            const SizedBox(height: 24),
            _buildSectionHeader('USER ANALYTICS', mainTextColor),
            _buildUserAnalyticsCard(cardColor, borderColor, mainTextColor),
            const SizedBox(height: 24),
            _buildSectionHeader('SYSTEM HEARTBEAT', mainTextColor),
            _buildSystemHeartbeatCard(cardColor, borderColor, mainTextColor),
            const SizedBox(height: 24),
            _buildSectionHeader('RECENT URGENT ALERTS', mainTextColor, showWarning: true),
            _buildAlertCard(
              user: 'FARMX',
              title: 'Soil Moisture Critical',
              desc: 'Threshold below 12% in sector 4A. Immediate irrigation required.',
              time: '2m ago',
              color: criticalRed,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: mainTextColor,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              user: 'GREENHARVEST',
              title: 'Battery Low - Robot #104',
              desc: "Charging required to complete task 'Pest Inspection B'.",
              time: '14m ago',
              color: harvestGold,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: mainTextColor,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor, {bool isLive = false, bool showWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              if (showWarning) ...[
                const SizedBox(width: 8),
                const Icon(Icons.warning_amber_rounded, color: criticalRed, size: 16),
              ],
            ],
          ),
          if (isLive) const Text('LIVE', style: TextStyle(color: sproutGreen, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(Color bg, Color border, Color text) {
    return _glassContainer(
      bg: bg,
      border: border,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOCAL TEMP', style: TextStyle(color: ironGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('78° C', style: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              const Column(
                children: [
                  Icon(Icons.wb_cloudy_outlined, color: sproutGreen, size: 32),
                  Text('CLEAR SKIES', style: TextStyle(color: sproutGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _weatherSubTile(Icons.water_drop, 'HUMIDITY', '42%', text)),
              const SizedBox(width: 12),
              Expanded(child: _weatherSubTile(Icons.air, 'WIND', '12 mph', text)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: criticalRed.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: criticalRed.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.thunderstorm, color: criticalRed, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INCOMING STORM ALERT', style: TextStyle(color: criticalRed, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text('Heavy precipitation expected in 45m.', style: TextStyle(color: ironGrey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsCard(Color bg, Color border, Color text) {
    return _glassContainer(
      bg: bg,
      border: border,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL NETWORK USERS', style: TextStyle(color: ironGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('1,284', style: TextStyle(color: sproutGreen, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ACTIVE SESSIONS', style: TextStyle(color: ironGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('142', style: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('TOP PERFORMING USERS', style: TextStyle(color: sproutGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),
          _topUserTile('FX', 'FarmX Corp', '12 Deployments', '98.2', text),
          const SizedBox(height: 10),
          _topUserTile('GH', 'GreenHarvest', '8 Deployments', '94.5', text),
        ],
      ),
    );
  }

  Widget _buildSystemHeartbeatCard(Color bg, Color border, Color text) {
    return _glassContainer(
      bg: bg,
      border: border,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(100, 100),
                  painter: GlowWheelPainter(
                    sproutGreen,
                    widget.isDarkMode ? criticalRed : ironGrey.withValues(alpha: 0.2),
                    0.85,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('428', style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('TOTAL', style: TextStyle(color: ironGrey, fontSize: 8)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                _statusRow(sproutGreen, 'Online', '384', text),
                const SizedBox(height: 8),
                _statusRow(criticalRed, 'Offline', '44', text),
                Divider(color: text.withValues(alpha: 0.1), height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('UPTIME: 99.8%', style: TextStyle(color: sproutGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({required String user, required String title, required String desc, required String time, required Color color, required Color cardColor, required Color borderColor, required Color textColor}) {
    return _glassContainer(
      bg: cardColor,
      border: borderColor,
      padding: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 4))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('USER: $user', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: ironGrey, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: ironGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child, required Color bg, required Color border, double padding = 16}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
      child: child,
    );
  }

  Widget _weatherSubTile(IconData icon, String label, String val, Color text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: text.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: sproutGreen, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: ironGrey, fontSize: 8, fontWeight: FontWeight.bold)),
              Text(val, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topUserTile(String initial, String name, String sub, String score, Color text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: text.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: sproutGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(initial, style: const TextStyle(color: sproutGreen, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: ironGrey, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score, style: const TextStyle(color: sproutGreen, fontSize: 14, fontWeight: FontWeight.bold)),
              const Text('MONITORING SCORE', style: TextStyle(color: ironGrey, fontSize: 7, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _statusRow(Color color, String label, String val, Color text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: text.withValues(alpha: 0.7), fontSize: 12)),
        const Spacer(),
        Text(val, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class GlowWheelPainter extends CustomPainter {
  final Color onlineColor;
  final Color offlineColor;
  final double percent;
  GlowWheelPainter(this.onlineColor, this.offlineColor, this.percent);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()..color = offlineColor..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    final glowPaint = Paint()..color = onlineColor.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 12..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final progressPaint = Paint()..color = onlineColor..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * percent, false, glowPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * percent, false, progressPaint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}