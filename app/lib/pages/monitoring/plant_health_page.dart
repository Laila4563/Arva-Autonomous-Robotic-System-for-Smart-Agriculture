import 'package:flutter/material.dart';
import 'package:app/components/user_navbar.dart'; // Ensure this import is correct for your project path

class PlantHealthPage extends StatefulWidget {
  const PlantHealthPage({super.key});

  @override
  State<PlantHealthPage> createState() => _PlantHealthPageState();
}

class _PlantHealthPageState extends State<PlantHealthPage> {
  bool isDarkMode = true;

  // --- ARVA THEME COLORS ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color deepForest = Color(0xFF0A120A);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color backgroundLight = Color(0xFFF6F8F6);

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on theme state
    final Color currentBg = isDarkMode ? deepForest : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : deepForest;
    final Color cardColor = isDarkMode ? deepForest : Colors.white;

    return Scaffold(
      backgroundColor: currentBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP BAR (Back Button + Centered Title + Theme Switch) ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // BACK BUTTON (Left) - Fixed to return to UserNavbar
                      _buildRoundButton(
                        Icons.arrow_back_ios_new,
                        textColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserNavbar()),
                          );
                        },
                      ),
                      
                      // CENTERED TITLE
                      Expanded(
                        child: Text(
                          "Plant Health",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),

                      // THEME TOGGLE (Right)
                      _buildRoundButton(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        textColor,
                        onTap: () {
                          setState(() {
                            isDarkMode = !isDarkMode;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildSectionHeader("Disease Prevalence Analytics", textColor),
                const SizedBox(height: 12),
                _buildMainAnalyticsCard(cardColor, textColor),
                
                const SizedBox(height: 24),
                _buildSectionHeader("Neural Analysis Feed", textColor),
                const SizedBox(height: 12),

                // Analysis Cards
                _buildAnalysisCard(
                  title: "Apple Scab Leaf",
                  status: "UNHEALTHY",
                  statusColor: harvestGold,
                  confidence: "Confidence: 89%",
                  location: "Lat: 42.36 | Long: -71.05",
                  imagePath: "assets/images/apple scab leaf.jpg",
                  hasAdvice: true,
                  adviceText: "Fungicide: Apply Myclobutanil within 24 hours.",
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  title: "Strawberry Leaf",
                  status: "HEALTHY",
                  statusColor: sproutGreen,
                  confidence: "Confidence: 83%",
                  location: "Lat: 42.36 | Long: -71.02",
                  imagePath: "assets/images/strawberry leaf.jpg",
                  hasAdvice: false,
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  title: "Squash Mildew Leaf",
                  status: "UNHEALTHY",
                  statusColor: harvestGold,
                  confidence: "Confidence: 81%",
                  location: "Lat: 42.38 | Long: -71.09",
                  imagePath: "assets/images/Squash_Powdery_mildew_leaf.jpg",
                  hasAdvice: true,
                  adviceText: "Treatment: Apply sulfur-based fungicide.",
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  title: "Tomato Leaf",
                  status: "HEALTHY",
                  statusColor: sproutGreen,
                  confidence: "Confidence: 94%",
                  location: "Lat: 42.37 | Long: -71.06",
                  imagePath: "assets/images/tomato leaf.jpg",
                  hasAdvice: false,
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

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
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const Text(
          "LIVE SYNC",
          style: TextStyle(color: skyBlue, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMainAnalyticsCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ironGrey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: sproutGreen.withValues(alpha: isDarkMode ? 0.08 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressBar("Healthy Population", 0.84, sproutGreen, textColor),
          const SizedBox(height: 16),
          _buildProgressBar("Unhealthy Population", 0.12, harvestGold, textColor, isSmall: true),
          const Divider(color: ironGrey, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("INCIDENCE", "Low"),
              _buildStatItem("SPREAD", "-1.2%", color: harvestGold),
              _buildStatItem("RISK", "Stable", color: sproutGreen),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color, Color textColor, {bool isSmall = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: isSmall ? 9 : 11, fontWeight: FontWeight.bold)),
            Text("${(value * 100).toInt()}%", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withValues(alpha: 0.1),
          color: color,
          minHeight: isSmall ? 6 : 8,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, {Color color = skyBlue}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: ironGrey, fontSize: 8, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required String status,
    required Color statusColor,
    required String confidence,
    required String location,
    required String imagePath,
    required Color cardColor,
    required Color textColor,
    bool hasAdvice = false,
    String adviceText = "",
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 110, height: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(11), bottomLeft: Radius.circular(11)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(11), bottomLeft: Radius.circular(11)),
                  child: Image.asset(
                    imagePath, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.eco,
                      color: Colors.white24,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                            child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                          ),
                          Text(confidence, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(location, style: const TextStyle(color: skyBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        if (hasAdvice) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: harvestGold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services, color: harvestGold, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(adviceText, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 11))),
              ],
            ),
          )
        ]
      ],
    );
  }
}