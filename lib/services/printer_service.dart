import 'package:flutter/foundation.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await bluetooth.getBondedDevices();
    } catch (e) {
      debugPrint("Error getting paired devices: $e");
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected == true) {
        await bluetooth.disconnect();
      }
      await bluetooth.connect(device);
      return true;
    } catch (e) {
      debugPrint("Error connecting to printer: $e");
      return false;
    }
  }

  Future<void> disconnect() async {
    await bluetooth.disconnect();
  }

  Future<void> printTicket({
    required String destinationName,
    required String visitorName,
    required String visitorNik,
    required String visitorAddress,
    required int ticketCount,
    required String qrData,
  }) async {
    try {
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected != true) {
        return;
      }

      bluetooth.printNewLine();
      bluetooth.printCustom("TIKET WISATA", 3, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom(destinationName, 2, 1);
      bluetooth.printNewLine();
      
      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printLeftRight("Nama", visitorName, 1);
      bluetooth.printLeftRight("NIK", visitorNik, 1);
      bluetooth.printLeftRight("Alamat", visitorAddress, 1);
      bluetooth.printLeftRight("Jumlah", "$ticketCount Tiket", 1);
      bluetooth.printCustom("--------------------------------", 1, 1);
      
      bluetooth.printNewLine();
      bluetooth.printQRcode(qrData, 200, 200, 1);
      bluetooth.printNewLine();
      
      bluetooth.printNewLine();
      bluetooth.printCustom("Terima kasih atas kunjungan Anda", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine(); // Extra lines so paper can be torn
      
      // bluetooth.paperCut(); // Optional depending on printer model
    } catch (e) {
      debugPrint("Error printing: $e");
    }
  }
}
