import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:xnmoapp/objects/work_logs.dart';

class WorkDataSource extends CalendarDataSource {
  WorkDataSource(List<WorkLog> workLogs) {
    appointments = workLogs;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].date;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].date;
  }

  @override
  String getSubject(int index) {
    return appointments![index].status;
  }
}
