// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/destination.dart';

class ApiService {
  // IP MASING-MASING EMULATOR/PERANGKAT:
  // - Jika pakai Emulator Android bawaan Android Studio: gunakan 'http://10.0.2.2:8000/api'
  // - Jika pakai HP Fisik asli: gunakan IP Laptop kamu (misal: 'http://192.168.1.5:8000/api')
  // - Jika tes di Windows/Chrome Web: gunakan 'http://127.0.0.1:8000/api'
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // 1. Mengambil data destinasi wisata dari API Laravel
  Future<List<Destination>> getDestinations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/destinations'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        // Mapping JSON dari Laravel ke Objek Model Flutter
        return jsonResponse.map((data) => Destination.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat data: Kode Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server backend: $e');
    }
  }

  // 2. Mengirim data manifest/pemesanan tiket ke API Laravel
  Future<bool> simpanBookingTiket(Map<String, dynamic> dataManifest) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataManifest),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
