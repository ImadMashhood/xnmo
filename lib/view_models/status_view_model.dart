import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:xnmoapp/enum/work_status_enum.dart';

class StatusViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool isFetchingStatus = true;
  WorkStatus currentStatus = WorkStatus.clockOut;
  String statusMessage = "No Status";

  StatusViewModel() {
    fetchLastStatus();
  }

  Future<void> fetchLastStatus() async {
    isFetchingStatus = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('timestamps')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var lastEntry = snapshot.docs.first.data() as Map<String, dynamic>;
        String lastStatus = lastEntry['status'] ?? "CLOCKEDOUT";
        Timestamp lastTimestamp = lastEntry['timestamp'];

        String formattedTime = DateFormat('h:mm a').format(lastTimestamp.toDate());
        String formattedDate = DateFormat('M/d/yyyy').format(lastTimestamp.toDate());

        currentStatus = lastStatus.toWorkStatus();
        statusMessage = "${currentStatus.displayName}\n$formattedTime\n$formattedDate";
      }
    } catch (e) {
      currentStatus = WorkStatus.clockOut;
      statusMessage = "Error fetching status";
    } finally {
      isFetchingStatus = false;
      notifyListeners();
    }
  }

  Future<void> logAction(WorkStatus newStatus) async {
    isLoading = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      Timestamp now = Timestamp.now();

      await _firestore.collection('users').doc(user.uid).collection('timestamps').add({
        'status': newStatus.backendValue, // Send backend value
        'timestamp': now,
        'location': {'lat': position.latitude, 'lon': position.longitude},
      });

      String formattedTime = DateFormat('h:mm a').format(now.toDate());
      String formattedDate = DateFormat('M/d/yyyy').format(now.toDate());

      currentStatus = newStatus;
      statusMessage = "${newStatus.displayName}\n$formattedTime\n$formattedDate";
    } catch (e) {
      statusMessage = "Error updating status";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isButtonEnabled(WorkStatus buttonStatus) {
    if (isLoading) return false;

    switch (buttonStatus) {
      case WorkStatus.clockIn:
        return currentStatus == WorkStatus.clockOut;

      case WorkStatus.onBreak:
        return currentStatus == WorkStatus.clockIn || currentStatus == WorkStatus.endBreak;

      case WorkStatus.endBreak:
        return currentStatus == WorkStatus.onBreak;

      case WorkStatus.clockOut:
        return currentStatus == WorkStatus.clockIn || currentStatus == WorkStatus.endBreak;
    }
  }
}
