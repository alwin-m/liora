import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../home/cycle_algorithm.dart';

class CycleSession {
  // 🔄 REACTIVE: ValueNotifier broadcasts changes to all listeners
  static late ValueNotifier<CycleAlgorithm> _algorithmNotifier;

  static ValueNotifier<CycleAlgorithm> get algorithmNotifier =>
      _algorithmNotifier;

  // ✅ Initialize notifier (call this on app startup)
  static void initialize() {
    _algorithmNotifier = ValueNotifier<CycleAlgorithm>(
      CycleAlgorithm(
        lastPeriod: DateTime.now(),
        cycleLength: 28,
        periodLength: 5,
      ),
    );
  }

  // 📡 Get current algorithm (synchronous)
  static CycleAlgorithm get algorithm => _algorithmNotifier.value;

  // 🔄 SET algorithm and notify all listeners (reactive)
  static void setAlgorithm(CycleAlgorithm algo) {
    _algorithmNotifier.value = algo;
  }

  /// 🔥 SAVE cycle data to Firestore
  static Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final algo = algorithm;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'lastPeriodDate': algo.lastPeriod,
      'cycleLength': algo.cycleLength,
      'periodLength': algo.periodLength,
      'profileCompleted': true,
    });
  }

  /// 🔄 LOAD cycle data from Firestore and notify listeners
  static Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setAlgorithm(
        CycleAlgorithm(
          lastPeriod: DateTime.now(),
          cycleLength: 28,
          periodLength: 5,
        ),
      );
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      setAlgorithm(
        CycleAlgorithm(
          lastPeriod: DateTime.now(),
          cycleLength: 28,
          periodLength: 5,
        ),
      );
      return;
    }

    final data = doc.data()!;

    if (data['lastPeriodDate'] != null) {
      setAlgorithm(
        CycleAlgorithm(
          lastPeriod: (data['lastPeriodDate'] as Timestamp).toDate(),
          cycleLength: data['cycleLength'] ?? 28,
          periodLength: data['periodLength'] ?? 5,
        ),
      );
    } else {
      setAlgorithm(
        CycleAlgorithm(
          lastPeriod: DateTime.now(),
          cycleLength: data['cycleLength'] ?? 28,
          periodLength: data['periodLength'] ?? 5,
        ),
      );
    }
  }
}
