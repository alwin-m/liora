/// PERIOD EDITOR PROVIDER
///
/// Manages state for period editing, blood flow tracking, and ML learning
/// Handles user corrections to cycle predictions

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/period_editor_model.dart';
import '../models/smart_prediction_model.dart';

class PeriodEditorProvider extends ChangeNotifier {
  // ======== STATE ========

  /// Currently editing date
  DateTime? _editingDate;

  /// Current period cycle being edited
  PeriodCycleEdit? _currentCycleEdit;

  /// All completed cycle edits
  List<PeriodCycleEdit> _cycleHistory = [];

  /// Blood flow history
  BloodFlowHistory? _bloodFlowHistory;

  /// Latest prediction for comparison
  SmartCyclePrediction? _latestPrediction;

  /// Accuracy tracking
  double _currentAccuracy = 0.82; // Starting at 82%
  double _targetAccuracy = 0.95; // Target 95%

  /// ML service reference
  dynamic _mlService;

  /// Loading state
  bool _isLoading = false;
  String _statusMessage = '';

  // ======== GETTERS ========

  DateTime? get editingDate => _editingDate;
  PeriodCycleEdit? get currentCycleEdit => _currentCycleEdit;
  List<PeriodCycleEdit> get cycleHistory => _cycleHistory;
  BloodFlowHistory? get bloodFlowHistory => _bloodFlowHistory;
  SmartCyclePrediction? get latestPrediction => _latestPrediction;
  double get currentAccuracy => _currentAccuracy;
  double get targetAccuracy => _targetAccuracy;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;

  /// Get improvement needed (target - current)
  double get accuracyImprovement => targetAccuracy - currentAccuracy;

  // ======== INITIALIZATION ========

  /// Initialize provider with dependencies
  Future<void> initialize({required dynamic mlService}) async {
    _mlService = mlService;
    await _loadCycleHistory();
    notifyListeners();
  }

  // ======== PERIOD EDITING ========

  /// Start editing for a specific date
  void startEditingDate(DateTime date, {SmartCyclePrediction? prediction}) {
    _editingDate = DateTime(date.year, date.month, date.day);
    _latestPrediction = prediction;
    notifyListeners();
  }

  /// Stop editing
  void stopEditing() {
    _editingDate = null;
    notifyListeners();
  }

