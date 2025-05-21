import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xnmoapp/reusable_components/expandable_card.dart';
import 'package:xnmoapp/screens/user_work_activity_screen.dart';
import 'package:xnmoapp/view_models/admin_view_model.dart';

class AdminCard extends StatelessWidget {
  const AdminCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminViewModel(),
      child: Consumer<AdminViewModel>(
        builder: (context, viewModel, child) {
          return ExpandableCard(
            title: "Admin Panel",
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: viewModel.users.isEmpty
                  ? [const Text("No users found.")]
                  : viewModel.users.map((user) {
                return ListTile(
                  title: Text(user['email'] ?? 'Unknown'),
                  subtitle: Text(user['isAdmin'] == true ? 'Admin' : 'User'),
                  trailing: const Icon(Icons.chevron_right), // <- Chevron added here
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserWorkActivityScreen(
                          userId: user['id'],
                          email: user['email'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
