import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xnmoapp/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // Tracks loading state

  Future<void> _signUp() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'isAdmin': false, // Default to false, manually updated in DB if needed
        'createdAt': FieldValue.serverTimestamp(), // Timestamp of account creation
      });

      if (mounted) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        title: const Text('XNMO'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "assets/logo.jpg",
                  height: 260,
                  width: 260,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            const Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Enter your Email",
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            const Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter your password",
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            const Text("Confirm Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Re-enter your password",
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sign Up Button with Loading Indicator
            Center(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _signUp, // Disable button if loading
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Sign Up", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Login Link
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
