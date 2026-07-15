// lib/models/ticket_category.dart
import 'package:flutter/material.dart';

class TicketCategory {
  final int id;
  final String name;
  final int price;
  final IconData? icon;
  final Color? iconBgColor;

  TicketCategory({
    required this.id,
    required this.name,
    required this.price,
    this.icon,
    this.iconBgColor,
  });

  // Mengubah JSON dari API Laravel menjadi Objek Dart
  factory TicketCategory.fromJson(Map<String, dynamic> json) {
    int parsedPrice = 0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString())?.toInt() ?? 0;
    } else if (json['tickets'] != null && json['tickets'] is List && (json['tickets'] as List).isNotEmpty) {
      final ticketPrice = json['tickets'][0]['price'];
      if (ticketPrice != null) {
        parsedPrice = double.tryParse(ticketPrice.toString())?.toInt() ?? 0;
      }
    }

    return TicketCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      price: parsedPrice,
    );
  }
}