import 'package:flutter/material.dart';
import 'dart:ui';

// Page Imports
import '../pages/Landing Page/landing_page.dart';
import '../pages/dashboard/user_dashboard.dart';
import '../pages/monitoring/plant_health_page.dart';
import '../pages/soil_analysis/soil_analysis_page.dart';
import '../pages/dashboard/user_profile.dart';
import '../pages/monitoring/pest_detection_page.dart';
import '../pages/treatment/irrigation_fertilization_page.dart';
import '../pages/recommendation/crop_recommendation_page.dart';

class UserNavbar extends StatefulWidget {
  const UserNavbar({super.key});

  @override
  State<UserNavbar> createState() => _UserNavbarState();
}

class _UserNavbarState extends State<UserNavbar> {
  int _currentIndex = 0;
  bool isDarkMode = true;

  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color deepForest = Color(0xFF0A150F);

  // 1. ALL pages are now inside the IndexedStack to keep the navbar visible
  final List<Widget> _pages = [
    const LandingPage(),                // index 0
    const UserDashboard(),              // index 1
    const UserProfile(),                // index 2
    const SoilAnalysisPage(),           // index 3
    const PestDetectionPage(),          // index 4
    const IrrigationFertilizationPage(),// index 5
    const CropRecommendationPage(),     // index 6
    const PlantHealthPage(),            // index 7
  ];

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            color: deepForest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: sproutGreen.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("ARVA OPERATIONS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  children: [
                    // Instead of Navigator.push, we change the index of the IndexedStack
                    _buildOverlayItem(Icons.bug_report_rounded, 'PESTS', 4),
                    _buildOverlayItem(Icons.water_drop_rounded, 'TREATMENT', 5),
                    _buildOverlayItem(Icons.auto_awesome_rounded, 'CROP RECOMMENDATION', 6),
                    _buildOverlayItem(Icons.center_focus_strong_rounded, 'PLANT HEALTH', 7),
                    _buildOverlayItem(Icons.science_rounded, 'SOIL ANALYSIS', 3),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlayItem(IconData icon, String label, int targetIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the menu
        setState(() {
          _currentIndex = targetIndex; // Switch the page inside the stack
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sproutGreen.withOpacity(0.1),
              border: Border.all(color: sproutGreen.withOpacity(0.2)),
            ),
            child: Icon(icon, color: sproutGreen, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color navBgColor = isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.6);

    return Scaffold(
      backgroundColor: isDarkMode ? deepForest : const Color(0xFFF6F8F6),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      // The IndexedStack now contains every page you want the navbar to stay on
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: navBgColor,
              border: Border(top: BorderSide(color: sproutGreen.withOpacity(0.3), width: 0.5)),
            ),
            child: BottomNavigationBar(
              // Logic to handle which icon stays "glowing" when sub-pages are active
              currentIndex: _getNavbarIndex(_currentIndex),
              onTap: (index) {
                if (index == 4) {
                  _showMoreMenu(context);
                } else {
                  setState(() => _currentIndex = index);
                }
              },
              backgroundColor: Colors.transparent,
              selectedItemColor: sproutGreen,
              unselectedItemColor: ironGrey.withOpacity(0.5),
              selectedFontSize: 10,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                _buildGlowItem(Icons.home_rounded, 'HOME', 0),
                _buildGlowItem(Icons.grid_view_rounded, 'DASHBOARD', 1),
                _buildGlowItem(Icons.person_rounded, 'PROFILE', 2),
                _buildGlowItem(Icons.science_rounded, 'SOIL', 3),
                _buildGlowItem(Icons.more_horiz_rounded, 'MORE', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to keep the correct navbar icon lit up even on sub-pages
  int _getNavbarIndex(int stackIndex) {
    if (stackIndex >= 4) return 4; // If we are on Pests/Water/AI/Health, highlight "MORE"
    return stackIndex;
  }

  BottomNavigationBarItem _buildGlowItem(IconData icon, String label, int navIndex) {
    bool isActive = _getNavbarIndex(_currentIndex) == navIndex;
    
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          if (isActive)
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: sproutGreen.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)],
              ),
            ),
          Icon(icon, color: isActive ? sproutGreen : ironGrey.withOpacity(0.8), size: 24),
        ],
      ),
      label: label,
    );
  }
}