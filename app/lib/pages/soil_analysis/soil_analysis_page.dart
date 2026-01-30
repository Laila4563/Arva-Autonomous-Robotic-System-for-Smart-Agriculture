import 'package:flutter/material.dart';
// import 'dart:ui' as ui;

// Global color palette to ensure all classes can access them
class AppColors {
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0A150F);
  static const Color ironGrey = Color(0xFF546E7A);
}

class SoilAnalysisPage extends StatelessWidget {
  const SoilAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepForest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.sproutGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Soil Analysis',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.sproutGreen.withValues(alpha: 0.5), width: 1),
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
              const SectionHeader(title: 'Holistic Health Overview', icon: Icons.analytics),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    _buildOverviewBar('Nutrients', 0.85, AppColors.sproutGreen),
                    _buildOverviewBar('pH Balance', 0.68, AppColors.harvestGold),
                    _buildOverviewBar('Moisture', 0.45, AppColors.skyBlue),
                    _buildOverviewBar('Conductivity', 0.30, AppColors.ironGrey),
                  ],
                ),
              ),
              
              const SizedBox(height: 35),
              const SectionHeader(title: 'Nutrient Levels (NPK)', icon: Icons.science),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  const Expanded(child: NutrientCard(label: 'NITROGEN', value: '42', unit: 'mg/kg', color: AppColors.sproutGreen)),
                  const SizedBox(width: 10),
                  const Expanded(child: NutrientCard(label: 'PHOSPHORUS', value: '18', unit: 'mg/kg', color: AppColors.harvestGold)),
                  const SizedBox(width: 10),
                  const Expanded(child: NutrientCard(label: 'POTASSIUM', value: '156', unit: 'mg/kg', color: AppColors.skyBlue)),
                ],
              ),

              const SizedBox(height: 30),
              const SectionHeader(title: 'Soil pH & Moisture', icon: Icons.water_drop),
              const SizedBox(height: 15),

              InfoCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('pH Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(text: '6.8 ', style: TextStyle(color: AppColors.sproutGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                              TextSpan(text: 'Neutral', style: TextStyle(color: AppColors.ironGrey, fontSize: 14)),
                            ]
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const PHSlider(phValue: 6.8), 
                  ],
                ),
              ),
              
              const SizedBox(height: 15),

              const InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Volumetric Water Content', style: TextStyle(color: AppColors.ironGrey, fontSize: 14)),
                        Text('32% Optimal', style: TextStyle(color: AppColors.sproutGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 15),
                    MoistureIndicator(level: 5),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.thermostat, color: AppColors.harvestGold, size: 16),
                              SizedBox(width: 4),
                              Text('Soil Temp', style: TextStyle(color: AppColors.ironGrey, fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('24.2°C', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bolt, color: AppColors.skyBlue, size: 16),
                              SizedBox(width: 4),
                              Text('Conductivity', style: TextStyle(color: AppColors.ironGrey, fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('1.2 dS/m', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    backgroundColor: AppColors.sproutGreen.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
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

  Widget _buildOverviewBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
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

// --- Custom Components (Now accessing AppColors globally) ---

class PHSlider extends StatelessWidget {
  final double phValue;
  const PHSlider({super.key, required this.phValue});

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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 12),
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
  const InfoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class NutrientCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const NutrientCard({super.key, required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(color: AppColors.ironGrey, fontSize: 10)),
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
  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.sproutGreen, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class MoistureIndicator extends StatelessWidget {
  final int level;
  const MoistureIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(8, (index) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 12,
          decoration: BoxDecoration(
            color: index < level ? AppColors.sproutGreen : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2),
            boxShadow: index < level ? [BoxShadow(color: AppColors.sproutGreen.withValues(alpha: 0.3), blurRadius: 4)] : [],
          ),
        ),
      )),
    );
  }
}