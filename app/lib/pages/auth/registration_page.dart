import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Required for TapGestureRecognizer

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool isDarkMode = true;

  // --- THEME COLORS ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7); // Good for Dark Mode
  static const Color skyBlueDark = Color(
    0xFF007A8A,
  ); // Better contrast for Light Mode
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF102210);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color.fromARGB(
    255,
    246,
    248,
    246,
  ); // Increased opacity for stability

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on theme state
    final Color currentBg = isDarkMode ? deepForest : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : deepForest;

    // UPDATED: Now picks a darker blue for light mode so it doesn't disappear
    final Color subTextColor = isDarkMode ? skyBlue : skyBlueDark;

    return Scaffold(
      backgroundColor: currentBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 0.4 : 0.1,
              child: Image.asset(
                'assets/images/Register Background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    currentBg.withValues(alpha: 0.4),
                    currentBg.withValues(alpha: 0.7),
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
                  // Top Bar
Padding(
  padding: const EdgeInsets.symmetric(vertical: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // This pushes items to far left and far right
    children: [
      // Left Side: System Status
      Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: const BoxDecoration(
              color: harvestGold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "SYSTEM ONLINE",
            style: TextStyle(
              color: sproutGreen,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      // Right Side: Theme Toggle
      _buildRoundButton(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        textColor,
        onTap: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    ],
  ),
),

                  // Logo Section
                  Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: ironGrey.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ARVA",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Container(height: 2, width: 40, color: sproutGreen),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Autonomous Agriculture Management System",
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),

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
                            color: ironGrey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Join the network of autonomous farming.",
                              style: TextStyle(
                                color: subTextColor.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildInputLabel(
                              Icons.person,
                              "Full Name",
                              isDarkMode ? sproutGreen : sproutGreen,
                            ),
                            _buildTextField(
                              "John Cooper",
                              textColor,
                              isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildInputLabel(
                              Icons.email,
                              "Email Address",
                              isDarkMode ? sproutGreen : sproutGreen,
                            ),
                            _buildTextField(
                              "name@example.com",
                              textColor,
                              isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildInputLabel(
                              Icons.lock,
                              "Password",
                              isDarkMode ? sproutGreen : sproutGreen,
                            ),
                            _buildTextField(
                              "••••••••",
                              textColor,
                              isDarkMode,
                              isPassword: true,
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: sproutGreen,
                                  foregroundColor: deepForest,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.resolveWith<
                                    Color?
                                  >((Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return harvestGold.withValues(alpha: 0.3);
                                    }
                                    return null;
                                  }),
                                  mouseCursor: WidgetStateProperty.all(
                                    SystemMouseCursors.click,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "CREATE ACCOUNT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
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
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: subTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                            // This recognizer handles the click event
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate back to the Login Page
                                    Navigator.pushNamed(context, '/');
                                  },
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
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    Color textColor,
    bool dark, {
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: dark ? Colors.white24 : Colors.black26),
        filled: true,
        fillColor:
            dark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ironGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: sproutGreen, width: 2),
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
