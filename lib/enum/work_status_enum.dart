enum WorkStatus {
  clockIn("CLOCKEDIN", "Clock In"),
  onBreak("ONBREAK", "Take Break"),
  endBreak("ENDBREAK", "End Break"),
  clockOut("CLOCKEDOUT", "Clock Out");

  final String backendValue;
  final String displayName;

  const WorkStatus(this.backendValue, this.displayName);
}

extension WorkStatusExtension on String {
  WorkStatus toWorkStatus() {
    switch (this) {
      case "CLOCKEDIN":
        return WorkStatus.clockIn;
      case "ONBREAK":
        return WorkStatus.onBreak;
      case "ENDBREAK":
        return WorkStatus.endBreak;
      case "CLOCKEDOUT":
      default:
        return WorkStatus.clockOut;
    }
  }
}
