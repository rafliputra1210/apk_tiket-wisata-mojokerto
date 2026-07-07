// lib/screens/ticket_category_screen.dart
import 'package:flutter/material.dart';
import '../models/ticket_category_screen.dart';
import 'booking_form_screen.dart';

class TicketCategoryScreen extends StatefulWidget {
  const TicketCategoryScreen({super.key});

  @override
  State<TicketCategoryScreen> createState() => _TicketCategoryScreenState();
}

class _TicketCategoryScreenState extends State<TicketCategoryScreen> {
  int _bottomNavIndex = 0;

  // Map untuk menyimpan jumlah tiket per kategori
  final Map<String, int> _ticketQuantities = {
    'Anak-anak (Weekday)': 0,
    'Dewasa (Weekday)': 0,
    'Rombongan Anak-anak >10 (Weekday)': 0,
    'Rombongan Dewasa (Weekday)': 0,
  };

  // Hitung total tiket terkumpul
  int get _totalTickets => _ticketQuantities.values.reduce((a, b) => a + b);

  // Hitung total harga keseluruhan
  int get _totalPrice {
    int total = 0;
    for (var category in dummyCategories) {
      total += ((_ticketQuantities[category.name] ?? 0) * category.price).toInt();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // =========================================================
                  // 1. HEADER INFORMASI PETUGAS & TOMBOL KELUAR (AKTIF)
                  // =========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Bertugas,', 
                            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Petugas Dlundung', 
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2942)),
                          ),
                        ],
                      ),
                      
                      // Tombol Keluar Kapsul
                      GestureDetector(
                        onTap: () {
                          // Fungsi navigasi untuk keluar/kembali ke halaman sebelumnya
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEB), // Merah muda pastel
                            borderRadius: BorderRadius.circular(20), // Bentuk kapsul
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              color: Color(0xFFEF4444), // Teks merah solid
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Opsional
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month_rounded, color: Colors.red, size: 16),
                          SizedBox(width: 6),
                          Text('Senin, 6 Juli 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'PEMBELIAN LANGSUNG',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 16),

                  // Kategori Pengunjung dengan Counter
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dummyCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final category = dummyCategories[index];
                      int currentQty = _ticketQuantities[category.name] ?? 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20, top: -20, bottom: -20,
                              child: Container(
                                width: 110,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEB).withValues(alpha: 0.5), 
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: category.iconBgColor, 
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(category.icon, color: Colors.white, size: 22),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            category.name, 
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F2942)),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Rp ${category.price}', 
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F2942)),
                                          ),
                                          const Text('per tiket', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Aksi Tambah Kurang Kuantitas
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton.filledTonal(
                                        iconSize: 32,
                                        onPressed: currentQty > 0 
                                            ? () => setState(() => _ticketQuantities[category.name] = currentQty - 1) 
                                            : null,
                                        icon: const Icon(Icons.remove, size: 16),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Text('$currentQty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                      IconButton.filledTonal(
                                        iconSize: 32,
                                        onPressed: () => setState(() => _ticketQuantities[category.name] = currentQty + 1),
                                        icon: const Icon(Icons.add, size: 16),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Custom Banner Pembayaran Merah (Muncul jika tiket > 0)
          if (_totalTickets > 0)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626), 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_totalTickets TIKET', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('Rp $_totalPrice', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withValues(alpha: 0.2),
    elevation: 0,
    shape: const CircleBorder(),
    padding: const EdgeInsets.all(14),
  ),
  onPressed: () {
    // BERUBAH: Sekarang menuju ke halaman isi formulir terlebih dahulu
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          totalTickets: _totalTickets,
          totalPrice: _totalPrice,
        ),
      ),
    );
  },
  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
)
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _totalTickets == 0 
          ? BottomNavigationBar(
              currentIndex: _bottomNavIndex,
              onTap: (i) => setState(() => _bottomNavIndex = i),
              selectedItemColor: Colors.red,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tiket'),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
              ],
            )
          : null, 
    );
  }
}