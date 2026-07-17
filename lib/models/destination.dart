// lib/models/destination.dart
import 'package:flutter/foundation.dart'; // untuk debugPrint

class Destination {
  // ─── Ganti IP ini sesuai kebutuhan ────────────────────────────────────────
  // • Emulator Android Studio  : 'http://10.0.2.2:8000'
  // • HP Fisik (WiFi sama)     : 'http://192.168.x.x:8000'  ← ganti IP laptop
  // • Web / Windows run        : 'http://127.0.0.1:8000'
  static const String _baseUrl = 'http://127.0.0.1:8000';
  // ──────────────────────────────────────────────────────────────────────────

  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int price;
  final String description;
  final List<String> categories;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.description,
    required this.categories,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    // 1. Ambil nilai mentah gambar dari berbagai kemungkinan nama kolom
    String rawImage = json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        '';

    // 2. Bangun URL final gambar
    String finalImageUrl;

    if (rawImage.isEmpty) {
      // Tidak ada gambar di database → tampilkan placeholder
      finalImageUrl = 'https://placehold.co/600x400/e2e8f0/94a3b8?text=Belum+Ada+Foto';
    } else if (rawImage.startsWith('http')) {
      // Sudah berupa URL lengkap → pakai langsung
      finalImageUrl = rawImage;
    } else {
      // Path relatif dari Laravel — normalisasi dulu
      if (rawImage.startsWith('/')) rawImage = rawImage.substring(1);

      // Foto ada di public/images/ → URL = baseUrl/images/nama.png
      if (rawImage.startsWith('public/images/wisata_air_panas.png')) {
        rawImage = rawImage.replaceFirst('public/', '');
        // rawImage sekarang: images/nama.png
      }
      // Foto ada di storage/app/public/ → URL melalui symlink storage/
      else if (rawImage.startsWith('public/')) {
        rawImage = rawImage.replaceFirst('public/', 'storage/');
      }
      // Jika hanya nama file (misal: wisata_air_panas.png) → asumsi di images/
      else if (!rawImage.contains('/')) {
        rawImage = 'images/$rawImage';
      }

      finalImageUrl = '$_baseUrl/$rawImage';
    }

    // DEBUG: cetak URL gambar di console (hapus setelah berhasil)
    debugPrint('🖼️  Image URL → $finalImageUrl');

    return Destination(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? 'Tanpa Nama',
      location: json['location']?.toString() ?? json['lokasi']?.toString() ?? '',
      imageUrl: finalImageUrl,
      rating: json['rating'] != null
          ? (double.tryParse(json['rating'].toString()) ?? 0.0)
          : 0.0,
      price: json['price'] != null
          ? (int.tryParse(json['price'].toString()) ?? 0)
          : (json['harga'] != null
              ? (int.tryParse(json['harga'].toString()) ?? 0)
              : (json['harga_tiket'] != null
                  ? (int.tryParse(json['harga_tiket'].toString()) ?? 0)
                  : 0)),
      description:
          json['description']?.toString() ?? json['deskripsi']?.toString() ?? '',
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
    );
  }
}