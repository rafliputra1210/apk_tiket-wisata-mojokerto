import 'package:flutter/material.dart';
import '../models/ticket_category_screen.dart';
import 'ticket_screen.dart';

class TicketCategoryScreen extends StatefulWidget {
  const TicketCategoryScreen({super.key});

  @override
  State<TicketCategoryScreen> createState() => _TicketCategoryScreenState();
}

class _TicketCategoryScreenState extends State<TicketCategoryScreen> {
  // Map untuk menyimpan jumlah tiket yang dipesan per kategori
  final Map<String, int> _ticketQuantities = {};

  // Hitung total tiket terkumpul
  int get _totalTickets {
    if (_ticketQuantities.isEmpty) return 0;
    return _ticketQuantities.values.reduce((a, b) => a + b);
  }

  // Hitung total harga keseluruhan
  int get _totalPrice {
    int total = 0;
    for (var category in dummyCategories) {
      total += (originalGetQuantity(category.name) * category.price);
    }
    return total;
  }

  int originalGetQuantity(String name) {
    return _ticketQuantities[name] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Informasi Petugas
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat Bertugas,', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                      SizedBox(height: 4),
                      Text('Petugas Dlundung', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F2942))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFEBEB)),
                          backgroundColor: const Color(0xFFFEF2F2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Keluar', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: Colors.red, size: 14),
                            SizedBox(width: 6),
                            Text('Senin, 6 Juli 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kategori Penguji dengan Counter List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dummyCategories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final category = dummyCategories[index];
                  int currentQty = originalGetQuantity(category.name);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30, top: -30, bottom: 20,
                          child: Container(
                            width: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAECEB), 
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: category.iconBgColor, borderRadius: BorderRadius.circular(14)),
                                    child: Icon(category.icon, color: Colors.white, size: 28),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Rp ${category.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                                      const Text('per tiket', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2942))),
                              const SizedBox(height: 16),
                              // Counter Aksi Tambah Kurang Jumlah Orang (Pill bentuk panjang)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: const Color(0xFFFFEDD5)),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: currentQty > 0 ? () => setState(() => _ticketQuantities[category.name] = currentQty - 1) : null,
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.shade100),
                                        ),
                                        child: Icon(Icons.remove, color: currentQty > 0 ? Colors.black87 : Colors.grey.shade300, size: 20),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('$currentQty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                          const Text('TIKET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => setState(() => _ticketQuantities[category.name] = currentQty + 1),
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFC83B1D),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Tab Item: Tiket
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_outlined, color: Colors.red, size: 24),
                    SizedBox(height: 4),
                    Text('Tiket', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Tab Item: Riwayat
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, color: Colors.grey, size: 24),
                    SizedBox(height: 4),
                    Text('Riwayat', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Checkout Button
              Expanded(
                child: GestureDetector(
                  onTap: _totalTickets > 0 ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketScreen(
                          destinationName: "Air Terjun Dlundung",
                          ticketCount: _totalTickets,
                        ),
                      ),
                    );
                  } : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _totalTickets > 0 ? const Color(0xFFDC2626) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_totalTickets TIKET', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('Rp $_totalPrice', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}