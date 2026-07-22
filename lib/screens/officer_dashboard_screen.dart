// lib/screens/officer_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/ticket_category.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import 'ticket_screen.dart';
import 'login_screen.dart';

class OfficerDashboardScreen extends StatefulWidget {
  final String officerName;

  const OfficerDashboardScreen({super.key, required this.officerName});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  // Input Controllers untuk Manifest
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _addressController = TextEditingController();

  // State data dari API
  List<Destination> _destinations = [];
  Destination? _selectedDestination;
  List<TicketCategory> _categories = [];

  // State loket
  final Map<int, int> _ticketQuantities = {}; // key: categoryId, value: qty
  bool _isLoadingData = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final destinations = await _apiService.getDestinations();
      final categories = await _apiService.getTicketCategories();

      setState(() {
        _destinations = destinations;
        if (destinations.isNotEmpty) {
          _selectedDestination = destinations.first;
        }
        _categories = categories;
        for (var cat in categories) {
          _ticketQuantities[cat.id] = 0;
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data dari server Laravel: $e';
        _isLoadingData = false;
      });
    }
  }

  // Hitung total tiket terpilih
  int get _totalTickets {
    if (_ticketQuantities.isEmpty) return 0;
    return _ticketQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  // Hitung total harga
  int get _totalPrice {
    int total = 0;
    for (var cat in _categories) {
      final qty = _ticketQuantities[cat.id] ?? 0;
      total += qty * cat.price;
    }
    return total;
  }

  String _formatRupiah(int price) {
    String priceStr = price.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = priceStr.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return 'Rp $result';
  }

  IconData _getIconForCategory(String name) {
    String nameLower = name.toLowerCase();
    if (nameLower.contains('anak')) return Icons.child_care;
    if (nameLower.contains('dewasa')) return Icons.person;
    if (nameLower.contains('rombongan')) return Icons.groups;
    if (nameLower.contains('parkir')) return Icons.local_parking;
    if (nameLower.contains('camping') || nameLower.contains('kemah')) return Icons.landscape;
    return Icons.confirmation_number_outlined;
  }

  Color _getColorForCategory(String name) {
    String nameLower = name.toLowerCase();
    if (nameLower.contains('anak')) return Colors.blue;
    if (nameLower.contains('dewasa')) return Colors.green;
    if (nameLower.contains('rombongan')) return Colors.orange;
    if (nameLower.contains('parkir')) return Colors.teal;
    if (nameLower.contains('camping') || nameLower.contains('kemah')) return Colors.deepPurple;
    return Colors.blueGrey;
  }

  void _submitTransaction() async {
    if (_totalTickets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Harap masukkan jumlah tiket terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Siapkan detail transaksi relasional
    final List<Map<String, dynamic>> detailsPayload = [];
    for (var cat in _categories) {
      final qty = _ticketQuantities[cat.id] ?? 0;
      if (qty > 0) {
        detailsPayload.add({
          'category_id': cat.id,
          'quantity': qty,
          'price': cat.price,
          'subtotal': qty * cat.price,
        });
      }
    }

    final Map<String, dynamic> transactionPayload = {
      'wisata_id': _selectedDestination?.id ?? '1',
      'nama_pengunjung': _nameController.text.trim(),
      'nik': _nikController.text.trim(),
      'alamat': _addressController.text.trim(),
      'total_tickets': _totalTickets,
      'total_price': _totalPrice,
      'details': detailsPayload,
    };

    // 1. Simpan ke Laravel Backend via API
    final apiSuccessResponse = await _apiService.simpanTransaksiRelasional(transactionPayload);

    // 2. Simpan paralel ke Firebase Firestore (Offline-first fallback)
    try {
      await _firestoreService.submitBooking(
        name: _nameController.text.trim(),
        nik: _nikController.text.trim(),
        address: _addressController.text.trim(),
        totalTickets: _totalTickets,
        totalPrice: _totalPrice,
      );
    } catch (e) {
      debugPrint('Firestore offline-queue write: $e');
    }

    // Tutup loading dialog
    if (mounted) Navigator.pop(context);

    if (apiSuccessResponse != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Transaksi tersimpan ke Laravel MySQL & Firebase!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketScreen(
              destinationName: _selectedDestination?.name ?? "Tempat Wisata",
              ticketCount: _totalTickets,
              visitorName: _nameController.text.trim(),
              visitorNik: _nikController.text.trim(),
              visitorAddress: _addressController.text.trim(),
            ),
          ),
        ).then((_) => _clearForm());
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('💡 Offline / Terjadi Masalah API'),
            content: const Text(
                'Transaksi gagal disimpan ke database pusat Laravel MySQL (kemungkinan server offline).\n\nNamun, data telah diantrekan secara lokal di Firebase Firestore HP ini dan akan tersinkronisasi otomatis saat terhubung kembali.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketScreen(
                        destinationName: _selectedDestination?.name ?? "Tempat Wisata",
                        ticketCount: _totalTickets,
                        visitorName: _nameController.text.trim(),
                        visitorNik: _nikController.text.trim(),
                        visitorAddress: _addressController.text.trim(),
                      ),
                    ),
                  ).then((_) => _clearForm());
                },
                child: const Text('Tetap Cetak Struk'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _nikController.clear();
      _addressController.clear();
      for (var cat in _categories) {
        _ticketQuantities[cat.id] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 untuk background bersih
      appBar: AppBar(
        title: const Text('Dashboard Loket Terpadu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF0F2942),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Keluar Akun',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadInitialData, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Jika lebar layar < 700px (HP / Portrait mode), tampilkan Single Column
                    if (constraints.maxWidth < 700) {
                      return _buildMobileSingleColumnLayout();
                    } else {
                      // Jika layar lebar (Tablet / Desktop / Landscape), tampilkan 2 Kolom Side-by-Side
                      return _buildWideTwoColumnLayout();
                    }
                  },
                ),
    );
  }

  // ===========================================================================
  // LAYOUT HP (SINGLE COLUMN VERTICAL SCROLLABLE)
  // ===========================================================================
  Widget _buildMobileSingleColumnLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Wisata Selector Card
          _buildWisataSelectorCard(),
          const SizedBox(height: 16),

          // 2. Daftar Kategori Tiket Section
          const Text(
            'PILIH KATEGORI TIKET',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          _buildTicketCategoriesList(),
          const SizedBox(height: 24),

          // 3. Manifest Form & Summary Section
          Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Petugas: ${widget.officerName}',
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text('MANIFEST PENGUNJUNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F2942))),
                  const Divider(height: 24),
                  _buildManifestFormFields(),
                  const Divider(height: 32),
                  _buildSummaryAndCheckoutSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // LAYOUT TABLET / DESKTOP (TWO COLUMNS SIDE-BY-SIDE)
  // ===========================================================================
  Widget _buildWideTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- KIRI: Input Kuantitas Tiket (55% Lebar Layar) ---
        Expanded(
          flex: 55,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWisataSelectorCard(),
                const SizedBox(height: 16),
                const Text(
                  'PILIH KATEGORI TIKET',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                _buildTicketCategoriesList(),
              ],
            ),
          ),
        ),

        // --- KANAN: Formulir Manifest & Ringkasan (45% Lebar Layar) ---
        Expanded(
          flex: 45,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade300, width: 1.0)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petugas: ${widget.officerName}',
                      style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text('MANIFEST PENGUNJUNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F2942))),
                    const Divider(height: 24),
                    _buildManifestFormFields(),
                    const Divider(height: 32),
                    _buildSummaryAndCheckoutSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET KOMPONEN TERPISAH (CLEAN & REUSABLE)
  // ===========================================================================

  Widget _buildWisataSelectorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Destination>(
          value: _selectedDestination,
          isExpanded: true,
          icon: const Icon(Icons.location_on_rounded, color: Color(0xFF0F2942)),
          onChanged: (Destination? newValue) {
            setState(() {
              _selectedDestination = newValue;
            });
          },
          items: _destinations.map<DropdownMenuItem<Destination>>((Destination dest) {
            return DropdownMenuItem<Destination>(
              value: dest,
              child: Text(
                dest.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2942)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTicketCategoriesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final currentQty = _ticketQuantities[category.id] ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: currentQty > 0 ? Colors.blue.shade300 : Colors.grey.shade200, width: currentQty > 0 ? 1.5 : 1.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon Kategori
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColorForCategory(category.name).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconForCategory(category.name), color: _getColorForCategory(category.name), size: 24),
              ),
              const SizedBox(width: 14),

              // Detail Teks Nama & Harga Kategori (Expanded agar tidak overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F2942)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(category.price),
                      style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Tombol Kurang, Angka Kuantitas, Tombol Tambah
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36)),
                    onPressed: currentQty > 0
                        ? () => setState(() => _ticketQuantities[category.id] = currentQty - 1)
                        : null,
                    icon: const Icon(Icons.remove, size: 18),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 32,
                    child: Text(
                      '$currentQty',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2942)),
                    ),
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36)),
                    onPressed: () => setState(() => _ticketQuantities[category.id] = currentQty + 1),
                    icon: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManifestFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nama Ketua Rombongan',
            hintText: 'Masukkan nama lengkap',
            prefixIcon: const Icon(Icons.person_outline),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _nikController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'NIK KTP (16 Digit)',
            hintText: 'Masukkan 16 digit NIK',
            prefixIcon: const Icon(Icons.badge_outlined),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'NIK wajib diisi';
            if (v.trim().length < 16) return 'NIK harus berjumlah 16 digit';
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Alamat Asal Kota/Kabupaten',
            hintText: 'Masukkan kota atau kabupaten asal',
            prefixIcon: const Icon(Icons.home_outlined),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          validator: (v) => v!.trim().isEmpty ? 'Alamat wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildSummaryAndCheckoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Kuantitas:', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
            Text('$_totalTickets Tiket', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2942))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Pembayaran:', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
            Text(_formatRupiah(_totalPrice), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF2563EB))),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _submitTransaction,
            icon: const Icon(Icons.print_rounded, size: 22),
            label: const Text(
              'CETAK & SIMPAN TIKET',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626), // Merah kontras tinggi
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
