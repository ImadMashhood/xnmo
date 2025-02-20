import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xnmoapp/objects/work_data_source.dart';
import 'package:xnmoapp/objects/work_logs.dart';
import 'package:xnmoapp/view_models/activity_view_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:xnmoapp/reusable_components/expandable_card.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActivityViewModel(),
      child: Consumer<ActivityViewModel>(
        builder: (context, viewModel, child) {
          return ExpandableCard(
            title: "Work Activity",
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                SfCalendar(
                  view: CalendarView.month,
                  dataSource: WorkDataSource(viewModel.workLogs),
                  monthCellBuilder: (context, details) =>
                      _buildMonthCell(details, viewModel.workLogs),
                  onTap: (CalendarTapDetails details) {
                    if (details.date != null) {
                      viewModel.selectedDate = details.date;
                      viewModel.notifyListeners();
                    }
                  },
                ),
                if (viewModel.selectedDate != null)
                  _buildExpandedView(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, ActivityViewModel viewModel) {
    List<WorkLog> logs = viewModel.getLogsForDate(viewModel.selectedDate!);
    double totalHours = viewModel.calculateTotalHours(logs);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Hours Worked: ${totalHours.toStringAsFixed(2)} hrs",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          logs.isEmpty
              ? const Text("No logs for this day.")
              : Column(
            children:
            logs.map((log) => _buildLogEntry(context, log, viewModel)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, WorkLog log, ActivityViewModel viewModel) {
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
    bool hasLogs = logs.any((log) => _isSameDay(log.date, details.date));

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
