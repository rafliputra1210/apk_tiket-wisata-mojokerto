import 'package:flutter/material.dart';
import '../models/destination.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk menangkap teks dari input form
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  void _addNewDestination() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        globalDestinations.add(
          Destination(
            id: DateTime.now().toString(), // ID unik berbasis timestamp
            name: _nameController.text,
            location: _locationController.text,
            imageUrl: _imageController.text.isNotEmpty 
                ? _imageController.text 
                : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=500&q=80', // Default image fallback
            rating: 5.0, // Destinasi baru otomatis rating sempurna
            price: int.parse(_priceController.text),
            description: _descriptionController.text,
            categories: ['Alam'],
          ),
        );
      });

      // Bersihkan form setelah sukses input
      _nameController.clear();
      _locationController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _imageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Destinasi Baru Berhasil Ditambahkan!')),
      );
    }
  }

  @override
  void dispose() {
    // Menghapus controller dari memori jika screen ditutup
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
            
            // FORM INPUT DATA BARU
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
                    decoration: const InputDecoration(
                      labelText: 'URL Gambar Kualitas Tinggi', 
                      hintText: 'https://example.com/gambar.jpg',
                      border: OutlineInputBorder()
                    ),
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
                      onPressed: _addNewDestination,
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                      child: const Text('Simpan Destinasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text('Daftar Wisata Saat Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // LIST VIEW UNTUK MEMANTAU & MENGAPUS TIKET
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: globalDestinations.length,
              itemBuilder: (context, index) {
                final item = globalDestinations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rp ${item.price}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          globalDestinations.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Destinasi berhasil dihapus')),
                        );
                      },
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}