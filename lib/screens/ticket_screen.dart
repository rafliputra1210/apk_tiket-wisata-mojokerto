import 'package:flutter/material.dart';

class TicketScreen extends StatelessWidget {
  final String destinationName;
  final int ticketCount;

  const TicketScreen({
    super.key,
    required this.destinationName,
    required this.ticketCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Tiket'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Telah memesan $ticketCount tiket untuk $destinationName'),
          ],
        ),
      ),
    );
  }
}
