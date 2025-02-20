import 'package:xnmoapp/services/map_service.dart';
import 'package:flutter/material.dart';

class MapRepository {
  final MapService _mapService = MapService();

  Widget fetchMapWidget(double lat, double lon, int zoom) {
    return _mapService.fetchMapImage(lat, lon, zoom);
  }
}
