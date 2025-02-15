import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xnmoapp/screens/splash.dart';
import 'package:xnmoapp/widgets/activity_card.dart';
import 'package:xnmoapp/widgets/status.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigate to SplashScreen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false, // Removes all routes from the stack
    );
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
      body: ListView(
        children: [
          StatusCard(),   // Fetches live status
          ActivityCard(), // Fetches and displays live activity
        ],
      ),
    );
  }
}
