import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/cycle_algorithm.dart';

class CycleDataService {
  static final CycleDataService _instance = CycleDataService._internal();

  factory CycleDataService() {
    return _instance;
  }

  CycleDataService._internal();

  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  int _periodDuration = 5;
  bool _dataLoaded = false;

  bool get isDataLoaded => _dataLoaded;
  DateTime? get lastPeriodDate => _lastPeriodDate;
  int get cycleLength => _cycleLength;
  int get periodDuration => _periodDuration;

  late CycleAlgorithm _algorithm;

  /// Get real-time stream of user's cycle data from Firestore
  Stream<void> getUserCycleDataStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        _lastPeriodDate = (data?['lastPeriodDate'] as Timestamp?)?.toDate();
        _cycleLength = data?['cycleLength'] ?? 28;
        _periodDuration = data?['periodDuration'] ?? 5;

        if (_lastPeriodDate != null) {
          _algorithm = CycleAlgorithm(
            lastPeriod: _lastPeriodDate!,
            cycleLength: _cycleLength,
            periodLength: _periodDuration,
          );
          _dataLoaded = true;
        } else {
          _dataLoaded = false;
        }
      } else {
        _dataLoaded = false;
      }
    });
  }

  /// Fetch user's cycle data from Firestore (one-time)
  Future<void> loadUserCycleData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _dataLoaded = false;
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        _lastPeriodDate = (data?['lastPeriodDate'] as Timestamp?)?.toDate();
        _cycleLength = data?['cycleLength'] ?? 28;
        _periodDuration = data?['periodDuration'] ?? 5;

        if (_lastPeriodDate != null) {
          _algorithm = CycleAlgorithm(
            lastPeriod: _lastPeriodDate!,
            cycleLength: _cycleLength,
            periodLength: _periodDuration,
          );
          _dataLoaded = true;
        }
      }
    } catch (e) {
      print('Error loading cycle data: $e');
      _dataLoaded = false;
    }
  }

  /// Update user's cycle data
  Future<void> updateCycleData({
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodDuration,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'lastPeriodDate': Timestamp.fromDate(lastPeriodDate),
        'cycleLength': cycleLength,
        'periodDuration': periodDuration,
        'setupCompleted': true,
        'setupDate': Timestamp.now(),
      });

      // Update local data
      _lastPeriodDate = lastPeriodDate;
      _cycleLength = cycleLength;
      _periodDuration = periodDuration;
      _algorithm = CycleAlgorithm(
        lastPeriod: lastPeriodDate,
        cycleLength: cycleLength,
        periodLength: periodDuration,
      );
      _dataLoaded = true;
    } catch (e) {
      print('Error updating cycle data: $e');
    }
  }

  /// Get day type for a specific date
  DayType getDayType(DateTime date) {
    if (!_dataLoaded || _lastPeriodDate == null) {
      return DayType.normal;
    }
    return _algorithm.getType(date);
  }

  /// Calculate next period start date
  DateTime? getNextPeriodStartDate() {
    if (!_dataLoaded || _lastPeriodDate == null) return null;
    
    final today = DateTime.now();
    final diff = today.difference(_lastPeriodDate!).inDays;
    final daysIntoCurrentCycle = diff % _cycleLength;
    final daysUntilNextPeriod = _cycleLength - daysIntoCurrentCycle;
    
    return today.add(Duration(days: daysUntilNextPeriod));
  }

  /// Calculate next period date range
  DateRange? getNextPeriodDateRange() {
    final nextStart = getNextPeriodStartDate();
    if (nextStart == null) return null;

    final nextEnd = nextStart.add(Duration(days: _periodDuration - 1));
    return DateRange(start: nextStart, end: nextEnd);
  }

  /// Get current cycle day
  int getCurrentCycleDay() {
    if (!_dataLoaded || _lastPeriodDate == null) return 0;
    
    final today = DateTime.now();
    final diff = today.difference(_lastPeriodDate!).inDays;
    return (diff % _cycleLength) + 1;
  }

  /// Reset instance (for testing)
  void reset() {
    _dataLoaded = false;
    _lastPeriodDate = null;
    _cycleLength = 28;
    _periodDuration = 5;
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  String get formattedString {
    final startMonth = _monthName(start.month);
    final endMonth = _monthName(end.month);
    
    if (start.month == end.month) {
      return '$startMonth ${start.day} - ${end.day}';
    } else {
      return '$startMonth ${start.day} - $endMonth ${end.day}';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
