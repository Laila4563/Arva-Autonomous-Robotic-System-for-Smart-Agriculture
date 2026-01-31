import 'package:flutter/material.dart';

class AdminProfile extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AdminProfile({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  static const Color sproutGreen = Color(0xFF88B04B);
  // static const Color skyBlue = Color(0xFF56B9C7);
  static const Color harvestGold = Color(0xFFE69F21);
  static const Color deepForest = Color(0xFF0A150F);
  static const Color richBark = Color(0xFF1A1F1C);
  static const Color ironGrey = Color(0xFF546E7A);
  static const Color backgroundLight = Color.fromARGB(255, 246, 248, 246);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDarkMode;
    final Color currentBg = dark ? deepForest : backgroundLight;
    final Color textColor = dark ? Colors.white : deepForest;
    final Color cardColor = dark ? richBark.withValues(alpha: 0.6) : Colors.white;

    return Scaffold(
      backgroundColor: currentBg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridPainter(color: dark ? Colors.green.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)))),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(dark ? Icons.light_mode : Icons.dark_mode, color: dark ? Colors.white : deepForest),
                      onPressed: widget.onThemeToggle,
                    ),
                  ),
                  const Text('ADMIN PROFILE', style: TextStyle(color: sproutGreen, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 1, width: 40, color: ironGrey.withValues(alpha: 0.3)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('UNIFIED COMMAND ACCESS', style: TextStyle(color: ironGrey, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2))),
                    Container(height: 1, width: 40, color: ironGrey.withValues(alpha: 0.3)),
                  ]),
                  const SizedBox(height: 50),
                  _buildProfileCard(cardColor, textColor),
                  const SizedBox(height: 40),
                  const Text('SECURE_DATA_READY   |   SYSTEM_STABLE', style: TextStyle(color: ironGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('ARVA AGROBOTICS CORP // CORE_OS', style: TextStyle(color: Colors.white10, fontSize: 9)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Color cardColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: sproutGreen.withValues(alpha: 0.15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, 20))]),
      child: Column(children: [
        _buildAvatar(),
        const SizedBox(height: 24),
        _buildUIDBadge(),
        const SizedBox(height: 40),
        _buildEditableInput(label: 'FULL NAME // IDENTIFIER', hint: 'Commander Arva', controller: _nameController, icon: Icons.edit),
        const SizedBox(height: 24),
        _buildEditableInput(label: 'ADMIN EMAIL // NETWORK ID', hint: 'root@arva-systems.agri', controller: _emailController, icon: Icons.alternate_email),
        const SizedBox(height: 24),
        _buildEditableInput(label: 'SYSTEM ACCESS KEY', hint: '••••••••••••', controller: _keyController, icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 40),
        _buildCommitButton(),
        const SizedBox(height: 30),
        _buildSystemInfoRow(textColor),
      ]),
    );
  }

  Widget _buildAvatar() {
    return Stack(alignment: Alignment.center, children: [
      Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sproutGreen.withValues(alpha: 0.2), width: 1))),
      Container(width: 85, height: 85, decoration: BoxDecoration(shape: BoxShape.circle, color: deepForest, border: Border.all(color: sproutGreen.withValues(alpha: 0.5), width: 2)), child: const Icon(Icons.person, color: sproutGreen, size: 40)),
      Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: harvestGold, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.black, size: 18))),
    ]);
  }

  Widget _buildUIDBadge() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: harvestGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: harvestGold.withValues(alpha: 0.3))), child: const Text('UID: ARVA-ROOT-01', style: TextStyle(color: harvestGold, fontSize: 11, fontWeight: FontWeight.bold)));
  }

  Widget _buildEditableInput({required String label, required String hint, required TextEditingController controller, required IconData icon, bool isPassword = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: sproutGreen, fontSize: 10, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: sproutGreen,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          suffixIcon: Icon(icon, color: ironGrey, size: 18),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: sproutGreen, width: 1)),
        ),
      ),
    ]);
  }

  Widget _buildCommitButton() {
    return Container(width: double.infinity, height: 55, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: sproutGreen.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]), child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: sproutGreen, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text('COMMIT UPDATES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))));
  }

  Widget _buildSystemInfoRow(Color textColor) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ACCESS LEVEL', style: TextStyle(color: ironGrey, fontSize: 9, fontWeight: FontWeight.bold)), Text('SUPER-ADMIN', style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold))]),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('NODE ID', style: TextStyle(color: ironGrey, fontSize: 9, fontWeight: FontWeight.bold)), const Text('ARVA-01', style: TextStyle(color: harvestGold, fontSize: 10, fontWeight: FontWeight.bold))]),
    ]);
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5;
    const double step = 35;
    for (double i = 0; i < size.width; i += step) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i < size.height; i += step) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}