import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/printer_service.dart';

class TicketScreen extends StatefulWidget {
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
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final PrinterService _printerService = PrinterService();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    List<BluetoothDevice> devices = await _printerService.getPairedDevices();
    if (mounted) {
      setState(() {
        _devices = devices;
      });
    }
  }

  void _showPrinterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Printer Bluetooth',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Tidak ada printer Bluetooth yang ter-pairing.'),
                    )
                  else
                    ..._devices.map((device) {
                      return ListTile(
                        leading: const Icon(Icons.print),
                        title: Text(device.name ?? 'Unknown Device'),
                        subtitle: Text(device.address ?? ''),
                        trailing: _selectedDevice?.address == device.address
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          setModalState(() {
                            _selectedDevice = device;
                          });
                        },
                      );
                    }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _selectedDevice == null || _isConnecting
                          ? null
                          : () async {
                              setModalState(() {
                                _isConnecting = true;
                              });
                              
                              bool connected = await _printerService.connect(_selectedDevice!);
                              
                              setModalState(() {
                                _isConnecting = false;
                              });

                              if (connected) {
                                String qrData = 'Nama: ${widget.visitorName}\nNIK: ${widget.visitorNik}\nTujuan: ${widget.destinationName}\nTiket: ${widget.ticketCount}';
                                await _printerService.printTicket(
                                  destinationName: widget.destinationName,
                                  visitorName: widget.visitorName,
                                  visitorNik: widget.visitorNik,
                                  visitorAddress: widget.visitorAddress,
                                  ticketCount: widget.ticketCount,
                                  qrData: qrData,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Struk berhasil dicetak!')),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal terhubung ke printer')),
                                  );
                                }
                              }
                            },
                      child: _isConnecting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Hubungkan & Cetak'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Tiket'),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                      _buildDetailRow('Nama', widget.visitorName),
                      const SizedBox(height: 12),
                      _buildDetailRow('NIK', widget.visitorNik),
                      const SizedBox(height: 12),
                      _buildDetailRow('Alamat', widget.visitorAddress),
                      const Divider(height: 32, thickness: 1),
                      _buildDetailRow('Destinasi', widget.destinationName),
                      const SizedBox(height: 12),
                      _buildDetailRow('Jumlah', '${widget.ticketCount} Tiket'),
                      const SizedBox(height: 24),
                      Center(
                        child: QrImageView(
                          data: 'Nama: ${widget.visitorName}\nNIK: ${widget.visitorNik}\nTujuan: ${widget.destinationName}\nTiket: ${widget.ticketCount}',
                          version: QrVersions.auto,
                          size: 150.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Tunjukkan QR ini ke petugas',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showPrinterDialog,
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak Struk (Bluetooth)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
