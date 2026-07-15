// lib/models/destination.dart

class Destination {
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
    // 1. Ambil data mentah gambar dari database
    String rawImage = json['image_url']?.toString() ?? json['image']?.toString() ?? json['imageUrl']?.toString() ?? '';
    
    // 2. Format URL Gambar agar valid dan mengarah ke backend Laravel
    String finalImageUrl = rawImage;
    if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
      // Hapus garis miring di awal jika ada
      if (rawImage.startsWith('/')) rawImage = rawImage.substring(1);
      
      // Sesuaikan jalur penyimpanan standar Laravel
      if (rawImage.startsWith('public/')) {
        rawImage = rawImage.replaceFirst('public/', 'storage/');
      } else if (!rawImage.startsWith('storage/')) {
        rawImage = 'storage/$rawImage';
      }
      
      // Gabungkan dengan alamat IP backend Laragon
      finalImageUrl = 'http://127.0.0.1:8000/$rawImage';
    } else if (rawImage.isEmpty) {
      // Gambar cadangan jika di database benar-benar kosong
      finalImageUrl = 'https://placehold.co/600x400/eeeeee/999999?text=Belum+Ada+Foto';
    }

    return Destination(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? 'Tanpa Nama',
      location: json['location']?.toString() ?? json['lokasi']?.toString() ?? '',
      imageUrl: finalImageUrl, 
      rating: json['rating'] != null ? (double.tryParse(json['rating'].toString()) ?? 0.0) : 0.0,
      price: json['price'] != null 
          ? (int.tryParse(json['price'].toString()) ?? 0)
          : (json['harga'] != null 
              ? (int.tryParse(json['harga'].toString()) ?? 0) 
              : (json['harga_tiket'] != null ? (int.tryParse(json['harga_tiket'].toString()) ?? 0) : 0)),
      description: json['description']?.toString() ?? json['deskripsi']?.toString() ?? '',
      categories: json['categories'] != null ? List<String>.from(json['categories']) : [],
    );
  }
}