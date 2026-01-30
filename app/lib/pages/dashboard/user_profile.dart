import 'dart:ui';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Theme State
  bool isDarkMode = true;

  // Arva Login Palette
  static const Color sproutGreen = Color(0xFF88B04B);
  static const Color skyBlue = Color(0xFF56B9C7);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color ironGrey = Color(0xFF546E7A);
  
  // Dynamic Backgrounds
  static const Color deepForest = Color(0xFF1B1F13);
  static const Color lightBone = Color(0xFFF5F5F0);

  @override
  Widget build(BuildContext context) {
    // Determine current colors based on toggle
    final bgColor = isDarkMode ? deepForest : lightBone;
    final cardColor = isDarkMode ? const Color(0xCC2D2D2D) : Colors.white.withOpacity(0.8);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (isDarkMode) _buildBackgroundGlow(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  _buildHeader(textColor),
                  const SizedBox(height: 40),
                  _buildGlassCard(context, cardColor, textColor),
                  const SizedBox(height: 40),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dummy spacer to keep title centered
        const SizedBox(width: 48),
        Column(
          children: [
            Text(
              'EDIT PROFILE',
              style: TextStyle(
                color: ironGrey,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 6.0,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'OPERATOR PROFILE MANAGEMENT',
              style: TextStyle(
                color: skyBlue,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // THEME SWITCH
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () => setState(() => isDarkMode = !isDarkMode),
        ),
      ],
    );
  }

  Widget _buildGlassCard(BuildContext context, Color cardColor, Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ironGrey.withOpacity(0.3)),
            boxShadow: !isDarkMode 
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)] 
              : [],
          ),
          child: Column(
            children: [
              _buildProfileAvatar(),
              const SizedBox(height: 16),
           
              const SizedBox(height: 32),
              _buildSciFiInput("FULL NAME", "John Cooper", textColor),
              const SizedBox(height: 20),
              _buildSciFiInput("EMAIL ADDRESS", "name@example.com", textColor),
              const SizedBox(height: 20),
              _buildSciFiInput("NEW PASSWORD", "••••••••••••", textColor, isPassword: true),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 24),
              _buildSystemInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: sproutGreen, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: sproutGreen.withOpacity(0.1),
            child: const Icon(Icons.person, color: sproutGreen, size: 50),
          ),
        ),
        Container(
          height: 32,
          width: 32,
          decoration: const BoxDecoration(color: harvestGold, shape: BoxShape.circle),
          child: const Icon(Icons.edit, color: Colors.black, size: 18),
        ),
      ],
    );
  }

  Widget _buildSciFiInput(String label, String initialValue, Color textColor, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: sproutGreen, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: initialValue,
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            filled: true,
            fillColor: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ironGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: sproutGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: sproutGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.terminal, size: 18),
        label: const Text("SAVE CHANGES", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: sproutGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("ACCESS LEVEL: USER", style: TextStyle(color: skyBlue.withOpacity(0.7), fontSize: 8)),
        Text("LAST AUTH: 30.01.26", style: TextStyle(color: skyBlue.withOpacity(0.7), fontSize: 8)),
      ],
    );
  }

  Widget _buildFooter() {
    return Opacity(
      opacity: 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("SYSTEM STATUS: STABLE", style: TextStyle(color: sproutGreen, fontSize: 8)),
          SizedBox(width: 16),
          Text("SECURE_DATA_READY", style: TextStyle(color: sproutGreen, fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [sproutGreen.withOpacity(0.05), Colors.transparent],
          ),
        ),
      ),
    );
  }
}