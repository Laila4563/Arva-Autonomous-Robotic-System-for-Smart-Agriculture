import 'package:flutter/material.dart';

class PlantHealthPage extends StatelessWidget {
  const PlantHealthPage({super.key});

  // Custom Color Palette matching the Login Theme
  static const Color primaryGreen = Color(0xFF88B04B); // Sprout Green
  static const Color backgroundDark = Color(0xFF0A120A); // Deep Forest
  static const Color surfaceDark = Color(0xFF5D4037); // Rich Bark
  static const Color charcoal = Color(0xFF546E7A); // Iron Grey
  static const Color accentOrange = Color(0xFFE69F21); // Harvest Gold
  static const Color skyBlue = Color(0xFF56B9C7); // Sky Blue

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        // Updated to .withValues for the latest Flutter standard
        backgroundColor: backgroundDark.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Plant Health",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                "Disease Prevalence Analytics",
                "Global Field View",
              ),
              const SizedBox(height: 12),
              _buildMainAnalyticsCard(),
              const SizedBox(height: 24),
              _buildSectionHeader("Neural Analysis Feed", "Live Detection"),
              const SizedBox(height: 12),

              _buildAnalysisCard(
                title: "Apple Scab Leaf",
                status: "UNHEALTHY",
                statusColor: accentOrange,
                confidence: "Confidence: 89%",
                location: "Lat: 42.36 | Long: -71.05",
                imagePath: "assets/images/apple scab leaf.jpg",
                hasAdvice: true,
                adviceText:
                    "Fungicide: Apply Myclobutanil within 24 hours and remove infected leaves to reduce spread.",
              ),
              const SizedBox(height: 16),
              _buildAnalysisCard(
                title: "Strawberry Leaf",
                status: "HEALTHY",
                statusColor: primaryGreen,
                confidence: "Confidence: 83%",
                location: "Lat: 42.36 | Long: -71.02",
                imagePath: "assets/images/strawberry leaf.jpg",
                hasAdvice: false,
              ),
              const SizedBox(height: 16),
              _buildAnalysisCard(
                title: "Squash Mildew Leaf",
                status: "UNHEALTHY",
                statusColor: accentOrange,
                confidence: "Confidence: 81%",
                location: "Lat: 42.38 | Long: -71.09",
                imagePath: "assets/images/Squash_Powdery_mildew_leaf.jpg",
                hasAdvice: true,
                adviceText:
                    "Treatment: Apply sulfur-based fungicide or potassium bicarbonate.",
              ),
              const SizedBox(height: 16),
              _buildAnalysisCard(
                title: "Tomato Leaf",
                status: "HEALTHY",
                statusColor: primaryGreen,
                confidence: "Confidence: 94%",
                location: "Lat: 42.37 | Long: -71.06",
                imagePath: "assets/images/tomato leaf.jpg",
                hasAdvice: false,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle.toUpperCase(),
          style: const TextStyle(
            color: skyBlue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMainAnalyticsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: charcoal),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressBar("Healthy Population", 0.84, primaryGreen),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressBar(
                  "Unhealthy Population",
                  0.12,
                  accentOrange,
                  isSmall: true,
                ),
              ),
            ],
          ),
          const Divider(color: charcoal, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Incidence", "Low"),
              _buildStatItem("Spread Rate", "-1.2%", color: accentOrange),
              _buildStatItem("Risk Level", "Stable", color: primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double value,
    Color color, {
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: isSmall ? 9 : 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          color: color,
          minHeight: isSmall ? 6 : 8,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: skyBlue,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    bool hasAdvice = false,
    String adviceText = "",
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundDark.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            confidence,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          color: skyBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasAdvice) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentOrange.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: accentOrange.withValues(alpha: 0.05), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: accentOrange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    adviceText,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}