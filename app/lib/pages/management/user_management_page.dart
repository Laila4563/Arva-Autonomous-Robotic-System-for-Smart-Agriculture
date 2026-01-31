import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppColors {
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0A150F);
  static const Color richBark = Color(0xFF1A1F1C);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color.fromARGB(255, 246, 248, 246);
}

class UserManagementPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const UserManagementPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDarkMode;
    final Color currentBg = dark ? AppColors.deepForest : AppColors.backgroundLight;
    final Color textColor = dark ? Colors.white : AppColors.deepForest;
    final Color cardColor = dark ? AppColors.richBark.withValues(alpha: 0.4) : Colors.white;
    final Color borderColor = dark ? AppColors.ironGrey.withValues(alpha: 0.2) : AppColors.ironGrey.withValues(alpha: 0.1);

    return Scaffold(
      backgroundColor: currentBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(color: dark ? AppColors.ironGrey.withValues(alpha: 0.1) : AppColors.ironGrey.withValues(alpha: 0.05)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(textColor),
                _buildAddButton(),
                _buildActiveHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      OperatorCard(id: 'T-4092', name: 'Marcus Thorne', email: 'm.thorne@arva-agri.com', percent: 0.95, color: AppColors.sproutGreen, isDarkMode: dark, cardColor: cardColor, borderColor: borderColor, textColor: textColor),
                      OperatorCard(id: 'B-1229', name: 'Sarah Chen', email: 's.chen@arva-agri.com', percent: 0.84, color: AppColors.sproutGreen, isDarkMode: dark, cardColor: cardColor, borderColor: borderColor, textColor: textColor),
                      OperatorCard(id: 'A-0882', name: 'Vaughn Miller', email: 'v.miller@arva-agri.com', percent: 0.41, color: AppColors.harvestGold, isDarkMode: dark, cardColor: cardColor, borderColor: borderColor, textColor: textColor),
                      const SizedBox(height: 30),
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

  Widget _buildHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: AppColors.sproutGreen, size: 10),
                  const SizedBox(width: 8),
                  Text('COMMAND CENTER', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const Text('ARVA OPERATOR MGMT', style: TextStyle(color: AppColors.ironGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          Row(
            children: [
              _buildRoundButton(Icons.analytics_outlined, AppColors.sproutGreen, onTap: () => print("Analytics Ledger Accessed")),
              const SizedBox(width: 12),
              _buildRoundButton(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, widget.isDarkMode ? Colors.white : AppColors.deepForest, onTap: widget.onThemeToggle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.08), border: Border.all(color: color.withValues(alpha: 0.15))),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.sproutGreen.withValues(alpha: widget.isDarkMode ? 0.2 : 0.3), blurRadius: 15, spreadRadius: -2)]),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.sproutGreen, foregroundColor: widget.isDarkMode ? AppColors.deepForest : Colors.white, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_add_alt_1, size: 28), SizedBox(width: 12), Text('ADD NEW OPERATOR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2))]),
        ),
      ),
    );
  }

  Widget _buildActiveHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ACTIVE OPERATORS', style: TextStyle(color: AppColors.ironGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Row(children: [Icon(Icons.sensors, color: AppColors.sproutGreen, size: 14), SizedBox(width: 6), Text('3 ONLINE', style: TextStyle(color: AppColors.sproutGreen, fontSize: 10, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }
}

class OperatorCard extends StatelessWidget {
  final String id, name, email;
  final double percent;
  final Color color, cardColor, borderColor, textColor;
  final bool isDarkMode;
  const OperatorCard({super.key, required this.id, required this.name, required this.email, required this.percent, required this.color, required this.isDarkMode, required this.cardColor, required this.borderColor, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor), boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(20.0), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ID', style: TextStyle(color: AppColors.skyBlue, fontSize: 9, fontWeight: FontWeight.bold)),
            Text(id, style: const TextStyle(color: AppColors.skyBlue, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('EMAIL', style: TextStyle(color: AppColors.ironGrey, fontSize: 9, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: 12),
            const Text('PASSWORD', style: TextStyle(color: AppColors.ironGrey, fontSize: 9, fontWeight: FontWeight.bold)),
            Text('● ● ● ● ● ● ● ●', style: TextStyle(color: color, fontSize: 12)),
          ])),
          _buildStatusWheel(textColor),
        ])),
        Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.ironGrey.withValues(alpha: 0.2), width: 0.2))), child: Row(children: [_cardAction(Icons.notes_rounded, 'EDIT'), _cardAction(Icons.visibility_rounded, 'VIEW'), _cardAction(Icons.delete_rounded, 'REMOVE', isLast: true, isDestructive: true)]))
      ]),
    );
  }
  Widget _buildStatusWheel(Color textColor) {
    return SizedBox(width: 100, height: 100, child: Stack(alignment: Alignment.center, children: [
      CustomPaint(size: const Size(85, 85), painter: RadialPainter(percent: percent, color: color, trackColor: AppColors.ironGrey.withValues(alpha: 0.1))),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.battery_std, color: color, size: 18), Text('${(percent * 100).toInt()}%', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold))]),
    ]));
  }
  Widget _cardAction(IconData icon, String label, {bool isLast = false, bool isDestructive = false}) {
    return Expanded(child: Container(height: 50, decoration: BoxDecoration(border: isLast ? null : Border(right: BorderSide(color: AppColors.ironGrey.withValues(alpha: 0.2), width: 0.2))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: isDestructive ? Colors.redAccent.withValues(alpha: 0.7) : AppColors.ironGrey), const SizedBox(width: 8), Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent.withValues(alpha: 0.7) : AppColors.ironGrey, fontSize: 10, fontWeight: FontWeight.bold))])));
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5;
    const double step = 35;
    for (double i = 0; i < size.width; i += step) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i < size.height; i += step) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RadialPainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trackColor;
  RadialPainter({required this.percent, required this.color, required this.trackColor});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = 6);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * percent, false, Paint()..color = color.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 10..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * percent, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(RadialPainter oldDelegate) => oldDelegate.percent != percent;
}