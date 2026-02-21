import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cycle_data.dart';
import '../models/cycle_history_entry.dart';

class CycleProvider with ChangeNotifier {
  CycleDataModel? _cycleData;
  List<CycleHistoryEntry> _history = [];
  bool _isLoading = true;

  CycleDataModel? get cycleData => _cycleData;
  List<CycleHistoryEntry> get history => _history;
  bool get isLoading => _isLoading;

  static const String _storageKey = 'liora_cycle_data';

  CycleProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // 1. Try Local Storage (SharedPreferences) as the primary source of truth for local use
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getString(_storageKey);

    if (localData != null) {
      final decoded = jsonDecode(localData);
      _cycleData = CycleDataModel.fromJson(decoded['current']);
      if (decoded['history'] != null) {
        _history = (decoded['history'] as List)
            .map((e) => CycleHistoryEntry.fromJson(e))
            .toList();
      }
    }

    // 2. Sync with Firestore if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final firestoreData = CycleDataModel.fromFirestore(doc.data()!);

          // If local data is missing or different, update it
          if (_cycleData == null || _isDifferent(_cycleData!, firestoreData)) {
            _cycleData = firestoreData;
            await _saveLocal(_cycleData!);
          }
        }
      } catch (e) {
        debugPrint("Error syncing with Firestore: $e");
      }
    }

    // fallback to default if still null
    if (_cycleData == null) {
      _cycleData = CycleDataModel(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 14)),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Auto-generate some dummy history for visual testing if requested
      if (_history.isEmpty) {
        _history = [
          CycleHistoryEntry(
            predictedStartDate: DateTime.now().subtract(
              const Duration(days: 42),
            ),
            actualStartDate: DateTime.now().subtract(const Duration(days: 42)),
            cycleLength: 28,
            periodDuration: 5,
            predictionDeviationDays: 0,
          ),
          CycleHistoryEntry(
            predictedStartDate: DateTime.now().subtract(
              const Duration(days: 70),
            ),
            actualStartDate: DateTime.now().subtract(const Duration(days: 72)),
            cycleLength: 30,
            periodDuration: 6,
            predictionDeviationDays: 2,
          ),
        ];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  bool _isDifferent(CycleDataModel a, CycleDataModel b) {
    return a.lastPeriodStartDate != b.lastPeriodStartDate ||
        a.averageCycleLength != b.averageCycleLength ||
        a.averagePeriodDuration != b.averagePeriodDuration;
  }

  Future<void> updateCycleData({
    required DateTime lastPeriodStartDate,
    required int averageCycleLength,
    required int averagePeriodDuration,
  }) async {
    final newData = CycleDataModel(
      lastPeriodStartDate: lastPeriodStartDate,
      averageCycleLength: averageCycleLength,
      averagePeriodDuration: averagePeriodDuration,
    );

    _cycleData = newData;
    notifyListeners();

    // Persistent storage
    await _saveLocal(newData);
    await _saveRemote(newData);
  }

  Future<void> _saveLocal(CycleDataModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'current': data.toJson(),
        'history': _history.map((e) => e.toJson()).toList(),
      }),
    );
  }

  Future<void> _saveRemote(CycleDataModel data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'lastPeriodDate': data.lastPeriodStartDate,
            'cycleLength': data.averageCycleLength,
            'periodLength': data.averagePeriodDuration,
            'profileCompleted': true,
          });
    } catch (e) {
      debugPrint("Error saving to Firestore: $e");
    }
  }
}
