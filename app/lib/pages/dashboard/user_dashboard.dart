import 'package:flutter/material.dart';
import 'dart:ui';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // --- THEME STATE ---
  bool isDarkMode = true;

  // --- THEME COLORS ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color skyBlueDark = Color(0xFF007A8A);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0D1402);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color.fromARGB(255, 246, 248, 246);

  // Reusable Glass Card updated with .withValues() and Light/Dark logic
  Widget _buildGlassCard({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF0D1402).withValues(alpha: 0.8) 
                : Colors.white.withValues(alpha: 0.7),
            border: Border.all(color: ironGrey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on theme state
    final Color currentBg = isDarkMode ? deepForest : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : deepForest;
    final Color subTextColor = isDarkMode ? skyBlue : skyBlueDark;

    return Scaffold(
      backgroundColor: currentBg,
      body: Stack(
        children: [
          // Background Glows/Particles
          Positioned(top: 100, left: 40, child: _buildParticle(sproutGreen, 4, 4)),
          Positioned(bottom: 200, right: 80, child: _buildParticle(subTextColor, 6, 6)),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column( 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER with round toggle button
                  _buildHeader(textColor, subTextColor),
                  const SizedBox(height: 10),
                  Container(height: 1, color: ironGrey.withValues(alpha: 0.2)),
                  const SizedBox(height: 20),

                  // 1. Atmospheric Data
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildSectionHeader("ATMOSPHERIC DATA", Icons.cloud_sync, subTextColor),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDataOrb("24.5°", "Ambient Temp", Icons.sunny, sproutGreen, textColor),
                            _buildDataOrb("62%", "Humidity", Icons.air, subTextColor, textColor),
                            _buildDataOrb("0.02", "Precipitation", Icons.water_drop, harvestGold, textColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Soil Nutrient Analysis
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "SOIL NUTRIENT ANALYSIS",
                              style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                            _buildHologramTag("SCAN_ACTIVE", sproutGreen),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 140,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildGaugeBar("N", 0.72, sproutGreen),
                                    _buildGaugeBar("P", 0.58, subTextColor),
                                    _buildGaugeBar("K", 0.65, harvestGold),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _buildSideStat("Soil pH", "6.8", "pH", subTextColor, textColor),
                                  const SizedBox(height: 8),
                                  _buildSideStat("Moisture Level", "42", "%", harvestGold, textColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Tactical Unit
                  _buildGlassCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Arva Robot State", style: TextStyle(color: sproutGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                            _buildHologramTag("ID: ARVA-0092", ironGrey),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildBatteryCircle(harvestGold, textColor),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(child: _buildSmallInfoCard("Power State", "OPTIMAL", Icons.bolt, sproutGreen)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildSmallInfoCard("Latency", "14ms", Icons.router, subTextColor)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 4. Neural Detection Log
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 16.0),
                    child: Text(
                      "NEURAL DETECTION LOG",
                      style: TextStyle(color: ironGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildDetectionItem("Tomato Late Blight", "LOC: 42.12N / 12.04W", "Unhealthy", harvestGold, textColor),
                        const Divider(color: Colors.white10, height: 20),
                        _buildDetectionItem("Powdery Mildew", "LOC: 42.13N / 12.05W", "Unhealthy", harvestGold, textColor),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Center(child: Text("LINK: UPLINK_STABLE", style: TextStyle(color: textColor.withValues(alpha: 0.1), fontSize: 8, letterSpacing: 2))),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Theme-Matched Helpers ---

  Widget _buildHeader(Color txtColor, Color subTxt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "WELCOME BACK, USER",
              style: TextStyle(color: sproutGreen, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            Text(
              "GROWTH ANALYTICS: ACTIVE",
              style: TextStyle(color: subTxt.withValues(alpha: 0.7), fontSize: 9, letterSpacing: 1.5),
            ),
          ],
        ),
        _buildRoundButton(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          txtColor,
          onTap: () {
            setState(() {
              isDarkMode = !isDarkMode;
            });
          },
        ),
      ],
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

  Widget _buildSectionHeader(String title, IconData icon, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 16),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const Text("LIVE TELEMETRY", style: TextStyle(color: ironGrey, fontSize: 8)),
      ],
    );
  }

  Widget _buildDataOrb(String val, String label, IconData icon, Color accent, Color txtColor) {
    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2)],
            gradient: RadialGradient(colors: [accent.withValues(alpha: 0.15), Colors.transparent], stops: const [0.3, 1.0]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(height: 2),
              Text(val, style: TextStyle(color: txtColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label.toUpperCase(), style: const TextStyle(color: ironGrey, fontSize: 7, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGaugeBar(String label, double pct, Color primary) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 14,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: FractionallySizedBox(
              heightFactor: pct,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [primary, Colors.white.withValues(alpha: 0.5)]),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSideStat(String label, String val, String unit, Color accent, Color txtColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), border: Border(left: BorderSide(color: accent, width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: ironGrey, fontSize: 7)),
          Row(
            children: [
              Text(val, style: TextStyle(color: txtColor, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBatteryCircle(Color accent, Color txtColor) {
    return Container(
      width: 170, height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 5)],
        gradient: RadialGradient(colors: [accent.withValues(alpha: 0.1), Colors.transparent], stops: const [0.4, 1.0]),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160, height: 160,
            child: CircularProgressIndicator(value: 0.88, strokeWidth: 6, color: accent, backgroundColor: isDarkMode ? Colors.white10 : Colors.black12),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("BATTERY", style: TextStyle(color: ironGrey, fontSize: 9, fontWeight: FontWeight.bold)),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("88", style: TextStyle(color: txtColor, fontSize: 48, fontWeight: FontWeight.bold)),
                  Text("%", style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallInfoCard(String label, String val, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: accent, width: 2))),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: ironGrey, fontSize: 8)),
              Text(val, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetectionItem(String disease, String location, String level, Color levelColor, Color txtColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.psychology, color: ironGrey, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(disease, style: TextStyle(color: txtColor, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(location, style: const TextStyle(color: ironGrey, fontSize: 9, fontFamily: 'monospace')),
            ],
          ),
        ),
        _buildHologramTag(level, levelColor),
      ],
    );
  }

  Widget _buildHologramTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), border: Border.all(color: color.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildParticle(Color color, double w, double h) {
    return Container(width: w, height: h, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2)));
  }
}