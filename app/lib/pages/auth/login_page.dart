import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2010),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                // This ensures the content at least fills the screen height
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // System Status Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00FF00),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'SYSTEM ONLINE',
                                  style: TextStyle(
                                    color: Color(0xFF00FF00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'V4.2.0-STABLE',
                              style: TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),

                        // Branded Logo (Circle and Border REMOVED)
                        Center(
                          child: SizedBox(
                            width: 107, // Slightly reduced to save space
                            height: 107,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit:
                                  BoxFit
                                      .contain, // Contain ensures the logo isn't cropped
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.eco,
                                  color: Color(0xFF00FF00),
                                  size: 80,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Center(
                          child: Text(
                            'ARVA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28, // Scaled down slightly
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'AUTONOMOUS SYSTEMS',
                            style: TextStyle(
                              color: Color(0xFF00FF00),
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field Intel Card (Reduced height to save space)
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/field.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'FIELD INTEL ACTIVE',
                                  style: TextStyle(
                                    color: Color(0xFF00FF00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Central Valley Sector-4',
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
                        const SizedBox(height: 16),

                        // Email Field
                        const Text(
                          'Email',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            hintStyle: const TextStyle(
                              color: Color(0xFF5A5A5A),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0F2A15),
                            prefixIcon: const Icon(
                              Icons.alternate_email,
                              color: Color(0xFF00FF00),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1A3A20),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00FF00),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              'FORGOT?',
                              style: TextStyle(
                                color: Color(0xFF00FF00),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: _obscureText,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            hintStyle: const TextStyle(
                              color: Color(0xFF5A5A5A),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0F2A15),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF00FF00),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscureText = !_obscureText,
                                  ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1A3A20),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00FF00),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        // Flexible spacer pushes the button and signup link down
                        const SizedBox(height: 20),

                        // Login Button
                        ElevatedButton(
                          onPressed:
                              () => Navigator.pushReplacementNamed(
                                context,
                                '/user_dashboard',
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () =>
                                      Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF00FF00),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
}
