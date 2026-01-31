import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  // ✨ NEW: Added callback to notify UserNavbar of a successful login
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool isDarkMode = true;

  // --- 1. CONTROLLERS FOR INPUT FIELDS ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- THEME COLORS ---
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color skyBlueDark = Color(0xFF007A8A);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0A150F);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color.fromARGB(255, 246, 248, 246);

  // --- 2. LOGIN LOGIC FUNCTION ---
  void _handleLogin() {
  final String email = _emailController.text.trim();
  final String password = _passwordController.text.trim();

  if (email == "admin@arva.com" && password == "admin123") {
    // 1. ADMIN: Jumps to a completely separate route (no UserNavbar)
    Navigator.pushReplacementNamed(context, '/admin_main');
  } else if (email == "user@arva.com" && password == "user123") {
    // 2. USER: Calls callback to show navbar and moves to dashboard
    widget.onLoginSuccess();
    Navigator.pop(context); 
  } else {
       // Show error for invalid credentials
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Invalid email or password",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentBg = isDarkMode ? deepForest : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : deepForest;
    final Color subTextColor = isDarkMode ? skyBlue : skyBlueDark;
    final Color fieldColor = isDarkMode ? const Color(0xFF14241A) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: currentBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: sproutGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'SYSTEM ONLINE',
                                  style: TextStyle(
                                    color: sproutGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            _buildRoundButton(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              isDarkMode ? Colors.white : deepForest,
                              onTap: () {
                                setState(() {
                                  isDarkMode = !isDarkMode;
                                });
                              },
                            ),
                          ],
                        ),
                        Center(
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.eco,
                                  color: sproutGreen,
                                  size: 80,
                                );
                              },
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'ARVA',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'AUTONOMOUS SYSTEMS',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/field.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'FARM OVERVIEW',
                                  style: TextStyle(
                                    color: harvestGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Agriculture Management System',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        Text('Email', style: TextStyle(color: isDarkMode ? ironGrey : ironGrey.withValues(alpha: 0.8))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            hintStyle: TextStyle(color: isDarkMode ? ironGrey : Colors.black26),
                            filled: true,
                            fillColor: fieldColor,
                            prefixIcon: const Icon(
                              Icons.alternate_email,
                              color: sproutGreen,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDarkMode ? ironGrey : ironGrey.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: sproutGreen,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Password', style: TextStyle(color: isDarkMode ? ironGrey : ironGrey.withValues(alpha: 0.8))),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'FORGOT?',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            hintStyle: TextStyle(color: isDarkMode ? ironGrey : Colors.black26),
                            filled: true,
                            fillColor: fieldColor,
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: sproutGreen,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: ironGrey,
                              ),
                              onPressed: () => setState(() => _obscureText = !_obscureText),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDarkMode ? ironGrey : ironGrey.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: sproutGreen,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        const SizedBox(height: 24),

                        // Login Button
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sproutGreen,
                            foregroundColor: isDarkMode ? deepForest : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'LOGIN',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: TextStyle(color: isDarkMode ? ironGrey : Colors.black54, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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