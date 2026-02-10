import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

/// OnboardingProvider - First-Time User Flow State Management
///
/// Manages the AirPods-style bottom sheet onboarding flow:
/// - One question per screen
/// - Soft progress indicator
/// - Skip allowed
class OnboardingProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  int _currentStep = 0;
  bool _isComplete = false;
  bool _isLoading = false;

  // Onboarding data
  DateTime? _dateOfBirth;
  DateTime? _lastMenstrualPeriod;
  int _averageCycleLength = 28;
  int _averagePeriodLength = 5;
  List<String> _wellnessFlags = [];

  int get currentStep => _currentStep;
  bool get isComplete => _isComplete;
  bool get isLoading => _isLoading;
  int get totalSteps => 5;
  double get progress => (_currentStep + 1) / totalSteps;

  DateTime? get dateOfBirth => _dateOfBirth;
  DateTime? get lastMenstrualPeriod => _lastMenstrualPeriod;
  int get averageCycleLength => _averageCycleLength;
  int get averagePeriodLength => _averagePeriodLength;
  List<String> get wellnessFlags => _wellnessFlags;

  OnboardingProvider() {
    _checkOnboardingStatus();
  }

  void _checkOnboardingStatus() {
    _isComplete = _storage.isOnboardingComplete();
    notifyListeners();
  }

  /// Check if onboarding is needed
  bool get needsOnboarding => !_isComplete;

  /// Go to next step
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Skip to next step (for optional questions)
  void skip() {
    nextStep();
  }

  /// Set date of birth
  void setDateOfBirth(DateTime date) {
    _dateOfBirth = date;
    notifyListeners();
  }

  /// Set last menstrual period date
  void setLastMenstrualPeriod(DateTime date) {
    _lastMenstrualPeriod = date;
    notifyListeners();
  }

  /// Set average cycle length
  void setAverageCycleLength(int days) {
    _averageCycleLength = days;
    notifyListeners();
  }

  /// Set average period length
  void setAveragePeriodLength(int days) {
    _averagePeriodLength = days;
    notifyListeners();
  }

  /// Toggle wellness flag
  void toggleWellnessFlag(String flag) {
    if (_wellnessFlags.contains(flag)) {
      _wellnessFlags.remove(flag);
    } else {
      _wellnessFlags.add(flag);
    }
    notifyListeners();
  }

  /// Set wellness flags
  void setWellnessFlags(List<String> flags) {
    _wellnessFlags = flags;
    notifyListeners();
  }

  /// Complete onboarding and save data
  Future<bool> completeOnboarding() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Save user profile data locally
      await _storage.saveUserProfile(
        dateOfBirth: _dateOfBirth,
        lastMenstrualPeriod: _lastMenstrualPeriod,
        averageCycleLength: _averageCycleLength,
        averagePeriodLength: _averagePeriodLength,
        wellnessFlags: _wellnessFlags,
      );

      // If LMP was provided, log it as a period start
      if (_lastMenstrualPeriod != null) {
        await _storage.savePeriodStart(_lastMenstrualPeriod!);
      }

      // Mark onboarding as complete
      await _storage.setOnboardingComplete(true);
      _isComplete = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset onboarding (for testing)
  void reset() {
    _currentStep = 0;
    _dateOfBirth = null;
    _lastMenstrualPeriod = null;
    _averageCycleLength = 28;
    _averagePeriodLength = 5;
    _wellnessFlags = [];
    notifyListeners();
  }

  /// Get step title
  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return "When were you born?";
      case 1:
        return "When did your last period start?";
      case 2:
        return "How long is your typical cycle?";
      case 3:
        return "How many days does your period usually last?";
      case 4:
        return "Any wellness concerns to track?";
      default:
        return "";
    }
  }

  /// Get step subtitle
  String getStepSubtitle(int step) {
    switch (step) {
      case 0:
        return "This helps us personalize your experience";
      case 1:
        return "It's okay if you're not sure – just estimate";
      case 2:
        return "The average is 28 days, but everyone is different";
      case 3:
        return "Most periods last 3-7 days";
      case 4:
        return "Optional – you can always update this later";
      default:
        return "";
    }
  }

  /// Check if current step can proceed
  bool canProceed() {
    switch (_currentStep) {
      case 0:
        return _dateOfBirth != null;
      case 1:
        return _lastMenstrualPeriod != null;
      case 2:
      case 3:
        return true; // These have default values
      case 4:
        return true; // Optional
      default:
        return false;
    }
  }

  /// Check if current step is skippable
  bool isSkippable() {
    return _currentStep == 4; // Only wellness flags are skippable
  }
}

/// Wellness flags available during onboarding
class WellnessFlags {
  static const String hairFall = 'hair_fall';
  static const String cramps = 'cramps';
  static const String moodSwings = 'mood_swings';
  static const String bloating = 'bloating';
  static const String headaches = 'headaches';
  static const String fatigue = 'fatigue';
  static const String acne = 'acne';
  static const String breastTenderness = 'breast_tenderness';

  static const List<WellnessFlagData> all = [
    WellnessFlagData(id: hairFall, label: 'Hair fall', emoji: '💇'),
    WellnessFlagData(id: cramps, label: 'Cramps', emoji: '😣'),
    WellnessFlagData(id: moodSwings, label: 'Mood swings', emoji: '🎭'),
    WellnessFlagData(id: bloating, label: 'Bloating', emoji: '🫃'),
    WellnessFlagData(id: headaches, label: 'Headaches', emoji: '🤕'),
    WellnessFlagData(id: fatigue, label: 'Fatigue', emoji: '😴'),
    WellnessFlagData(id: acne, label: 'Acne', emoji: '🔴'),
    WellnessFlagData(
        id: breastTenderness, label: 'Breast tenderness', emoji: '💔'),
  ];
}

class WellnessFlagData {
  final String id;
  final String label;
  final String emoji;

  const WellnessFlagData({
    required this.id,
    required this.label,
    required this.emoji,
  });
}
