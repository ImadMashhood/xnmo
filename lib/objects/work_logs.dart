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