import 'package:flutter/material.dart';
import '../models/destination.dart';
import 'detail_screen.dart';
import 'admin_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showAdminLoginDialog(BuildContext context) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text == 'admin123') { // Password dummy
                Navigator.pop(context); // Tutup dialog
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
                setState(() {}); // Refresh state setelah admin kembali
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password salah!')),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil & Akses Admin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, Mau Kemana?', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const Text('Jelajahi Destinasi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    ],
                  ),
                  // Tombol Profil yang mengarah ke Panel Admin jika diklik
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_open_rounded, // Ikon gembok masuk admin
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    onPressed: () {
                      // Memanggil fungsi dialog login yang akan kita buat di bawah
                      _showAdminLoginDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari pantai, gunung, museum...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text('Rekomendasi Wisata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              
              // Gunakan globalDestinations dinamis, bukan dummyDestinations lama
              globalDestinations.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text('Belum ada tiket wisata yang tersedia.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: globalDestinations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final destination = globalDestinations[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(destination: destination),
                              ),
                            );
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  destination.imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(destination.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(destination.location, style: const TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Rp ${destination.price}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}