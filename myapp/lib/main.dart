// lib/main.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/onboarding_screen.dart';
import 'package:myapp/screens/auth/user_login_screen.dart';
import 'package:myapp/screens/auth/vendor_login_screen.dart';
import 'package:myapp/screens/auth/driver_login_screen.dart';
import 'package:myapp/screens/user/home/home_screen.dart';

void main() {
  runApp(const TaxiSureApp());
}

class TaxiSureApp extends StatelessWidget {
  const TaxiSureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxiSure',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFF),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/user-login': (context) => const UserLoginScreen(),
        '/vendor-login': (context) => const VendorLoginScreen(),
        '/driver-login': (context) => const DriverLoginScreen(),
        '/user-home': (context) => const UserHomeScreen()
      },
    );
  }
}
