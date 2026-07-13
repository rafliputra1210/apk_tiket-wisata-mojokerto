// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Mengambil Data Destinasi (Otomatis mengambil dari cache lokal jika sedang offline)
 Future<void> addDestination(Destination destination) async {
    await _db.collection('destinations').add({
      'name': destination.name,
      'location': destination.location,
      'price': destination.price,
      'rating': destination.rating,
      'imageUrl': destination.imageUrl,
      'description': destination.description,
      'categories': destination.categories,
    });
  }

  // 4. Admin: Menghapus Destinasi dari Firestore Database berdasarkan ID dokumen
  Future<void> deleteDestination(String id) async {
    await _db.collection('destinations').doc(id).delete();
  }

  Future<List<Destination>> getDestinations() async {
    final snapshot = await _db.collection('destinations').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Destination(
        id: doc.id,
        name: data['name'] ?? '',
        location: data['location'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        rating: (data['rating'] ?? 0).toDouble(),
        price: data['price'] ?? 0,
        description: data['description'] ?? '',
        categories: List<String>.from(data['categories'] ?? []),
      );
    }).toList();
  }

  // 2. Menyimpan Data Pemesanan Tiket (Manifest)
  Future<void> submitBooking({
    required String name,
    required String nik,
    required String address,
    required int totalTickets,
    required int totalPrice,
  }) async {
    // Fungsi .add() ini akan langsung sukses di sisi lokal HP jika offline,
    // lalu masuk antrean untuk diunggah otomatis saat internet tersambung kembali.
    await _db.collection('bookings').add({
      'nama_pengunjung': name,
      'nik': nik,
      'alamat': address,
      'jumlah_tiket': totalTickets,
      'total_harga': totalPrice,
      'status_sinkronisasi': 'diantrekan', 
      'timestamp': FieldValue.serverTimestamp(), // Waktu server Firebase
    });
  }
}