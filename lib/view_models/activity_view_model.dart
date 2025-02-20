import 'package:flutter/material.dart';
import 'package:xnmoapp/repositories/firestore_repository.dart';
import 'package:xnmoapp/objects/work_logs.dart';
import 'package:xnmoapp/repositories/map_repository.dart';
import 'package:xnmoapp/enum/work_status_enum.dart';

class ActivityViewModel extends ChangeNotifier {
  final FirestoreRepository _firestoreRepository = FirestoreRepository();
  final MapRepository _mapRepository = MapRepository();

  bool isLoading = true;
  List<WorkLog> workLogs = [];
  DateTime? selectedDate;

  ActivityViewModel() {
    _observeActivityLogs();
  }

  void _observeActivityLogs() {
    _firestoreRepository.streamActivityLogs().listen((logs) {
      workLogs = logs.map((log) {
        return WorkLog(
          date: log.date,
          status: log.status.toWorkStatus().pastTenseDisplayName,
          latitude: log.latitude,
          longitude: log.longitude,
        );
      }).toList();

      isLoading = false;
      notifyListeners();
    });
  }

  List<WorkLog> getLogsForDate(DateTime date) {
    return workLogs.where((log) => _isSameDay(log.date, date)).toList();
  }

  double calculateTotalHours(List<WorkLog> logs) {
    DateTime? clockIn;
    DateTime? breakStart;
    int totalMinutes = 0;
    int breakMinutes = 0;

    for (var log in logs) {
      WorkStatus status = log.status.toWorkStatus();

      if (status == WorkStatus.clockIn) {
        clockIn = log.date;
      } else if (status == WorkStatus.clockOut && clockIn != null) {
        totalMinutes += log.date.difference(clockIn).inMinutes;
        clockIn = null;
      } else if (status == WorkStatus.onBreak) {
        breakStart = log.date;
      } else if (status == WorkStatus.endBreak && breakStart != null) {
        breakMinutes += log.date.difference(breakStart).inMinutes;
        breakStart = null;
      }
    }

    if (clockIn != null) {
      totalMinutes += DateTime.now().difference(clockIn).inMinutes;
    }

    double totalHours = (totalMinutes - breakMinutes) / 60.0;
    return totalHours;
  }


  Widget getMapWidget(double lat, double lon, int zoom) {
    return _mapRepository.fetchMapWidget(lat, lon, zoom);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}