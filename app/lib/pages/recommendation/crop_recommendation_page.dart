import 'package:flutter/material.dart';

class CropRecommendationPage extends StatefulWidget {
  const CropRecommendationPage({super.key});

  @override
  State<CropRecommendationPage> createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage> {
  bool isLiveMode = true;
  bool isDarkMode = true;

  final Color primaryGreen = const Color(0xFF13EC13);

  // Dynamic Colors
  Color get bgColor => isDarkMode ? const Color(0xFF060906) : const Color(0xFFF4F7F4);
  Color get cardColor => isDarkMode ? const Color(0xFF111611) : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF1B221B);
  Color get subTextColor => isDarkMode ? Colors.grey : const Color(0xFF5A6A5A);
  Color get accentGreen => isDarkMode ? primaryGreen : const Color(0xFF008A00);

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
            Icon(Icons.precision_manufacturing, color: primaryGreen, size: 28),
            const SizedBox(width: 10),
            Text(
              "ARVA",
              style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, color: primaryGreen, size: 20),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
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
              // --- CROP 1: RICE ---
              _buildCropSection(
                cropName: "RICE",
                imagePath: "assets/images/rice crop.jpg",
                season: "Summer",
                water: "Irrigated, Rainfed",
                soils: "Alluvial, Loamy, Clay",
                sowing: "Jun to Jul",
                harvest: "Sep to Oct",
                growthCycle: "110 - 150 days",
              ),
              const SizedBox(height: 32),
              // --- CROP 2: COTTON ---
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

  // --- NEW: Grouped Section (Banner + Card) ---
  Widget _buildCropSection({
    required String cropName,
    required String imagePath,
    required String season,
    required String water,
    required String soils,
    required String sowing,
    required String harvest,
    required String growthCycle,
  }) {
    return Column(
      children: [
        _buildCropBanner(cropName), // The Button-style name banner
        const SizedBox(height: 16),
        _buildDetailedCropCard(
          cropName: cropName,
          imagePath: imagePath,
          season: season,
          water: water,
          soils: soils,
          sowing: sowing,
          harvest: harvest,
          growthCycle: growthCycle,
        ),
      ],
    );
  }

  // --- The Banner Method (Button style with Name) ---
  Widget _buildCropBanner(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🌾", style: TextStyle(fontSize: 20)),
          Text(
            "RECOMMENDED CROP: $name",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCropCard({
    required String cropName,
    required String imagePath,
    required String season,
    required String water,
    required String soils,
    required String sowing,
    required String harvest,
    required String growthCycle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.asset(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.05),
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryGreen, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: primaryGreen, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        "OPTIMAL MATCH FOUND",
                        style: TextStyle(color: Color(0xFF13EC13), fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStyledRow("EGYPTIAN SEASON", season, "WATER SOURCES", water),
                const SizedBox(height: 20),
                _buildStyledItem("SUITABLE SOILS", soils),
                const SizedBox(height: 20),
                _buildStyledRow("SOWING PERIOD", sowing, "HARVEST PERIOD", harvest),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sync, color: primaryGreen, size: 22),
                          const SizedBox(width: 12),
                          Text("GROWTH CYCLE", style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Text(growthCycle, style: TextStyle(color: accentGreen, fontSize: 16, fontWeight: FontWeight.w900)),
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

  // --- Shared Mode Switch UI ---
  Widget _buildModeSwitch() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
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
            color: active ? (isDarkMode ? const Color(0xFF1A221A) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active && !isDarkMode ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(color: active ? accentGreen : subTextColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildSensorBox("NITROGEN (N)", _controllers["N"]!, "mg/kg"),
        _buildSensorBox("PHOSPHOROUS (P)", _controllers["P"]!, "mg/kg"),
        _buildSensorBox("POTASSIUM (K)", _controllers["K"]!, "mg/kg"),
        _buildSensorBox("TEMP", _controllers["Temp"]!, "°C"),
        _buildSensorBox("pH", _controllers["pH"]!, ""),
        _buildSensorBox("HUMIDITY", _controllers["Humidity"]!, "%"),
      ],
    );
  }

  Widget _buildSensorBox(String label, TextEditingController controller, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.transparent),
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
                Text(controller.text, style: TextStyle(color: accentGreen, fontSize: 23, fontWeight: FontWeight.bold)),
                const SizedBox(width: 2),
                Text(unit, style: TextStyle(color: accentGreen, fontSize: 8, fontWeight: FontWeight.w400)),
              ],
            )
          else
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(color: accentGreen, fontSize: 23, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixText: unit,
                suffixStyle: TextStyle(color: accentGreen, fontSize: 8),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentGreen.withOpacity(0.2))),
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
        Text("ENVIRONMENTAL PARAMETERS", style: TextStyle(color: accentGreen, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        if (isLiveMode) _buildSyncedBadge(),
      ],
    );
  }

  Widget _buildSyncedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.4)),
        boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: primaryGreen, size: 8),
          const SizedBox(width: 6),
          Text("SYNCED", style: TextStyle(color: accentGreen, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildManualActionButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.black,
        elevation: isDarkMode ? 0 : 4,
        shadowColor: primaryGreen.withOpacity(0.3),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text("RECOMMEND A CROP", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  Widget _buildStyledRow(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(child: _buildStyledItem(l1, v1)),
        const SizedBox(width: 16),
        Expanded(child: _buildStyledItem(l2, v2)),
      ],
    );
  }

  Widget _buildStyledItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: primaryGreen.withOpacity(0.3), width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: subTextColor, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}