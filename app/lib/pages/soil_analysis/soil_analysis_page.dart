import 'package:flutter/material.dart';

// Global color palette to ensure all classes can access them
class AppColors {
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color skyBlueDark = Color(0xFF007A8A);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0A150F);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color.fromARGB(255, 246, 248, 246);
}

class SoilAnalysisPage extends StatefulWidget {
  const SoilAnalysisPage({super.key});

  @override
  State<SoilAnalysisPage> createState() => _SoilAnalysisPageState();
}

class _SoilAnalysisPageState extends State<SoilAnalysisPage> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    // Theme-dependent variables
    final Color currentBg = isDarkMode ? AppColors.deepForest : AppColors.backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : AppColors.deepForest;
    final Color subTextColor = isDarkMode ? AppColors.ironGrey : AppColors.ironGrey.withValues(alpha: 0.8);
    final Color cardColor = isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: currentBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.sproutGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Soil Analysis',
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildThemeToggle(),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0, left: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.sproutGreen.withValues(alpha: 0.5), width: 1),
                boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: TextButton.icon(
                onPressed: () => print("Exporting..."),
                icon: const Icon(Icons.download, color: AppColors.sproutGreen, size: 18),
                label: const Text(
                  'EXPORT',
                  style: TextStyle(color: AppColors.sproutGreen, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Holistic Health Overview', icon: Icons.analytics, textColor: textColor),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildOverviewBar('Nutrients', 0.85, AppColors.sproutGreen, isDarkMode),
                    _buildOverviewBar('pH Balance', 0.68, AppColors.harvestGold, isDarkMode),
                    _buildOverviewBar('Moisture', 0.45, AppColors.skyBlue, isDarkMode),
                    _buildOverviewBar('Conductivity', 0.30, AppColors.ironGrey, isDarkMode),
                  ],
                ),
              ),
              
              const SizedBox(height: 35),
              SectionHeader(title: 'Nutrient Levels (NPK)', icon: Icons.science, textColor: textColor),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(child: NutrientCard(label: 'NITROGEN', value: '42', unit: 'mg/kg', color: AppColors.sproutGreen, isDarkMode: isDarkMode)),
                  const SizedBox(width: 10),
                  Expanded(child: NutrientCard(label: 'PHOSPHORUS', value: '18', unit: 'mg/kg', color: AppColors.harvestGold, isDarkMode: isDarkMode)),
                  const SizedBox(width: 10),
                  Expanded(child: NutrientCard(label: 'POTASSIUM', value: '156', unit: 'mg/kg', color: AppColors.skyBlue, isDarkMode: isDarkMode)),
                ],
              ),

              const SizedBox(height: 30),
              SectionHeader(title: 'Soil pH & Moisture', icon: Icons.water_drop, textColor: textColor),
              const SizedBox(height: 15),

              InfoCard(
                isDarkMode: isDarkMode,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('pH Balance', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontSize: 16)),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: '6.8 ', style: const TextStyle(color: AppColors.sproutGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                              TextSpan(text: 'Neutral', style: TextStyle(color: subTextColor, fontSize: 14)),
                            ]
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PHSlider(phValue: 6.8, isDarkMode: isDarkMode), 
                  ],
                ),
              ),
              
              const SizedBox(height: 15),

              InfoCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Volumetric Water Content', style: TextStyle(color: subTextColor, fontSize: 14)),
                        const Text('32% Optimal', style: TextStyle(color: AppColors.sproutGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    MoistureIndicator(level: 5, isDarkMode: isDarkMode),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      isDarkMode: isDarkMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.thermostat, color: AppColors.harvestGold, size: 16),
                              const SizedBox(width: 4),
                              Text('Soil Temp', style: TextStyle(color: subTextColor, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('24.2°C', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoCard(
                      isDarkMode: isDarkMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: AppColors.skyBlue, size: 16),
                              const SizedBox(width: 4),
                              Text('Conductivity', style: TextStyle(color: subTextColor, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('1.2 dS/m', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.sproutGreen.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -5),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/irrigation_fertilization'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sproutGreen,
                    foregroundColor: isDarkMode ? Colors.white : AppColors.deepForest,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.precision_manufacturing),
                      SizedBox(width: 12),
                      Text('TREAT DEFICIENCIES', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final Color iconColor = isDarkMode ? Colors.white : AppColors.deepForest;
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = !isDarkMode),
      child: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconColor.withValues(alpha: 0.1),
          border: Border.all(color: iconColor.withValues(alpha: 0.1)),
        ),
        child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildOverviewBar(String label, double value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
              Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1),
                    ],
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Custom Components ---

class PHSlider extends StatelessWidget {
  final double phValue;
  final bool isDarkMode;
  const PHSlider({super.key, required this.phValue, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.greenAccent, Colors.blueAccent],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                double position = (phValue / 14) * constraints.maxWidth;
                return Positioned(
                  left: position - 4,
                  child: Container(
                    height: 24,
                    width: 8,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white : AppColors.deepForest,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.5), blurRadius: 12),
                      ]
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ACIDIC', style: TextStyle(color: AppColors.ironGrey, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('NEUTRAL', style: TextStyle(color: AppColors.ironGrey, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('ALKALINE', style: TextStyle(color: AppColors.ironGrey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  const InfoCard({super.key, required this.child, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

class NutrientCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final bool isDarkMode;
  const NutrientCard({super.key, required this.label, required this.value, required this.unit, required this.color, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: isDarkMode ? [] : [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(color: isDarkMode ? Colors.white : AppColors.deepForest, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
               Text(unit, style: TextStyle(color: AppColors.ironGrey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color textColor;
  const SectionHeader({super.key, required this.title, required this.icon, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.sproutGreen, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class MoistureIndicator extends StatelessWidget {
  final int level;
  final bool isDarkMode;
  const MoistureIndicator({super.key, required this.level, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(8, (index) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 12,
          decoration: BoxDecoration(
            color: index < level ? AppColors.sproutGreen : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(2),
            boxShadow: index < level ? [BoxShadow(color: AppColors.sproutGreen.withValues(alpha: 0.3), blurRadius: 4)] : [],
          ),
        ),
      )),
    );
  }
}