  /// Add or update daily period edit
  Future<void> updateDailyPeriodEdit({
    required DateTime date,
    required bool hadBleeding,
    required BloodFlowIntensity flowIntensity,
    required int painLevel,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _statusMessage = 'Updating period data...';
      notifyListeners();

      // Create daily edit
      final dailyEdit = DailyPeriodEdit(
        date: DateTime(date.year, date.month, date.day),
        hadBleeding: hadBleeding,
        flowIntensity: flowIntensity,
        painLevel: painLevel,
        wasPredicted: _latestPrediction != null,
        deviationDays: _calculateDeviation(date),
        editedAt: DateTime.now(),
        notes: notes,
      );

      // Update or create cycle edit
      _currentCycleEdit ??= _createNewCycleEdit(date);

      // Add or update daily edit
      final existingIndex = _currentCycleEdit!.dailyEdits.indexWhere(
        (e) => e.date == dailyEdit.date,
      );

      if (existingIndex >= 0) {
        _currentCycleEdit!.dailyEdits[existingIndex] = dailyEdit;
      } else {
        _currentCycleEdit!.dailyEdits.add(dailyEdit);
      }

      // Detect deviations
      _detectDeviations();

      // Auto-save to local storage
      await _saveCycleHistory();

      // Trigger ML update if available
      if (_mlService != null) {
        await _updateMLModel();
      }

      _statusMessage = 'Period data updated ✓';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error updating: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Mark period as started on specific date
  Future<void> markPeriodStart(DateTime startDate) async {
    if (_currentCycleEdit == null) {
      _currentCycleEdit = _createNewCycleEdit(startDate);
    }

    _currentCycleEdit = _currentCycleEdit!.rebuild(actualStartDate: startDate);

    await _saveCycleHistory();
    notifyListeners();
  }

  /// Mark period as ended on specific date
  Future<void> markPeriodEnd(DateTime endDate) async {
    if (_currentCycleEdit == null) return;

    _currentCycleEdit = _currentCycleEdit!.rebuild(actualEndDate: endDate);

    await _saveCycleHistory();
    notifyListeners();
  }

  // ======== BLOOD FLOW VISUALIZATION ========

  /// Get blood flow for specific day
  BloodFlowIntensity getFlowForDay(DateTime date) {
    if (_currentCycleEdit == null) return BloodFlowIntensity.none;

    final edit = _currentCycleEdit!.dailyEdits.firstWhere(
      (e) => e.date == DateTime(date.year, date.month, date.day),
      orElse: () => DailyPeriodEdit(
        date: date,
        hadBleeding: false,
        flowIntensity: BloodFlowIntensity.none,
        painLevel: 0,
        wasPredicted: false,
        deviationDays: 0,
        editedAt: DateTime.now(),
      ),
    );

    return edit.hadBleeding ? edit.flowIntensity : BloodFlowIntensity.none;
  }

  // ======== DEVIATION DETECTION ========

  /// Calculate deviation from prediction
  int _calculateDeviation(DateTime date) {
    if (_latestPrediction == null) return 0;

    final predicted = _latestPrediction!.nextPeriodDate;
    return date.difference(predicted).inDays;
  }

  /// Detect deviations from predictions
  void _detectDeviations() {
    if (_currentCycleEdit == null || _latestPrediction == null) return;

    final actual = _currentCycleEdit!.actualStartDate;
    final predicted = _latestPrediction!.nextPeriodDate;
    final daysDiff = actual.difference(predicted).inDays;

    // Determine deviation type
    DeviationType type = DeviationType.none;
    if (daysDiff < -2) {
      type = DeviationType.early;
    } else if (daysDiff > 2) {
      type = DeviationType.late;
    }

    if (type != DeviationType.none) {
      // Store deviation in cycle edit
      _currentCycleEdit!.rebuild(totalDeviationDays: daysDiff.abs());
    }
  }

  // ======== ACCURACY TRACKING ========

  /// Update accuracy based on latest cycle
  Future<void> _updateAccuracy() async {
    if (_cycleHistory.isEmpty) return;

    // Calculate accuracy from recent cycles (last 3)
    final recentCycles = _cycleHistory.length > 3
        ? _cycleHistory.sublist(_cycleHistory.length - 3)
        : _cycleHistory;

    final avgAccuracy =
        recentCycles
            .map((c) => c.calculateAccuracy() / 100)
            .reduce((a, b) => a + b) /
        recentCycles.length;

    _currentAccuracy = (avgAccuracy * 100).clamp(0.0, 1.0);

    // Notify if target reached
    if (_currentAccuracy >= _targetAccuracy) {
      _statusMessage =
          '🎉 Target accuracy reached! (${(_currentAccuracy * 100).toStringAsFixed(1)}%)';
    }

    notifyListeners();
  }

  // ======== ML MODEL LEARNING ========

  /// Update ML model with new period data
  Future<void> _updateMLModel() async {
    if (_mlService == null || _currentCycleEdit == null) return;

    try {
      _statusMessage = 'Training model with new data...';
      notifyListeners();

      // Send update to ML service
      // This would trigger retraining or fine-tuning
      await _mlService!.updatePersonalModel(_currentCycleEdit!.actualStartDate);

      // Update accuracy
      await _updateAccuracy();

      _statusMessage = 'Model updated ✓';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error updating model: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======== PERSISTENCE ========

  /// Load cycle history from storage
  Future<void> _loadCycleHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('period_cycle_history');

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        _cycleHistory = historyList
            .map((e) => PeriodCycleEdit.fromJson(e))
            .toList();

        // Update accuracy based on history
        await _updateAccuracy();
      }
    } catch (e) {
      print('Error loading cycle history: $e');
    }
  }

  /// Save cycle history to storage
  Future<void> _saveCycleHistory() async {
    try {
      // Add current cycle to history if completed
      if (_currentCycleEdit != null &&
          _currentCycleEdit!.actualEndDate.isBefore(DateTime.now())) {
        if (!_cycleHistory.any(
          (c) => c.cycleId == _currentCycleEdit!.cycleId,
        )) {
          _cycleHistory.add(_currentCycleEdit!);
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _cycleHistory.map((e) => e.toJson()).toList(),
      );

      await prefs.setString('period_cycle_history', historyJson);
    } catch (e) {
      print('Error saving cycle history: $e');
    }
  }

  // ======== HELPERS ========

  /// Create new cycle edit
  PeriodCycleEdit _createNewCycleEdit(DateTime startDate) {
    final cycleId = 'cycle_${DateTime.now().millisecondsSinceEpoch}';

    return PeriodCycleEdit(
      cycleId: cycleId,
      predictedStartDate: _latestPrediction?.nextPeriodDate ?? startDate,
      actualStartDate: startDate,
      predictedEndDate: (_latestPrediction?.nextPeriodDate ?? startDate).add(
        Duration(
          days:
              _latestPrediction?.phaseInfo.estimatedEndDate
                  .difference(_latestPrediction!.nextPeriodDate)
                  .inDays ??
              4,
        ),
      ),
      actualEndDate: startDate.add(const Duration(days: 4)),
      dailyEdits: [],
      totalDeviationDays: 0,
      bloodFlowEditCount: 0,
      cycleCompletedAt: DateTime.now().add(const Duration(days: 5)),
    );
  }

  /// Extension for rebuilding cycle edits immutably
}

/// Extension for immutable updates
extension PeriodCycleEditRebuild on PeriodCycleEdit {
  PeriodCycleEdit rebuild({
    String? cycleId,
    DateTime? predictedStartDate,
    DateTime? actualStartDate,
    DateTime? predictedEndDate,
    DateTime? actualEndDate,
    List<DailyPeriodEdit>? dailyEdits,
    int? totalDeviationDays,
    int? bloodFlowEditCount,
    DateTime? cycleCompletedAt,
  }) {
    return PeriodCycleEdit(
      cycleId: cycleId ?? this.cycleId,
      predictedStartDate: predictedStartDate ?? this.predictedStartDate,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      predictedEndDate: predictedEndDate ?? this.predictedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      dailyEdits: dailyEdits ?? this.dailyEdits,
      totalDeviationDays: totalDeviationDays ?? this.totalDeviationDays,
      bloodFlowEditCount: bloodFlowEditCount ?? this.bloodFlowEditCount,
      cycleCompletedAt: cycleCompletedAt ?? this.cycleCompletedAt,
    );
  }
}
