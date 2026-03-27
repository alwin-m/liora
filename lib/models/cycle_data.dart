/// CycleDataModel - Medical Data - LOCAL STORAGE ONLY
///
/// PRIVACY CLASSIFICATION: STRICTLY SENSITIVE HEALTH INFORMATION
/// - Never transmitted to backend
/// - Never stored in database
/// - Exists ONLY on user's device
/// - Automatically deleted on app uninstall
class CycleDataModel {
  final DateTime lastPeriodStartDate;
  final int averageCycleLength;
  final int averagePeriodDuration;

  // Additional sensitive medical data (LOCAL ONLY)
  final String? flowLevel;
  final String? cycleRegularity;
  final String? pmsLevel;

  CycleDataModel({
    required this.lastPeriodStartDate,
    required this.averageCycleLength,
    required this.averagePeriodDuration,
    this.flowLevel,
    this.cycleRegularity,
    this.pmsLevel,
  });

  // Computed properties - all calculations done locally, offline-capable
  DateTime get computedNextPeriodStart {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedLast = DateTime(
      lastPeriodStartDate.year,
      lastPeriodStartDate.month,
      lastPeriodStartDate.day,
    );

    final diff = normalizedToday.difference(normalizedLast).inDays;
    if (diff <= 0) return normalizedLast;

    final cyclesPassed = diff ~/ averageCycleLength + 1;
    return normalizedLast.add(
      Duration(days: cyclesPassed * averageCycleLength),
    );
  }

  DateTime get computedNextPeriodEnd {
    return computedNextPeriodStart.add(
      Duration(days: averagePeriodDuration - 1),
    );
  }

  int get daysRemaining {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return computedNextPeriodStart.difference(today).inDays;
  }

  // Regularity is now stored if provided, otherwise defaults to "Regular"
  String get regularity => cycleRegularity ?? "Regular";

  /// Serialize cycle data to JSON for local storage
  Map<String, dynamic> toJson() => {
    'lastPeriodStartDate': lastPeriodStartDate.toIso8601String(),
    'averageCycleLength': averageCycleLength,
    'averagePeriodDuration': averagePeriodDuration,
    'flowLevel': flowLevel,
    'cycleRegularity': cycleRegularity,
    'pmsLevel': pmsLevel,
  };

  /// Deserialize cycle data from local JSON
  factory CycleDataModel.fromJson(Map<String, dynamic> json) => CycleDataModel(
    lastPeriodStartDate: DateTime.parse(json['lastPeriodStartDate']),
    averageCycleLength: json['averageCycleLength'],
    averagePeriodDuration: json['averagePeriodDuration'],
    flowLevel: json['flowLevel'],
    cycleRegularity: json['cycleRegularity'],
    pmsLevel: json['pmsLevel'],
  );
}
