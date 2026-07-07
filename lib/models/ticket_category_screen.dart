import 'package:flutter/material.dart';

class TicketCategory {
  final String name;
  final int price;
  final IconData icon;
  final Color iconBgColor;

  TicketCategory({
    required this.name,
    required this.price,
    required this.icon,
    required this.iconBgColor,
  });
}

// Data Dummy Kategori sesuai gambar image_b674f9.png dan image_b6751a.png
final List<TicketCategory> dummyCategories = [
  TicketCategory(
    name: 'Anak-anak (Weekday)',
    price: 10000,
    icon: Icons.child_care_rounded,
    iconBgColor: const Color(0xFFF97316), // Orange
  ),
  TicketCategory(
    name: 'Dewasa (Weekday)',
    price: 12500,
    icon: Icons.people_alt_rounded,
    iconBgColor: const Color(0xFFEA580C), // Darker Orange/Red
  ),
  TicketCategory(
    name: 'Rombongan Anak-anak >10 (Weekday)',
    price: 7500,
    icon: Icons.face_rounded,
    iconBgColor: const Color(0xFFF97316),
  ),
  TicketCategory(
    name: 'Rombongan Dewasa (Weekday)',
    price: 9500,
    icon: Icons.group_rounded,
    iconBgColor: const Color(0xFFEA580C),
  ),
  TicketCategory(
    name: 'Rombongan Pelajar PAUD-SMA (Weekday)',
    price: 6000,
    icon: Icons.people_alt_rounded,
    iconBgColor: const Color(0xFFC83B1D),
  ),
  TicketCategory(
    name: 'Rombongan Mahasiswa (Weekday)',
    price: 7500,
    icon: Icons.people_alt_rounded,
    iconBgColor: const Color(0xFFC83B1D),
  ),
];
