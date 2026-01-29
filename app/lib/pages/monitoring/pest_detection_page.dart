import 'package:flutter/material.dart';

class PestDetectionPage extends StatefulWidget {
  const PestDetectionPage({super.key});

  @override
  State<PestDetectionPage> createState() => _PestDetectionPageState();
}

class _PestDetectionPageState extends State<PestDetectionPage> {
  bool isDarkMode = true;

  // --- THEME COLORS (Matched to Registration Page) ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7); 
  static const Color skyBlueDark = Color(0xFF007A8A); 
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF102210);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color alertHigh = Color(0xFFFF4D4D);

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on theme state
    final Color currentBg = isDarkMode ? deepForest : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : deepForest;
    final Color subTextColor = isDarkMode ? skyBlue : skyBlueDark;
    
    // Updated with .withValues to fix deprecation
    final Color cardColor = isDarkMode 
        ? Colors.white.withValues(alpha: 0.05) 
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: currentBg,
      appBar: AppBar(
        backgroundColor: currentBg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Pest Detection",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: harvestGold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "LIVE FEED - ARVA-04",
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildRoundButton(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              textColor,
              onTap: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE VIEWER SECTION ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: ironGrey.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/pest detection.jpg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(-0.7, 0.0),
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              "Image not found",
                              style: TextStyle(color: alertHigh),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- INFO SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pest Detected",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Potential pest presence identified in Sector B-12",
                    style: TextStyle(
                      color: sproutGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // --- CONFIDENCE CARD ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ironGrey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CONFIDENCE",
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    Text(
                      "70%",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: sproutGreen, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Neural Core v4",
                          style: TextStyle(
                            color: sproutGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- DETECTION ALERT CARD ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: alertHigh.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: alertHigh.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report, color: alertHigh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Detection Alert",
                          style: TextStyle(
                            color: alertHigh,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "A potential pest presence has been identified in the current field segment.",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Updated Helper Widget with .withValues()
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
}