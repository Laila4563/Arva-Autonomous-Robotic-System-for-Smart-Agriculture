import 'package:flutter/material.dart';

class CropRecommendationPage extends StatefulWidget {
  const CropRecommendationPage({super.key});

  @override
  State<CropRecommendationPage> createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage> {
  bool isLiveMode = true;
  bool isDarkMode = true;

  // --- THEME COLORS (Synced Exactly with Registration Page) ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color skyBlueDark = Color(0xFF007A8A);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF102210);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color(0xFFF6F8F6);


  // Dynamic Color Getters
  Color get bgColor => isDarkMode ? deepForest : backgroundLight;
  Color get cardColor => isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : deepForest;
  Color get subTextColor => isDarkMode ? skyBlue : skyBlueDark;

  final Map<String, TextEditingController> _controllers = {
    "N": TextEditingController(text: "95"),
    "P": TextEditingController(text: "50"),
    "K": TextEditingController(text: "55"),
    "Temp": TextEditingController(text: "28"),
    "pH": TextEditingController(text: "7.6"),
    "Humidity": TextEditingController(text: "80"),
  };

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.precision_manufacturing, color: sproutGreen),
            ),
            const SizedBox(width: 12),
            Text(
              "ARVA",
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildRoundButton(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              textColor,
              onTap: () => setState(() => isDarkMode = !isDarkMode),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildModeSwitch(),
            const SizedBox(height: 30),
            _buildSectionHeader(),
            const SizedBox(height: 16),
            _buildSensorGrid(),

            if (isLiveMode) ...[
              const SizedBox(height: 32),
              _buildCropSection(
                cropName: "RICE",
                imagePath: "assets/images/rice crop.jpg",
                season: "Summer",
                water: "Irrigated",
                soils: "Alluvial, Loamy, Clay",
                sowing: "Jun to Jul",
                harvest: "Sep to Oct",
                growthCycle: "110 - 150 days",
              ),
              const SizedBox(height: 32),
              _buildCropSection(
                cropName: "COTTON",
                imagePath: "assets/images/cotton crop.jpg",
                season: "Summer",
                water: "Irrigated, Rainfed",
                soils: "Black Soil, Red Soil, Alluvial Soil",
                sowing: "Jun to Jul",
                harvest: "Sep to Oct",
                growthCycle: "135 - 140 days",
              ),
            ] else ...[
              const SizedBox(height: 32),
              _buildManualActionButton(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildCropSection({required String cropName, required String imagePath, required String season, required String water, required String soils, required String sowing, required String harvest, required String growthCycle}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: sproutGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: sproutGreen.withValues(alpha: 0.3), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🌾", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text("RECOMMENDED: $cropName", style: const TextStyle(color: deepForest, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ironGrey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STACK ADDED: Overlays the badge on the crop image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.asset(imagePath, height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: harvestGold, width: 1.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: harvestGold, size: 14),
                          SizedBox(width: 6),
                          Text(
                            "OPTIMAL MATCH FOUND",
                            style: TextStyle(
                              color: harvestGold  ,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStyledRow("SEASON", season, "WATER", water),
                    const SizedBox(height: 15),
                    _buildStyledItem("SUITABLE SOILS", soils),
                    const SizedBox(height: 15),
                    _buildStyledRow("SOWING", sowing, "HARVEST", harvest),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [const Icon(Icons.timer_outlined, color: sproutGreen, size: 18), const SizedBox(width: 8), Text("GROWTH CYCLE", style: TextStyle(color: subTextColor.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold))]),
                          Text(growthCycle, style: const TextStyle(color: harvestGold, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ironGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildSwitchTab("Real-Time Sensor Data", isLiveMode, true),
          _buildSwitchTab("User-Provided Data", !isLiveMode, false),
        ],
      ),
    );
  }

  Widget _buildSwitchTab(String label, bool active, bool isLeft) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLiveMode = isLeft),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? (isDarkMode ? sproutGreen.withValues(alpha: 0.2) : sproutGreen) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? (isDarkMode ? sproutGreen : Colors.white) : subTextColor.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorBox(String label, TextEditingController controller, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ironGrey.withValues(alpha: 0.2)),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: subTextColor, fontSize: 8, fontWeight: FontWeight.w800)),
          if (isLiveMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(controller.text, style: TextStyle(color: harvestGold, fontSize: 23, fontWeight: FontWeight.bold)),
                const SizedBox(width: 2),
                Text(unit, style: TextStyle(color: harvestGold, fontSize: 8, fontWeight: FontWeight.w400)),
              ],
            )
          else
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(color: harvestGold, fontSize: 23, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixText: unit,
                suffixStyle: const TextStyle(color: harvestGold, fontSize: 8),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: sproutGreen.withValues(alpha: 0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: sproutGreen)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("ENVIRONMENTAL DATA", style: TextStyle(color: sproutGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        if (isLiveMode) Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: harvestGold.withValues(alpha: 0.5))),
          child: const Row(children: [Icon(Icons.circle, color: harvestGold, size: 8), SizedBox(width: 6), Text("LIVE", style: TextStyle(color: harvestGold, fontSize: 9, fontWeight: FontWeight.bold))]),
        ),
      ],
    );
  }

  Widget _buildSensorGrid() {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3, // Change to 2 if you want larger manual input boxes
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: isLiveMode ? 1.1 : 1.1, // Adjust height specifically for manual entry
    children: [
      _buildSensorBox("NITROGEN", _controllers["N"]!, "mg/kg"),
      _buildSensorBox("PHOSPHORUS", _controllers["P"]!, "mg/kg"),
      _buildSensorBox("POTASSIUM", _controllers["K"]!, "mg/kg"),
      _buildSensorBox("TEMP", _controllers["Temp"]!, "°C"),
      _buildSensorBox("pH", _controllers["pH"]!, ""),
      _buildSensorBox("HUMIDITY", _controllers["Humidity"]!, "%"),
    ],
  );
}

  Widget _buildManualActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: sproutGreen,
          foregroundColor: deepForest,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("RECOMMEND A CROP", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildStyledRow(String l1, String v1, String l2, String v2) {
    return Row(children: [Expanded(child: _buildStyledItem(l1, v1)), const SizedBox(width: 16), Expanded(child: _buildStyledItem(l2, v2))]);
  }

  Widget _buildStyledItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(border: Border(left: BorderSide(color: ironGrey, width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: subTextColor.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1), border: Border.all(color: color.withValues(alpha: 0.1))),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}