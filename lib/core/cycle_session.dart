import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/cycle_algorithm.dart';

class CycleSession {
  static late CycleAlgorithm algorithm;

  /// 🔥 SAVE cycle data to Firestore
  static Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'lastPeriodDate': algorithm.lastPeriod,
      'cycleLength': algorithm.cycleLength,
      'periodLength': algorithm.periodLength,
      'profileCompleted': true, // Mark as complete
    });
  }

  /// 🔄 LOAD cycle data from Firestore
  static Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // ✅ Initialize with default if no user
      algorithm = CycleAlgorithm(
        lastPeriod: DateTime.now(),
        cycleLength: 28,
        periodLength: 5,
      );
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      // ✅ Initialize with default if document doesn't exist
      algorithm = CycleAlgorithm(
        lastPeriod: DateTime.now(),
        cycleLength: 28,
        periodLength: 5,
      );
      return;
    }

    final data = doc.data()!;

    // Safety check: if data is missing, use defaults or don't crash
    if (data['lastPeriodDate'] != null) {
      algorithm = CycleAlgorithm(
        lastPeriod: (data['lastPeriodDate'] as Timestamp).toDate(),
        cycleLength: data['cycleLength'] ?? 28,
        periodLength: data['periodLength'] ?? 5,
      );
    } else {
      // ✅ Initialize with default if lastPeriodDate is null
      algorithm = CycleAlgorithm(
        lastPeriod: DateTime.now(),
        cycleLength: data['cycleLength'] ?? 28,
        periodLength: data['periodLength'] ?? 5,
      );
    }
  }
}
