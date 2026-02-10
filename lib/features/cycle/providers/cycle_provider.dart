import 'package:flutter/material.dart';
import '../../../core/engine/prediction_engine.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';

/// CycleProvider - Cycle Tracking State Management
///
/// Manages cycle state and provides reactive updates to UI.
/// All data operations happen locally on the device.
class CycleProvider extends ChangeNotifier {
  final PredictionEngine _engine = PredictionEngine.instance;
  final StorageService _storage = StorageService.instance;
  final NotificationService _notifications = NotificationService.instance;

  CycleState _cycleState = CycleState.noData();
  CalendarPredictions _predictions = CalendarPredictions.empty();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  CycleState get cycleState => _cycleState;
  CalendarPredictions get predictions => _predictions;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  CycleProvider() {
    refresh();
  }

  /// Refresh cycle state from local storage
  Future<void> refresh() async {
    _setLoading(true);

    _cycleState = _engine.getCycleState();
    _predictions = _engine.getCalendarPredictions();

    // Reschedule notifications based on predictions
    await _notifications.rescheduleNotifications(_cycleState.nextPeriodDate);

    _setLoading(false);
  }

  /// Select a date on the calendar
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Get day type for a specific date
  DayType getDayType(DateTime date) {
    return _engine.getDayType(date);
  }

  /// Check if a date is the selected date
  bool isSelectedDate(DateTime date) {
    return _isSameDay(_selectedDate, date);
  }

  /// Check if a date is today
  bool isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  /// Log period start
  Future<void> logPeriodStart(DateTime date) async {
    _setLoading(true);

    await _engine.logPeriodStart(date);
    await refresh();

    _setLoading(false);
  }

  /// Toggle period day
  Future<void> togglePeriodDay(DateTime date) async {
    final currentlyPeriod = _storage.isPeriodDay(date);
    await _engine.logPeriodDay(date, !currentlyPeriod);
    await refresh();
  }

  /// Mark a day as period
  Future<void> markPeriodDay(DateTime date, bool isPeriod) async {
    await _engine.logPeriodDay(date, isPeriod);
    await refresh();
  }

  /// Log symptoms for selected date
  Future<void> logSymptoms(List<String> symptoms) async {
    await _storage.saveSymptoms(_selectedDate, symptoms);
    notifyListeners();
  }

  /// Get symptoms for selected date
  List<String> getSymptoms() {
    return _storage.getSymptoms(_selectedDate);
  }

  /// Log flow intensity for selected date
  Future<void> logFlowIntensity(String intensity) async {
    await _storage.saveFlowIntensity(_selectedDate, intensity);
    notifyListeners();
  }

  /// Get flow intensity for selected date
  String? getFlowIntensity() {
    return _storage.getFlowIntensity(_selectedDate);
  }

  /// Log mood for selected date
  Future<void> logMood(String mood) async {
    await _storage.saveMood(_selectedDate, mood);
    notifyListeners();
  }

  /// Get mood for selected date
  String? getMood() {
    return _storage.getMood(_selectedDate);
  }

  /// Log notes for selected date
  Future<void> logNotes(String notes) async {
    await _storage.saveNotes(_selectedDate, notes);
    notifyListeners();
  }

  /// Get notes for selected date
  String? getNotes() {
    return _storage.getNotes(_selectedDate);
  }

  /// Check if selected date is a period day
  bool isSelectedDayPeriod() {
    return _storage.isPeriodDay(_selectedDate);
  }

  /// Get selected date info
  SelectedDayInfo getSelectedDayInfo() {
    final dayType = getDayType(_selectedDate);
    final symptoms = getSymptoms();
    final flow = getFlowIntensity();
    final mood = getMood();
    final notes = getNotes();

    return SelectedDayInfo(
      date: _selectedDate,
      dayType: dayType,
      isPeriod: _storage.isPeriodDay(_selectedDate),
      symptoms: symptoms,
      flowIntensity: flow,
      mood: mood,
      notes: notes,
    );
  }

  // =====================
  // PRIVATE HELPERS
  // =====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Selected day information
class SelectedDayInfo {
  final DateTime date;
  final DayType dayType;
  final bool isPeriod;
  final List<String> symptoms;
  final String? flowIntensity;
  final String? mood;
  final String? notes;

  const SelectedDayInfo({
    required this.date,
    required this.dayType,
    required this.isPeriod,
    required this.symptoms,
    this.flowIntensity,
    this.mood,
    this.notes,
  });
}
