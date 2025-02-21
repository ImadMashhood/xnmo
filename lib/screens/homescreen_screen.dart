import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:xnmoapp/screens/splash_screen.dart';
import 'package:xnmoapp/widgets/activity_card.dart';
import 'package:xnmoapp/widgets/status_card.dart';
import 'package:xnmoapp/view_models/status_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    await Future.wait([
      Provider.of<StatusViewModel>(context, listen: false).fetchLastStatus(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            StatusCard(),
            ActivityCard(),
          ],
        ),
      ),
    );
  }
}
