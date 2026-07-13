// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/api_service.dart'; // 1. Import ApiService yang kita buat
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Inisialisasi ApiService dan penampung data Future
  final ApiService _apiService = ApiService();
  late Future<List<Destination>> _futureDestinations;

  @override
  void initState() {
    super.initState();
    // 3. Memicu penembakan API Laravel saat halaman pertama kali dibuka
    _futureDestinations = _apiService.getDestinations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Tiket Wisata Mojokerto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Destination>>(
        future: _futureDestinations,
        builder: (context, snapshot) {
          
          // 1. Kondisi ketika data sedang diambil/loading dari Laragon
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // 2. Kondisi jika terjadi error (Server Laragon mati atau IP salah)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '❌ Gagal Terhubung ke Backend Laravel:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }

          // 3. Kondisi jika sukses terhubung tapi tabel di database kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada data destinasi wisata di database Laragon.'),
            );
          }

          // 4. Kondisi Sukses: Data dari MySQL Laragon berhasil diterima
          final listWisata = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listWisata.length,
            itemBuilder: (context, index) {
              final wisata = listWisata[index];
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      wisata.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70, height: 70, color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(wisata.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(wisata.location),
                    ],
                  ),
                  trailing: Text(
                    'Rp ${wisata.price}',
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    // Pindah ke halaman detail dengan membawa objek data wisata
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(destination: wisata),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}