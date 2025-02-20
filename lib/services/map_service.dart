import 'dart:math';

import 'package:flutter/material.dart';

class MapService {
  Widget fetchMapImage(double lat, double lon, int zoom) {
    int x = ((lon + 180) / 360 * (1 << zoom)).toInt();
    int y = ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) / 2 * (1 << zoom)).toInt();

    String url = "https://tile.openstreetmap.org/$zoom/$x/$y.png";

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              "Map not available",
              style: TextStyle(color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
