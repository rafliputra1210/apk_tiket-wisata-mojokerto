import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'ticket_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final int totalTickets;
  final int totalPrice;

  const BookingFormScreen({
    super.key,
    required this.totalTickets,
    required this.totalPrice,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk menangkap input teks
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitData() async {
  if (_formKey.currentState!.validate()) {
    // Tampilkan loading indikator sebentar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Jalankan penyimpanan data manifest ke Firestore
      await FirestoreService().submitBooking(
        name: _nameController.text,
        nik: _nikController.text,
        address: _addressController.text,
        totalTickets: widget.totalTickets,
        totalPrice: widget.totalPrice,
      );

      // Tutup loading dialog
      if (mounted) Navigator.pop(context);

      // 3. Langsung arahkan ke halaman cetak E-Tiket (Sebab data sudah aman di cache HP)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => TicketScreen(
              destinationName: "Air Terjun Dlundung",
              ticketCount: widget.totalTickets,
              visitorName: _nameController.text,
              visitorNik: _nikController.text,
              visitorAddress: _addressController.text,
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan sistem lokal: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Data Pengunjung', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2942))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ringkasan Pesanan Ringkas
            Card(
              color: const Color(0xFF0F4C81).withValues(alpha: 0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Pesanan', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${widget.totalTickets} Tiket Wisata', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2942))),
                      ],
                    ),
                    Text(
                      'Rp ${widget.totalPrice}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F4C81)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'FORMULIR MANIFEST',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
            ),
            const SizedBox(height: 16),

            // 2. Komponen Formulir Validasi
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Input Nama Lengkap
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Ketua Rombongan',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Input NIK (Nomor Induk Kependudukan)
                  TextFormField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nomor NIK (KTP)',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'NIK wajib diisi';
                      if (value.length < 16) return 'NIK harus berjumlah 16 digit';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input Alamat Lengkap
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alamat Asal Kota / Kabupaten',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 30), // Mengatur posisi icon agar tetap di atas saat multiline
                        child: Icon(Icons.home_outlined),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),

                  // Tombol Konfirmasi Final
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81), // Kembalikan ke warna tema utama aplikasi
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Konfirmasi & Cetak Tiket', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}