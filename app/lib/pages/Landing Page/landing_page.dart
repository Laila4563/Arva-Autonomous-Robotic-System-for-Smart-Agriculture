import 'dart:ui';
import 'package:flutter/material.dart';
import '../auth/login_page.dart'; // Verify this path

class LandingPage extends StatefulWidget {
  // ✨ NEW: Parameters required for dynamic navbar logic
  final bool isLoggedIn;
  final VoidCallback onLoginSuccess;
  final VoidCallback onLogout;

  const LandingPage({
    super.key,
    required this.isLoggedIn,
    required this.onLoginSuccess,
    required this.onLogout,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;

  bool isDarkMode = true;

  static const Color primaryGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color skyBlueDark = Color(0xFF007A8A);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF1A1D15);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color(0xFFF6F8F6);

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentBg = isDarkMode ? deepForest : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : deepForest;
    final Color subTextColor = isDarkMode ? skyBlue : skyBlueDark;

    return Scaffold(
      backgroundColor: currentBg,
      appBar: AppBar(
        backgroundColor: currentBg.withValues(alpha: 0.8),
        elevation: 0,
        title: Text(
          "ARVA",
          style: TextStyle(
            color: isDarkMode ? Colors.white : deepForest,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          // ✨ DYNAMIC ACTION BUTTON (LOGIN OR LOGOUT)
          widget.isLoggedIn
              ? TextButton(
                  onPressed: widget.onLogout,
                  child: const Text(
                    "LOGOUT",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(
                          onLoginSuccess: widget.onLoginSuccess,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            color: isDarkMode ? Colors.white70 : deepForest,
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(currentBg, textColor),
            _buildCapabilitiesHeader(textColor, subTextColor),
            _buildCapabilitiesGrid(isDarkMode),
            _buildTechDetails(textColor),
            _buildSustainabilityHeader(textColor, subTextColor),
            _buildSustainabilityGrid(isDarkMode),
            _buildFooter(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Color bg, Color txt) {
    return Container(
      width: double.infinity,
      height: 550,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/crop bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkMode ? bg.withValues(alpha: 0.5) : bg.withValues(alpha: 0.45),
              bg,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ARVA: THE FUTURE OF",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "AUTONOMOUS\nFARMING",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: harvestGold,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Sleek industrial design meets precision agriculture. Command your fleet of low-profile, sensor-equipped titans.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.8) : deepForest,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 45),
            // GET STARTED BUTTON Logic
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                minimumSize: const Size(210, 54),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (widget.isLoggedIn) {
                  // If logged in, maybe scroll to capabilities or show a message
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        onLoginSuccess: widget.onLoginSuccess,
                      ),
                    ),
                  );
                }
              },
              child: Text(
                widget.isLoggedIn ? "EXPLORE FLEET" : "GET STARTED",
                style: TextStyle(
                  color: isDarkMode ? deepForest : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REST OF HELPER WIDGETS ---
  Widget _buildCapabilitiesHeader(Color txt, Color sub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 32, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: primaryGreen))),
              const SizedBox(width: 8),
              Text("OPERATIONS", style: TextStyle(color: sub, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Text("Core Capabilities", style: TextStyle(color: txt, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesGrid(bool dark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _capabilityCard(Icons.science, "Soil Analysis", "Deep insights", dark),
        _capabilityCard(Icons.eco, "Plant Health", "Real-time monitoring", dark),
        _capabilityCard(Icons.bug_report, "Pest Detection", "Early threat detection", dark),
        _capabilityCard(Icons.water_drop, "Irrigation", "Precision delivery", dark),
      ],
    );
  }

  Widget _capabilityCard(IconData icon, String title, String sub, bool dark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [
              BoxShadow(color: primaryGreen.withValues(alpha: dark ? 0.35 : 0.25), blurRadius: 28, spreadRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryGreen, size: 40),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: dark ? Colors.white : deepForest, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(sub.toUpperCase(), style: TextStyle(color: dark ? skyBlue : skyBlueDark, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechDetails(Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("High-Tech Precision", style: TextStyle(color: txt, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Our autonomous system integrates seamlessly.", style: TextStyle(color: txt.withValues(alpha: 0.6))),
          const SizedBox(height: 32),
          _techItem(Icons.verified_user, "Industrial Strength", "Low-profile chassis built for Egypt.", txt),
          _techItem(Icons.sensors, "Advanced LIDAR Array", "360-degree sensor suite.", txt),
        ],
      ),
    );
  }

  Widget _techItem(IconData icon, String title, String desc, Color txt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryGreen, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: txt.withValues(alpha: 0.6), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityHeader(Color txt, Color sub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 32, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: sub))),
              const SizedBox(width: 8),
              Text("ECO CONSCIOUS", style: TextStyle(color: sub, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Text("Sustainability & Stewardship", style: TextStyle(color: txt, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSustainabilityGrid(bool dark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _sustainabilityCard(icon: Icons.water_drop, label: "Water Efficiency", title: "70% Conservation", desc: "Intelligent mapping.", showProgress: true, dark: dark),
          const SizedBox(height: 16),
          _sustainabilityCard(icon: Icons.eco, label: "Resource Care", title: "Targeted Nutrients", desc: "Zero-waste system.", dark: dark),
          const SizedBox(height: 16),
          _sustainabilityCard(icon: Icons.bolt, label: "Clean Energy", title: "Zero Emission", desc: "100% electric.", isElectric: true, dark: dark),
        ],
      ),
    );
  }

  Widget _sustainabilityCard({required IconData icon, required String label, required String title, required String desc, required bool dark, bool showProgress = false, bool isElectric = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(icon, color: dark ? skyBlue : skyBlueDark, size: 24), const SizedBox(width: 8), Text(label.toUpperCase(), style: TextStyle(color: dark ? skyBlue : skyBlueDark, fontWeight: FontWeight.bold, fontSize: 12))]),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(color: dark ? Colors.white : deepForest, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(desc, style: TextStyle(color: dark ? Colors.white60 : ironGrey, fontSize: 14)),
              if (showProgress) ...[
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("CONSERVATION", style: TextStyle(color: dark ? skyBlue : skyBlueDark, fontSize: 10, fontWeight: FontWeight.bold)), const Text("70%", style: TextStyle(color: harvestGold, fontSize: 10, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: 0.7, backgroundColor: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), color: harvestGold, minHeight: 8)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Color txt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        children: [
          Container(height: 1, width: double.infinity, color: txt.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Text("READY FOR THE FUTURE?", style: TextStyle(color: txt.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3)),
          const SizedBox(height: 32),
          const Text("© 2026 ARVA ROBOTICS.", style: TextStyle(color: ironGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ],
      ),
    );
  }
}