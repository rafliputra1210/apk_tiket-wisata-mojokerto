// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/landing_screen.dart'; // 1. Ubah import ke landing_screen

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiket Wisata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C81), 
          primary: const Color(0xFF0F4C81),
          secondary: const Color(0xFF10B981), 
          surface: const Color(0xFFF8FAFC), 
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          color: Colors.white,
        ),
      ),
      home: const LandingScreen(), // 2. Ubah target awal ke LandingScreen
    );
  }
}