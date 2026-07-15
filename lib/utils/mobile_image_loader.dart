import 'package:flutter/material.dart';

Widget loadWebImage(String url, String id) {
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => const Center(
      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
    ),
  );
}
