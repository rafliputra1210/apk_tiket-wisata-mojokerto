import 'package:flutter/material.dart';

Widget loadWebImage(String url, String id) {
  // DEBUG: cetak URL yang dicoba dimuat
  debugPrint('🌐 loadWebImage → $url');

  return Image.network(
    url,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
          color: Colors.grey[400],
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      debugPrint('❌ Gagal load gambar [$id]: $error');
      return Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text('Gagal muat', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          ],
        ),
      );
    },
  );
}
