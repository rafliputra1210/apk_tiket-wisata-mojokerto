// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/firestore_service.dart'; // Impor Firestore Service

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  bool _isLoading = false;

  void _addNewDestination() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Membuat objek objek destinasi baru
        final newDest = Destination(
          id: '', // ID otomatis dibuat oleh Firebase
          name: _nameController.text,
          location: _locationController.text,
          imageUrl: _imageController.text.isNotEmpty 
              ? _imageController.text 
              : 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?auto=format&fit=crop&w=500&q=80',
          rating: 5.0,
          price: int.parse(_priceController.text),
          description: _descriptionController.text,
          categories: ['Alam'],
        );

        // KIRIM KE DATABASE FIREBASE
        await _firestoreService.addDestination(newDest);

        _nameController.clear();
        _locationController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _imageController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Sukses menyimpan destinasi ke Firebase!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Gagal menyimpan: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Kontrol Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Destinasi Wisata Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Destinasi', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Lokasi (Kota/Provinsi)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga Tiket (Rp)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Harga tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'URL Gambar Kualitas Tinggi', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Deskripsi Tempat Wisata', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addNewDestination,
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Destinasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text('Daftar Wisata di Firebase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // MEMBACA DAFTAR WISATA LANGSUNG DARI FIREBASE
            FutureBuilder<List<Destination>>(
              future: _firestoreService.getDestinations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada data wisata di database.', style: TextStyle(color: Colors.grey));
                }

                final listWisata = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listWisata.length,
                  itemBuilder: (context, index) {
                    final item = listWisata[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Rp ${item.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            // HAPUS DARI FIREBASE
                            await _firestoreService.deleteDestination(item.id);
                            setState(() {}); // Refresh list
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Destinasi berhasil dihapus dari Firebase')));
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}