import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xnmoapp/objects/work_logs.dart';
import 'package:xnmoapp/services/firestore_service.dart';
import 'package:xnmoapp/services/location_service.dart';

class FirestoreRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();

  Future<Map<String, dynamic>?> fetchLastStatus() async {
    DocumentSnapshot? snapshot = await _firestoreService.getLastStatus();
    if (snapshot == null || !snapshot.exists) return null;

    return snapshot.data() as Map<String, dynamic>;
  }

  Future<void> logAction(String status) async {
    Position position = await _locationService.getCurrentPosition();
    await _firestoreService.addTimestamp(status, position.latitude, position.longitude);
  }

  Stream<List<WorkLog>> streamActivityLogs() {
    return _firestoreService.streamActivityLogs().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return WorkLog(
          date: (data['timestamp'] as Timestamp).toDate(),
          status: data['status'] ?? "Unknown",
          latitude: data['location']?['lat'],
          longitude: data['location']?['lon'],
        );
      }).toList();
    });
  }
}
