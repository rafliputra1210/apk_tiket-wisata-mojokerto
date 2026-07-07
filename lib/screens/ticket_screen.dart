import 'package:flutter/material.dart';

class TicketScreen extends StatelessWidget {
  final String destinationName;
  final int ticketCount;
  final String visitorName;
  final String visitorNik;
  final String visitorAddress;

  const TicketScreen({
    super.key,
    required this.destinationName,
    required this.ticketCount,
    required this.visitorName,
    required this.visitorNik,
    required this.visitorAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Tiket'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'DATA MANIFEST PENGUNJUNG',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey, letterSpacing: 0.5),
                        ),
                      ),
                      const Divider(height: 32, thickness: 1),
                      _buildDetailRow('Nama', visitorName),
                      const SizedBox(height: 12),
                      _buildDetailRow('NIK', visitorNik),
                      const SizedBox(height: 12),
                      _buildDetailRow('Alamat', visitorAddress),
                      const Divider(height: 32, thickness: 1),
                      _buildDetailRow('Destinasi', destinationName),
                      const SizedBox(height: 12),
                      _buildDetailRow('Jumlah', '$ticketCount Tiket'),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
