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
    return Destination(
      // Aman dari Null: jika ID null, otomatis diubah ke String kosong ''
      id: json['id']?.toString() ?? '',
      
      // Mengantisipasi jika nama kolom di MySQL menggunakan 'name' atau 'nama'
      name: json['name']?.toString() ?? json['nama']?.toString() ?? 'Tanpa Nama',
      
      // Mengantisipasi jika nama kolom menggunakan 'location' atau 'lokasi'
      location: json['location']?.toString() ?? json['lokasi']?.toString() ?? 'Lokasi tidak diketahui',
      
      // Mengantisipasi variasi nama kolom gambar
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString() ?? json['imageUrl']?.toString() ?? '',
      
      // Mengubah rating ke double dengan aman, jika null otomatis 0.0
      rating: json['rating'] != null ? (double.tryParse(json['rating'].toString()) ?? 0.0) : 0.0,
      
      // ⚡ PERBAIKAN UTAMA: Mengantisipasi jika 'price' atau 'harga' bernilai null
      price: json['price'] != null 
          ? (int.tryParse(json['price'].toString()) ?? 0)
          : (json['harga'] != null ? (int.tryParse(json['harga'].toString()) ?? 0) : 0),
      
      // Mengantisipasi variasi deskripsi
      description: json['description']?.toString() ?? json['deskripsi']?.toString() ?? '',
      
      // Mengamankan data list/kategori jika null
      categories: json['categories'] != null ? List<String>.from(json['categories']) : [],
    );
  }
}