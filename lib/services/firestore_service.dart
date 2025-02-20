import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot?> getLastStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('timestamps')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  }

  Future<void> addTimestamp(String status, double lat, double lon) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    Timestamp now = Timestamp.now();

    await _firestore.collection('users').doc(user.uid).collection('timestamps').add({
      'status': status,
      'timestamp': now,
      'location': {'lat': lat, 'lon': lon},
    });
  }

  Stream<QuerySnapshot> streamActivityLogs() {
    User? user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('timestamps')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
