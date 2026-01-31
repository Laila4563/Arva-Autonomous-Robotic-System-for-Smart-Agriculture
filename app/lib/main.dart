import 'package:flutter/material.dart';
// Import your pages here
import 'pages/auth/login_page.dart';
import 'pages/auth/registration_page.dart';
import 'pages/dashboard/user_dashboard.dart';
import 'pages/monitoring/plant_health_page.dart';
import 'pages/monitoring/pest_detection_page.dart';
import 'pages/soil_analysis/soil_analysis_page.dart';
import 'pages/recommendation/crop_recommendation_page.dart';
import 'pages/treatment/irrigation_fertilization_page.dart';
import 'pages/Landing Page/landing_page.dart';
import 'pages/dashboard/user_profile.dart';

// NEW IMPORT: Navigation Controller
import 'components/admin_navbar.dart';
import 'components/user_navbar.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arva Smart Agriculture',
      // Start at the Navbar to handle the admin state
      initialRoute: '/user_main',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/user_dashboard': (context) => const UserDashboard(),
        '/user_profile': (context) => const UserProfile(),

        // ADMIN ENTRY POINT:
        // Use the Navbar instead of direct page links to avoid argument errors
        '/admin_main': (context) => const AdminNavbar(),
        '/user_main': (context) => const UserNavbar(),
        '/soil_analysis': (context) => const SoilAnalysisPage(),
        '/crop_recommendation': (context) => const CropRecommendationPage(),
        '/plant_health': (context) => const PlantHealthPage(),
        '/pest_detection': (context) => const PestDetectionPage(),
        '/irrigation_fertilization':
            (context) => const IrrigationFertilizationPage(),
        '/landing_page': (context) => const LandingPage(),
      },
    );
  }
}
