// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/landing_screen.dart';

import 'firebase_options.dart';

void main() async {
  // 1. Wajib dipanggil sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inisialisasi Firebase (Pastikan Anda sudah menghubungkan proyek ke Firebase Console)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. AKTIFKAN FITUR OFFLINE-FIRST FIRESTORE
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Data otomatis disimpan di HP saat offline
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Ukuran penyimpanan offline tidak terbatas
  );

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C81)),
      ),
      home: const LandingScreen(),
    );
  }
}