import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> users = [];

  AdminViewModel() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      final snapshot = await _firestore.collection('users').get();

      users = snapshot.docs
          .where((doc) => doc.id != currentUser?.uid) // 👈 Exclude current user
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      })
          .toList();
    } catch (e) {
      users = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
