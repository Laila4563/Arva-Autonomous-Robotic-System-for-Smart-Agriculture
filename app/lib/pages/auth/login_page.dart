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
      // Background: Deep Forest / Rich Bark
      backgroundColor: const Color(0xFF0A150F), 
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
                        // System Status Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF88B04B), // Sprout Green
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'SYSTEM ONLINE',
                                  style: TextStyle(
                                    color: Color(0xFF88B04B), // Sprout Green
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'V4.2.0-STABLE',
                              style: TextStyle(color: Color(0xFF546E7A), fontSize: 14), // Iron Grey
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Logo without circle/border
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
                                  color: Color(0xFF88B04B), // Sprout Green
                                  size: 80,
                                );
                              },
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'ARVA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'AUTONOMOUS SYSTEMS',
                            style: TextStyle(
                              color: Color(0xFF56B9C7), // Sky Blue
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Field Intel Card
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
                                  'FIELD INTEL ACTIVE',
                                  style: TextStyle(
                                    color: Color(0xFFE69F21), // Harvest Gold
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Central Valley Sector-4',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        const Text('Email', style: TextStyle(color: Color(0xFF546E7A))), // Iron Grey Header
                        const SizedBox(height: 8),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            hintStyle: const TextStyle(color: Color(0xFF546E7A)),
                            filled: true,
                            fillColor: const Color(0xFF14241A),
                            prefixIcon: const Icon(
                              Icons.alternate_email,
                              color: Color(0xFF88B04B), // Sprout Green Icon
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF546E7A)), // Iron Grey Border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF88B04B), // Sprout Green focus
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
                            const Text('Password', style: TextStyle(color: Color(0xFF546E7A))), // Iron Grey Header
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'FORGOT?',
                                style: TextStyle(
                                  color: Color(0xFF56B9C7), // Sky Blue
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
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
                            hintStyle: const TextStyle(color: Color(0xFF546E7A)),
                            filled: true,
                            fillColor: const Color(0xFF14241A),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF88B04B), // Sprout Green Icon
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: const Color(0xFF546E7A),
                              ),
                              onPressed: () => setState(() => _obscureText = !_obscureText),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF546E7A)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF88B04B),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        
                        // This pushes the buttons to the bottom of the screen
                        const Spacer(),
                        const SizedBox(height: 24),

                        // Login Button (Authenticate)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/user_dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF88B04B), // Sprout Green
                            foregroundColor: const Color(0xFF0A150F), // Dark Forest Text
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

                        // Registration Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(color: Color(0xFF546E7A), fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Color(0xFF56B9C7), // Sky Blue
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
}