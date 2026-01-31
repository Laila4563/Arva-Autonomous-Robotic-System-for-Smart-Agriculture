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
  bool isLoggedIn = false; // Initial state: Logged out

  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color deepForest = Color(0xFF0A150F);

  // --- AUTH LOGIC ---
  void loginUser() {
    setState(() {
      isLoggedIn = true;
      _currentIndex = 1; // Auto-jump to Dashboard on login
    });
  }

  void logoutUser() {
    setState(() {
      isLoggedIn = false;
      _currentIndex = 0; // Return to Home on logout
    });
  }

  // 1. DYNAMIC PAGE LIST
  List<Widget> get _pages {
    if (!isLoggedIn) {
      return [
        LandingPage(isLoggedIn: isLoggedIn, onLoginSuccess: loginUser, onLogout: logoutUser), // index 0
        const SoilAnalysisPage(),             // index 1
        const PestDetectionPage(),            // index 2
        const IrrigationFertilizationPage(),  // index 3
        const CropRecommendationPage(),       // index 4
        const PlantHealthPage(),              // index 5
      ];
    } else {
      return [
        LandingPage(isLoggedIn: isLoggedIn, onLoginSuccess: loginUser, onLogout: logoutUser), // index 0
        const UserDashboard(),                // index 1
        const UserProfile(),                  // index 2
        const SoilAnalysisPage(),             // index 3
        const PestDetectionPage(),            // index 4
        const IrrigationFertilizationPage(),  // index 5
        const CropRecommendationPage(),       // index 6
        const PlantHealthPage(),              // index 7
      ];
    }
  }

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
            border: Border.all(color: sproutGreen.withValues(alpha: 0.3), width: 1),
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
                  children: isLoggedIn 
                    ? [
                        _buildOverlayItem(Icons.bug_report_rounded, 'PESTS', 4),
                        _buildOverlayItem(Icons.water_drop_rounded, 'TREATMENT', 5),
                        _buildOverlayItem(Icons.auto_awesome_rounded, 'CROP', 6),
                        _buildOverlayItem(Icons.center_focus_strong_rounded, 'HEALTH', 7),
                        _buildOverlayItem(Icons.science_rounded, 'SOIL', 3),
                      ]
                    : [
                        _buildOverlayItem(Icons.bug_report_rounded, 'PESTS', 2),
                        _buildOverlayItem(Icons.water_drop_rounded, 'TREATMENT', 3),
                        _buildOverlayItem(Icons.auto_awesome_rounded, 'CROP', 4),
                        _buildOverlayItem(Icons.center_focus_strong_rounded, 'HEALTH', 5),
                        _buildOverlayItem(Icons.science_rounded, 'SOIL', 1),
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
        Navigator.pop(context);
        setState(() {
          _currentIndex = targetIndex;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sproutGreen.withValues(alpha: 0.1),
              border: Border.all(color: sproutGreen.withValues(alpha: 0.2)),
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
    final Color navBgColor = isDarkMode ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: isDarkMode ? deepForest : const Color(0xFFF6F8F6),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: navBgColor,
              border: Border(top: BorderSide(color: sproutGreen.withValues(alpha: 0.3), width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _getNavbarIndex(_currentIndex),
              onTap: (index) {
                int moreIndex = isLoggedIn ? 4 : 2;
                if (index == moreIndex) {
                  _showMoreMenu(context);
                } else {
                  setState(() => _currentIndex = index);
                }
              },
              backgroundColor: Colors.transparent,
              selectedItemColor: sproutGreen,
              unselectedItemColor: ironGrey.withValues(alpha: 0.5),
              selectedFontSize: 10,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: _buildNavbarItems(),
            ),
          ),
        ),
      ),
    );
  }

  // 2. DYNAMIC NAVBAR ITEMS
  List<BottomNavigationBarItem> _buildNavbarItems() {
    if (!isLoggedIn) {
      return [
        _buildGlowItem(Icons.home_rounded, 'HOME', 0),
        _buildGlowItem(Icons.science_rounded, 'SOIL', 1),
        _buildGlowItem(Icons.more_horiz_rounded, 'MORE', 2),
      ];
    } else {
      return [
        _buildGlowItem(Icons.home_rounded, 'HOME', 0),
        _buildGlowItem(Icons.grid_view_rounded, 'DASHBOARD', 1),
        _buildGlowItem(Icons.person_rounded, 'PROFILE', 2),
        _buildGlowItem(Icons.science_rounded, 'SOIL', 3),
        _buildGlowItem(Icons.more_horiz_rounded, 'MORE', 4),
      ];
    }
  }

  int _getNavbarIndex(int stackIndex) {
    if (!isLoggedIn) {
      return stackIndex >= 2 ? 2 : stackIndex;
    } else {
      return stackIndex >= 4 ? 4 : stackIndex;
    }
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
                boxShadow: [BoxShadow(color: sproutGreen.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 1)],
              ),
            ),
          Icon(icon, color: isActive ? sproutGreen : ironGrey.withValues(alpha: 0.8), size: 24),
        ],
      ),
      label: label,
    );
  }
}