/// DAILY BLEEDING FLOW TRACKING MODEL
///
/// Users log daily bleeding data to personalize ML model predictions
/// This data trains the model to understand their unique patterns

class DailyBleedingEntry {
  /// Unique identifier for this log entry
  final String id;

  /// Date of this bleeding observation
  final DateTime date;

  /// Bleeding intensity (1-7 scale)
  /// 1 = spotting, 4 = medium, 7 = very heavy
  final int intensity;

  /// Optional: Duration of bleeding (if user tracks it)
  /// For example, on Day 3 they might know it lasted 30 mins
  final int? durationMinutes;

  /// Optional: User description of flow
  /// Can include: "heavy with clots", "light spotting", "normal flow"
  final String? flowDescription;

  /// Optional: Color observation
  /// Helps model understand different cycle phases
  final String? color; // e.g., "bright red", "dark red", "brown"

  /// Whether this is a confirmed/actual bleed (vs predicted)
  /// true = actual observed, false = predicted
  final bool isActualObserved;

  /// Timestamp when user logged this entry
  final DateTime loggedAt;

  /// Version of the data model (for future migrations)
  final int version;

  DailyBleedingEntry({
    required this.id,
    required this.date,
    required this.intensity,
    this.durationMinutes,
    this.flowDescription,
    this.color,
    this.isActualObserved = false,
    required this.loggedAt,
    this.version = 1,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'intensity': intensity,
      'durationMinutes': durationMinutes,
      'flowDescription': flowDescription,
      'color': color,
      'isActualObserved': isActualObserved,
      'loggedAt': loggedAt.toIso8601String(),
      'version': version,
    };
  }

  /// Create from JSON
  factory DailyBleedingEntry.fromJson(Map<String, dynamic> json) {
    return DailyBleedingEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      intensity: json['intensity'] as int,
      durationMinutes: json['durationMinutes'] as int?,
      flowDescription: json['flowDescription'] as String?,
      color: json['color'] as String?,
      isActualObserved: json['isActualObserved'] as bool? ?? false,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      version: json['version'] as int? ?? 1,
    );
  }

  /// Create a copy with modifications
  DailyBleedingEntry copyWith({
    String? id,
    DateTime? date,
    int? intensity,
    int? durationMinutes,
    String? flowDescription,
    String? color,
    bool? isActualObserved,
    DateTime? loggedAt,
    int? version,
  }) {
    return DailyBleedingEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      intensity: intensity ?? this.intensity,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      flowDescription: flowDescription ?? this.flowDescription,
      color: color ?? this.color,
      isActualObserved: isActualObserved ?? this.isActualObserved,
      loggedAt: loggedAt ?? this.loggedAt,
      version: version ?? this.version,
    );
  }
}

/// Container for a period's complete bleeding data
class PeriodBleedingHistory {
  /// ID of the period this belongs to
  final String periodId;

  /// Date period started
  final DateTime periodStartDate;

  /// All daily bleeding entries for this period
  final List<DailyBleedingEntry> dailyEntries;

  /// Actual duration (once period ends)
  /// Null while period is ongoing
  final int? actualDurationDays;

  /// Summary statistics computed from daily entries
  final PeriodBleedingSummary? summary;

  PeriodBleedingHistory({
    required this.periodId,
    required this.periodStartDate,
    required this.dailyEntries,
    this.actualDurationDays,
    this.summary,
  });

  /// Calculate statistics from daily entries
  PeriodBleedingSummary computeSummary() {
    if (dailyEntries.isEmpty) {
      return PeriodBleedingSummary(
        averageIntensity: 0.0,
        maxIntensity: 0,
        minIntensity: 0,
        totalDays: 0,
      );
    }

    final intensities = dailyEntries.map((e) => e.intensity).toList();

    return PeriodBleedingSummary(
      averageIntensity:
          intensities.reduce((a, b) => a + b) / intensities.length,
      maxIntensity: intensities.reduce((a, b) => a > b ? a : b),
      minIntensity: intensities.reduce((a, b) => a < b ? a : b),
      totalDays: dailyEntries.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodId': periodId,
      'periodStartDate': periodStartDate.toIso8601String(),
      'dailyEntries': dailyEntries.map((e) => e.toJson()).toList(),
      'actualDurationDays': actualDurationDays,
      'summary': summary?.toJson(),
    };
  }

  factory PeriodBleedingHistory.fromJson(Map<String, dynamic> json) {
    return PeriodBleedingHistory(
      periodId: json['periodId'] as String,
      periodStartDate: DateTime.parse(json['periodStartDate'] as String),
      dailyEntries: (json['dailyEntries'] as List)
          .map((e) => DailyBleedingEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      actualDurationDays: json['actualDurationDays'] as int?,
      summary: json['summary'] != null
          ? PeriodBleedingSummary.fromJson(
              json['summary'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Statistics summarizing a period's bleeding patterns
class PeriodBleedingSummary {
  final double averageIntensity;
  final int maxIntensity;
  final int minIntensity;
  final int totalDays;

  PeriodBleedingSummary({
    required this.averageIntensity,
    required this.maxIntensity,
    required this.minIntensity,
    required this.totalDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageIntensity': averageIntensity,
      'maxIntensity': maxIntensity,
      'minIntensity': minIntensity,
      'totalDays': totalDays,
    };
  }

  factory PeriodBleedingSummary.fromJson(Map<String, dynamic> json) {
    return PeriodBleedingSummary(
      averageIntensity: (json['averageIntensity'] as num).toDouble(),
      maxIntensity: json['maxIntensity'] as int,
      minIntensity: json['minIntensity'] as int,
      totalDays: json['totalDays'] as int,
    );
  }
}
