import 'dart:ui';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // 1. Logic variable to track the theme state
  bool isDarkMode = true;

  // Constants
  static const Color primaryColor = Color(0xFF13EC13);
  static const Color backgroundDark = Color(0xFF102210);
  static const Color backgroundLight = Color(0xFFF6F8F6);

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on the theme state
    final Color currentBg = isDarkMode ? backgroundDark : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : backgroundDark;
    final Color subTextColor = isDarkMode ? Colors.grey : Colors.black54;

    return Scaffold(
      backgroundColor: currentBg,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 1.0 : 0.3, // Fade image more in light mode
              child: Image.asset(
                'assets/images/Register Background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    currentBg.withValues(alpha: 0.4),
                    currentBg.withValues(alpha: 0.6),
                    currentBg,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRoundButton(Icons.arrow_back, textColor),
                        Row(
                          children: [
                            // 2. THE THEME TOGGLE BUTTON
                            _buildRoundButton(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              textColor,
                              onTap: () {
                                setState(() {
                                  isDarkMode = !isDarkMode;
                                });
                              },
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                  color: primaryColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "SYSTEM ONLINE",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      const Icon(Icons.precision_manufacturing,
                          color: primaryColor, size: 40),
                      const SizedBox(width: 10),
                      Text("ARVA",
                          style: TextStyle(
                              color: textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1)),
                    ],
                  ),
                  Text("Autonomous Agriculture Management System",
                      style: TextStyle(color: subTextColor, fontSize: 16)),

                  const SizedBox(height: 30),

                  // Form Panel
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: currentBg.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: textColor.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Register Account",
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            Text("Join the network of autonomous farming.",
                                style: TextStyle(
                                    color: subTextColor, fontSize: 14)),
                            const SizedBox(height: 24),

                            _buildInputLabel(Icons.person, "Full Name", subTextColor),
                            _buildTextField("John Cooper", textColor),
                            const SizedBox(height: 16),
                            _buildInputLabel(Icons.email, "Email Address", subTextColor),
                            _buildTextField("arva@gmail.com", textColor),
                            const SizedBox(height: 16),
                            _buildInputLabel(Icons.lock, "Password", subTextColor),
                            _buildTextField("••••••••", textColor, isPassword: true),

                            const SizedBox(height: 24),

                            // Create Account Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  debugPrint("Account Created");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: backgroundDark,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      if (states.contains(WidgetState.pressed)) {
                                        return backgroundDark.withValues(alpha: 0.2);
                                      }
                                      if (states.contains(WidgetState.hovered)) {
                                        return Colors.white.withValues(alpha: 0.2);
                                      }
                                      return null;
                                    },
                                  ),
                                  mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("CREATE ACCOUNT",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: subTextColor),
                        children: const [
                          TextSpan(
                            text: "Log In",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildInputLabel(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, Color textColor, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3F3F46)),
        filled: true,
        fillColor: textColor.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textColor.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }

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