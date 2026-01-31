import 'package:flutter/material.dart';
import 'dart:ui'; 
import 'package:app/pages/dashboard/admin_dashboard.dart';
import 'package:app/pages/management/user_management_page.dart';
import 'package:app/pages/dashboard/admin_profile.dart';

class AdminNavbar extends StatefulWidget {
  const AdminNavbar({super.key});

  @override
  State<AdminNavbar> createState() => _AdminNavbarState();
}

class _AdminNavbarState extends State<AdminNavbar> {
  int _currentIndex = 0;
  bool isDarkMode = true;

  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color deepForest = Color(0xFF0A150F);

  void _toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    final Color navBgColor = isDarkMode 
        ? Colors.black.withOpacity(0.5) 
        : Colors.white.withOpacity(0.6);

    final List<Widget> _pages = [
      AdminDashboard(isDarkMode: isDarkMode, onThemeToggle: _toggleTheme),
      UserManagementPage(isDarkMode: isDarkMode, onThemeToggle: _toggleTheme),
      AdminProfile(isDarkMode: isDarkMode, onThemeToggle: _toggleTheme),
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? deepForest : const Color(0xFFF6F8F6),
      // Use ResizeToAvoidBottomInset to prevent keyboard overflows
      resizeToAvoidBottomInset: false, 
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            // Remove hardcoded height to let BottomNavigationBar calculate it
            decoration: BoxDecoration(
              color: navBgColor,
              border: Border(
                top: BorderSide(
                  color: sproutGreen.withOpacity(0.3), 
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              selectedItemColor: sproutGreen,
              unselectedItemColor: ironGrey.withOpacity(0.5),
              selectedFontSize: 10,
              unselectedFontSize: 10,
              // Reduced padding to prevent overflow
              // padding: const EdgeInsets.only(top: 8, bottom: 8), 
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                _buildGlowItem(Icons.grid_view_rounded, 'DASHBOARD', 0),
                _buildGlowItem(Icons.people_alt_rounded, 'OPERATORS', 1),
                _buildGlowItem(Icons.admin_panel_settings_rounded, 'PROFILE', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildGlowItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          // The Glow Effect
          if (isActive)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: sproutGreen.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          // The Icon
          Icon(
            icon,
            color: isActive ? sproutGreen : ironGrey.withOpacity(0.8),
            size: 24, // Consistent size to prevent vertical shifting
          ),
        ],
      ),
      label: label,
    );
  }
}