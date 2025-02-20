import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xnmoapp/enum/work_status_enum.dart';
import 'package:xnmoapp/view_models/status_view_model.dart';
import 'package:xnmoapp/reusable_components/expandable_card.dart';
import 'package:shimmer/shimmer.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatusViewModel(),
      child: Consumer<StatusViewModel>(
        builder: (context, viewModel, child) {
          return ExpandableCard(
            title: "Status",
            child: Column(
              children: [
                viewModel.isFetchingStatus
                    ? _buildShimmerText()
                    : Text(
                  viewModel.statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (viewModel.isLoading) const Center(child: CircularProgressIndicator()),
                if (!viewModel.isLoading && viewModel.isFetchingStatus) _buildShimmerButtons(),
                if (!viewModel.isLoading && !viewModel.isFetchingStatus)
                  Column(
                    children: [
                      _buildActionButton(context, WorkStatus.clockIn, Colors.green),
                      const SizedBox(height: 16),
                      _buildActionButton(context, WorkStatus.onBreak, Colors.orange),
                      const SizedBox(height: 16),
                      _buildActionButton(context, WorkStatus.endBreak, Colors.blue),
                      const SizedBox(height: 16),
                      _buildActionButton(context, WorkStatus.clockOut, Colors.red),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WorkStatus status, Color color) {
    final viewModel = Provider.of<StatusViewModel>(context, listen: false);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: viewModel.isButtonEnabled(status) ? color : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: viewModel.isButtonEnabled(status) ? () => viewModel.logAction(status) : null,
        child: Text(status.displayName),
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
