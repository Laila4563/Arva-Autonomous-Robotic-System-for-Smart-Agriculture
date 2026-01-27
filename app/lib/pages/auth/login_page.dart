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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                            color: Color(0xFF00FF00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SYSTEM ONLINE',
                          style: TextStyle(
                            color: Color(0xFF00FF00),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'V4.2.0-STABLE',
                      style: TextStyle(
                        color: Color(0xFF8A8A8A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Branded Logo/Avatar
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00FF00), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.eco, color: Color(0xFF00FF00), size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                      color: Color(0xFF00FF00),
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Field Intel Card
                Container(
                  height: 120,
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
                      // Updated to avoid deprecation error
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('FIELD INTEL ACTIVE', style: TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.bold)),
                        Text('Central Valley Sector-4', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                const Text('Email', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
                    filled: true,
                    fillColor: const Color(0xFF0F2A15),
                    prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF00FF00)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A3A20)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FF00), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Password', style: TextStyle(color: Colors.white)),
                    Text('FORGOT?', style: TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  obscureText: _obscureText,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '••••••••••••',
                    hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
                    filled: true,
                    fillColor: const Color(0xFF0F2A15),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF00FF00)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A3A20)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FF00), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                     Navigator.pushReplacementNamed(context, '/user_dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 12),

                // --- NEW REGISTER LINK ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigates to the register route
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Register',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}