import 'package:flutter/material.dart';
// Import your pages here
import 'pages/auth/login_page.dart';
import 'pages/auth/registration_page.dart';
import 'pages/dashboard/user_dashboard.dart';
import 'pages/dashboard/admin_dashboard.dart';
import 'pages/monitoring/plant_health_page.dart';
import 'pages/monitoring/pest_detection_page.dart';
import 'pages/soil_analysis/soil_analysis_page.dart';
import 'pages/recommendation/crop_recommendation_page.dart';
import 'pages/treatment/irrigation_fertilization_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the design size for ScreenUtil (standard mobile size)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arva Smart Agriculture',
      // Change this line to the route name you want to work on
      initialRoute: '/irrigation_fertilization',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/user_dashboard': (context) => const UserDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/soil_analysis': (context) => const SoilAnalysisPage(),
        '/crop_recommendation':
            (context) => const CropRecommendationPage(),
        '/plant_health': (context) => const PlantHealthPage(),
        '/pest_detection': (context) => const PestDetectionPage(),
        '/irrigation_fertilization': (context) => const IrrigationFertilizationPage(),
      },
    );
  }
}
