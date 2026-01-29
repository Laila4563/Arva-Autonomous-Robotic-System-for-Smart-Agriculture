import 'package:flutter/material.dart';

class SoilAnalysisPage extends StatelessWidget {
  const SoilAnalysisPage({super.key});

  // Color Palette Definitions
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0A150F); 
  static const Color richBark = Color(0xFF5D4037);  
  static const Color ironGrey = Color(0xFF546E7A);  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepForest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: sproutGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Soil Analysis',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
                  color: richBark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ironGrey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildOverviewBar('Nutrients', 0.85, sproutGreen),
                    _buildOverviewBar('pH Balance', 0.68, harvestGold),
                    _buildOverviewBar('Moisture', 0.45, skyBlue),
                    _buildOverviewBar('Conductivity', 0.30, ironGrey),
                  ],
                ),
              ),
              
              const SizedBox(height: 35),
              const SectionHeader(title: 'Nutrient Levels (NPK)', icon: Icons.science),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(child: NutrientCard(label: 'NITROGEN', value: '42', unit: 'mg/kg', color: sproutGreen)),
                  const SizedBox(width: 10),
                  Expanded(child: NutrientCard(label: 'PHOSPHORUS', value: '18', unit: 'mg/kg', color: harvestGold)),
                  const SizedBox(width: 10),
                  Expanded(child: NutrientCard(label: 'POTASSIUM', value: '156', unit: 'mg/kg', color: skyBlue)),
                ],
              ),

              const SizedBox(height: 30),
              const SectionHeader(title: 'Soil pH & Moisture', icon: Icons.water_drop),
              const SizedBox(height: 15),

              // Updated pH Balance Card to match image
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
                              TextSpan(text: '6.8 ', style: TextStyle(color: sproutGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                              TextSpan(text: 'Neutral', style: TextStyle(color: ironGrey, fontSize: 14)),
                            ]
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const PHSlider(phValue: 6.8), // Now takes actual pH value 0-14
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
                        Text('Volumetric Water Content', style: TextStyle(color: ironGrey, fontSize: 14)),
                        Text('32% Optimal', style: TextStyle(color: sproutGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 15),
                    MoistureIndicator(level: 5),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.thermostat, color: harvestGold, size: 16),
                              const SizedBox(width: 4),
                              const Text('Soil Temp', style: TextStyle(color: ironGrey, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('24.2°C', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bolt, color: skyBlue, size: 16),
                              const SizedBox(width: 4),
                              const Text('Conductivity', style: TextStyle(color: ironGrey, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('1.2 dS/m', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/irrigation_fertilization'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sproutGreen,
                  foregroundColor: deepForest,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 30), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value,
            backgroundColor: ironGrey.withValues(alpha: 0.1),
            color: color.withValues(alpha: 0.4),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// --- Custom Components ---

class PHSlider extends StatelessWidget {
  final double phValue; // Value between 0 and 14
  const PHSlider({super.key, required this.phValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Segmented Track
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 12,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(flex: 7, child: Container(color: Colors.redAccent.withOpacity(0.6))),
                    Expanded(flex: 3, child: Container(color: Colors.greenAccent)),
                    Expanded(flex: 4, child: Container(color: Colors.blueAccent.withOpacity(0.6))),
                  ],
                ),
              ),
            ),
            // The Indicator Bar
            LayoutBuilder(
              builder: (context, constraints) {
                double position = (phValue / 14) * constraints.maxWidth;
                return Positioned(
                  left: position - 2,
                  child: Container(
                    height: 24,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)
                      ]
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Labels below the bar
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ACIDIC (0)', style: TextStyle(color: Color(0xFF546E7A), fontSize: 10, fontWeight: FontWeight.bold)),
            Text('NEUTRAL (7)', style: TextStyle(color: Color(0xFF546E7A), fontSize: 10, fontWeight: FontWeight.bold)),
            Text('ALKALINE (14)', style: TextStyle(color: Color(0xFF546E7A), fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        )
      ],
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
        color: const Color(0xFF5D4037).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
            ],
          ),
        ],
      ),
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
        color: const Color(0xFF5D4037).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF546E7A).withValues(alpha: 0.2)),
      ),
      child: child,
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
        Icon(icon, color: const Color(0xFF88B04B), size: 18),
        const SizedBox(width: 8),
        Text(
          title, 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
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
          height: 16,
          decoration: BoxDecoration(
            color: index < level 
                ? const Color(0xFF88B04B) 
                : const Color(0xFF546E7A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
    );
  }
}