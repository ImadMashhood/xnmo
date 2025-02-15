import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:xnmoapp/expandable_card.dart';

class ActivityCard extends StatefulWidget {
  const ActivityCard({super.key});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<WorkLog> workLogs = [];
  DateTime? selectedDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivity();
  }

  /// **Fetch logs from Firestore and organize them by date**
  void _fetchActivity() {
    User? user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('timestamps')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      Map<String, List<WorkLog>> dailyLogs = {};

      for (var doc in snapshot.docs) {
        DateTime date = (doc['timestamp'] as Timestamp).toDate();
        String status = doc['status'] ?? "Unknown";
        double? lat = doc['location']?['lat'];
        double? lon = doc['location']?['lon'];

        String formattedDate = _formatDate(date);
        if (!dailyLogs.containsKey(formattedDate)) {
          dailyLogs[formattedDate] = [];
        }

        dailyLogs[formattedDate]!.add(
          WorkLog(
            date: date,
            status: status,
            latitude: lat,
            longitude: lon,
          ),
        );
      }

      setState(() {
        workLogs = dailyLogs.entries.expand((entry) => entry.value).toList();
        isLoading = false;
      });
    });
  }

  double _calculateTotalHours(List<WorkLog> logs) {
    DateTime? clockIn;
    DateTime? clockOut;
    int totalMinutes = 0;
    int breakMinutes = 0;
    DateTime? breakStart;

    for (var log in logs) {
      if (log.status == "Clock In") {
        clockIn = log.date;
      }
      else if (log.status == "Clock Out" && clockIn != null) {
        clockOut = log.date;
        totalMinutes += clockOut.difference(clockIn).inMinutes;
        clockIn = null; // Reset after logging hours
      }
      else if (log.status == "Take Break") {
        breakStart = log.date;
      }
      else if (log.status == "End Break" && breakStart != null) {
        breakMinutes += log.date.difference(breakStart).inMinutes;
        breakStart = null;
      }
    }

    // Compute total worked hours minus break time
    double totalHours = (totalMinutes - breakMinutes) / 60.0;

    // Prevent negative values
    return totalHours < 0 ? 0 : totalHours;
  }



  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: "Work Activity",
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // **Heatmap Calendar**
          SfCalendar(
            view: CalendarView.month,
            dataSource: WorkDataSource(workLogs),
            monthCellBuilder: _monthCellBuilder,
            onTap: (CalendarTapDetails details) {
              if (details.date != null) {
                setState(() {
                  selectedDate = details.date;
                });
              }
            },
          ),
          if (selectedDate != null) _buildExpandedView(selectedDate!),
        ],
      ),
    );
  }

  /// **Heatmap Coloring for Calendar**
  Widget _monthCellBuilder(BuildContext context, MonthCellDetails details) {
    bool hasLogs = workLogs.any((log) => isSameDay(log.date, details.date));

    return Container(
      decoration: BoxDecoration(
        color: hasLogs ? Colors.green[600] : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          "${details.date.day}",
          style: TextStyle(
            color: hasLogs ? Colors.white : Colors.white, // Ensure text is visible
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// **Expanded View for Selected Date**
  Widget _buildExpandedView(DateTime date) {
    List<WorkLog> logs = workLogs.where((log) => isSameDay(log.date, date)).toList();
    double totalHours = _calculateTotalHours(logs);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Hours Worked: ${totalHours.toStringAsFixed(2)} hrs",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          logs.isEmpty
              ? const Text("No logs for this day.")
              : Column(
            children: logs.map((log) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${log.status}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('h:mm a').format(log.date)),
                      const SizedBox(height: 8),

                      // **Static Map from OpenStreetMap**
                      if (log.latitude != null && log.longitude != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            getOSMTileUrl(log.latitude ?? 0, log.longitude ?? 0, 15),
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
                        ),
                      const SizedBox(height: 8),

                      // **Location Details**
                      if (log.latitude != null && log.longitude != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Lat/Lon: ${log.latitude}, ${log.longitude}", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

// **Syncfusion Data Source**
class WorkDataSource extends CalendarDataSource {
  WorkDataSource(List<WorkLog> workLogs) {
    appointments = workLogs;
  }
}

String getOSMTileUrl(double lat, double lon, int zoom) {
  int x = ((lon + 180) / 360 * (1 << zoom)).toInt();
  int y = ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) / 2 * (1 << zoom)).toInt();

  return "https://tile.openstreetmap.org/$zoom/$x/$y.png";
}

// **Work Log Model**
class WorkLog {
  final DateTime date;
  final String status;
  final double? latitude;
  final double? longitude;

  WorkLog({
    required this.date,
    required this.status,
    this.latitude,
    this.longitude,
  });
}
