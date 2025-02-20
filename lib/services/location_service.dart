import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
