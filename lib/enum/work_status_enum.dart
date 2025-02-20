enum WorkStatus {
  clockIn("CLOCKEDIN", "Clock In", "Clocked In"),
  onBreak("ONBREAK", "Take Break", "Took Break"),
  endBreak("ENDBREAK", "End Break", "Ended Break"),
  clockOut("CLOCKEDOUT", "Clock Out", "Clocked Out");

  final String backendValue;
  final String displayName;
  final String pastTenseDisplayName;

  const WorkStatus(this.backendValue, this.displayName, this.pastTenseDisplayName);
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
