import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/sleep_model.dart';

class SleepTrackingService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SleepSession? _currentSession;
  Timer? _interruptionTimer;
  bool _isTracking = false;

  SleepSession? get currentSession => _currentSession;
  bool get isTracking => _isTracking;

  // Start sleep tracking
  Future<void> startSleepSession() async {
    if (_isTracking) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final sessionId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    _currentSession = SleepSession(
      id: sessionId,
      startTime: DateTime.now(),
      isActive: true,
    );

    _isTracking = true;
    notifyListeners();

    // Save to Firestore
    await _saveSession(_currentSession!);

    // Start monitoring for interruptions (simplified - in real app use background service)
    _startInterruptionMonitoring();
  }

  // Stop sleep tracking
  Future<void> stopSleepSession() async {
    if (!_isTracking || _currentSession == null) return;

    final endTime = DateTime.now();
    final totalSleep = endTime.difference(_currentSession!.startTime);

    // Calculate quality score based on interruptions
    final qualityScore = _calculateQualityScore(
      _currentSession!.interruptions,
      totalSleep,
    );

    _currentSession = _currentSession!.copyWith(
      endTime: endTime,
      totalSleepTime: totalSleep,
      qualityScore: qualityScore,
      isActive: false,
    );

    _isTracking = false;
    _interruptionTimer?.cancel();
    notifyListeners();

    // Update in Firestore
    await _updateSession(_currentSession!);

    // Save daily data
    await _saveDailyData(_currentSession!);
  }

  // Record interruption (when phone is turned on during sleep)
  void recordInterruption() {
    if (!_isTracking || _currentSession == null) return;

    final interruption = SleepInterruption(startTime: DateTime.now());

    _currentSession!.interruptions.add(interruption);
    notifyListeners();

    // Auto-resume after short interruption (bathroom break)
    _interruptionTimer?.cancel();
    _interruptionTimer = Timer(const Duration(minutes: 5), () {
      // Mark as bathroom break if short
      final lastInterruption = _currentSession!.interruptions.last;
      if (lastInterruption.endTime == null) {
        final duration = DateTime.now().difference(lastInterruption.startTime);
        if (duration.inMinutes < 10) {
          _currentSession!.interruptions.last = lastInterruption.copyWith(
            endTime: DateTime.now(),
            duration: duration,
            type: 'bathroom',
          );
        }
      }
    });
  }

  // Resume after interruption
  void resumeSleep() {
    if (!_isTracking || _currentSession == null) return;

    _interruptionTimer?.cancel();
    final lastInterruption = _currentSession!.interruptions.last;
    if (lastInterruption.endTime == null) {
      final duration = DateTime.now().difference(lastInterruption.startTime);
      _currentSession!.interruptions.last = lastInterruption.copyWith(
        endTime: DateTime.now(),
        duration: duration,
        type: duration.inMinutes < 10 ? 'bathroom' : 'wake_up',
      );
    }
    notifyListeners();
  }

  double _calculateQualityScore(
    List<SleepInterruption> interruptions,
    Duration totalSleep,
  ) {
    if (totalSleep.inHours < 4) return 0.2;
    if (totalSleep.inHours > 10) return 0.8;

    final wakeUpInterruptions = interruptions
        .where((i) => i.type == 'wake_up')
        .length;
    final score =
        1.0 - (wakeUpInterruptions * 0.1) - (interruptions.length * 0.05);
    return score.clamp(0.0, 1.0);
  }

  Future<void> _saveSession(SleepSession session) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sleep_sessions')
        .doc(session.id)
        .set(session.toMap());
  }

  Future<void> _updateSession(SleepSession session) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sleep_sessions')
        .doc(session.id)
        .update(session.toMap());
  }

  Future<void> _saveDailyData(SleepSession session) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final date = DateTime(
      session.startTime.year,
      session.startTime.month,
      session.startTime.day,
    );
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_sleep')
        .doc(date.toIso8601String().split('T')[0]);

    final existing = await docRef.get();
    if (existing.exists) {
      final existingData = DailySleepData.fromMap(existing.data()!);
      final updatedSessions = [...existingData.sessions, session];
      final totalSleep = updatedSessions.fold<Duration>(
        Duration.zero,
        (sum, s) => sum + s.totalSleepTime,
      );
      final avgQuality =
          updatedSessions.map((s) => s.qualityScore).reduce((a, b) => a + b) /
          updatedSessions.length;

      final updatedData = DailySleepData(
        date: date,
        sessions: updatedSessions,
        totalSleep: totalSleep,
        averageQuality: avgQuality,
      );
      await docRef.update(updatedData.toMap());
    } else {
      final data = DailySleepData(
        date: date,
        sessions: [session],
        totalSleep: session.totalSleepTime,
        averageQuality: session.qualityScore,
      );
      await docRef.set(data.toMap());
    }
  }

  Future<List<DailySleepData>> getSleepHistory(int days) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_sleep')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return query.docs.map((doc) => DailySleepData.fromMap(doc.data())).toList();
  }

  void _startInterruptionMonitoring() {
    // In a real app, this would use platform channels to monitor screen on/off
    // For now, this is a placeholder
  }

  @override
  void dispose() {
    _interruptionTimer?.cancel();
    super.dispose();
  }
}
