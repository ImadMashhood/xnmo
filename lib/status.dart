import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xnmoapp/expandable_card.dart';

class StatusCard extends StatefulWidget {
  const StatusCard({super.key});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isFetchingStatus = true;
  String _statusMessage = "No Status";

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchLastStatus();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<void> _fetchLastStatus() async {
    setState(() {
      _isFetchingStatus = true;
    });

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
        String lastStatus = lastEntry['status'];
        Timestamp lastTimestamp = lastEntry['timestamp'];

        String formattedTime = DateFormat('h:mm a').format(lastTimestamp.toDate());
        String formattedDate = DateFormat('M/d/yyyy').format(lastTimestamp.toDate());

        setState(() {
          _statusMessage = _formatStatusMessage(lastStatus, formattedTime, formattedDate);
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error fetching status";
      });
    } finally {
      setState(() {
        _isFetchingStatus = false;
      });
    }
  }

  String _formatStatusMessage(String status, String time, String date) {
    switch (status) {
      case "Clock In":
        return "Clocked In\n$time\n$date";
      case "Take Break":
        return "On Break\n$time\n$date";
      case "End Break":
        return "Clocked In\n$time\n$date";
      case "Clock Out":
        return "Clocked Out\n$time\n$date";
      default:
        return "No Status";
    }
  }

  Future<void> _logAction(String status) async {
    setState(() {
      _isLoading = true;
      _statusMessage = "$status...";
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      Timestamp now = Timestamp.now();

      await _firestore.collection('users').doc(user.uid).collection('timestamps').add({
        'status': status,
        'timestamp': now,
        'location': {'lat': position.latitude, 'lon': position.longitude},
      });

      String formattedTime = DateFormat('h:mm a').format(now.toDate());
      String formattedDate = DateFormat('M/d/yyyy').format(now.toDate());

      setState(() {
        _statusMessage = _formatStatusMessage(status, formattedTime, formattedDate);
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error updating status";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: "Status",
      child: Column(
        children: [
          _isFetchingStatus
              ? _buildShimmerText()
              : Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          if (!_isLoading && _isFetchingStatus) _buildShimmerButtons(),

          if (!_isLoading && !_isFetchingStatus)
            Column(
              children: [
                _buildActionButton("Clock In", Colors.green),
                const SizedBox(height: 16),
                _buildActionButton("Take Break", Colors.orange),
                const SizedBox(height: 16),
                _buildActionButton("End Break", Colors.blue),
                const SizedBox(height: 16),
                _buildActionButton("Clock Out", Colors.red),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    bool isDisabled = false;

    if (_statusMessage == "No Status" && text != "Clock In") {
      isDisabled = true;
    } else {
      if (text == "Clock In" && (_statusMessage.contains("Clocked In") || _statusMessage.contains("On Break"))) {
        isDisabled = true;
      }
      if (text == "Take Break" && !_statusMessage.contains("Clocked In")) {
        isDisabled = true;
      }
      if (text == "End Break" && !_statusMessage.contains("On Break")) {
        isDisabled = true;
      }
      if (text == "Clock Out" && (_statusMessage.contains("On Break") || _statusMessage.contains("Clocked Out"))) {
        isDisabled = true;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey : color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: isDisabled ? null : () => _logAction(text),
        child: Text(text),
      ),
    );
  }

  Widget _buildShimmerText() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[700]!,
      highlightColor: Colors.grey[500]!,
      child: Container(
        height: 24,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[700]!,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildShimmerButtons() {
    return Column(
      children: List.generate(
        4,
            (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildShimmerText(),
        ),
      ),
    );
  }
}
