import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:xnmoapp/objects/work_data_source.dart';
import 'package:xnmoapp/objects/work_logs.dart';
import 'package:xnmoapp/view_models/user_activity_view_model.dart';

class UserWorkActivityScreen extends StatelessWidget {
  final String userId;
  final String email;

  const UserWorkActivityScreen({super.key, required this.userId, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserActivityViewModel(userId),
      child: Scaffold(
        appBar: AppBar(title: Text("Activity for $email")),
        body: Consumer<UserActivityViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                SfCalendar(
                  view: CalendarView.month,
                  dataSource: WorkDataSource(viewModel.workLogs),
                  monthCellBuilder: (context, details) => _buildMonthCell(details, viewModel.workLogs),
                  onTap: (details) {
                    if (details.date != null) {
                      viewModel.selectedDate = details.date;
                      viewModel.notifyListeners();
                    }
                  },
                ),
                if (viewModel.selectedDate != null)
                  _buildExpandedView(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedView(UserActivityViewModel viewModel) {
    final logs = viewModel.getLogsForDate(viewModel.selectedDate!);
    final totalHours = viewModel.calculateTotalHours(logs);

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text("Total Hours Worked: ${totalHours.toStringAsFixed(2)} hrs",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (logs.isEmpty)
            const Text("No logs for this day."),
          ...logs.map((log) => _buildLogEntry(viewModel, log)).toList(),
        ],
      ),
    );
  }

  Widget _buildLogEntry(UserActivityViewModel viewModel, WorkLog log) {
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
            if (log.latitude != null && log.longitude != null)
              viewModel.getMapWidget(log.latitude!, log.longitude!, 15),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCell(MonthCellDetails details, List<WorkLog> logs) {
    final hasLogs = logs.any((log) => _isSameDay(log.date, details.date));
    return Container(
      decoration: BoxDecoration(
        color: hasLogs ? Colors.green[600] : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          "${details.date.day}",
          style: TextStyle(
            color: hasLogs ? Colors.white : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
