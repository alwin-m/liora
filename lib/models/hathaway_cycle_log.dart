import 'hathaway_day_log.dart';

/// A single complete menstrual cycle record in the Annie Hathaway system.
/// Stores predicted start, actual start (user-confirmed), and per-day logs.
/// PRIVACY: LOCAL ONLY — never transmitted.
class HathawayCycleLog {
  final String id;
  final DateTime predictedStart;
  final DateTime? actualStart;
  final int? actualCycleLength;
  final int? actualPeriodLength;
  final List<HathawayDayLog> dayLogs;
  final DateTime createdAt;

  HathawayCycleLog({
    required this.id,
    required this.predictedStart,
    this.actualStart,
    this.actualCycleLength,
    this.actualPeriodLength,
    List<HathawayDayLog>? dayLogs,
    required this.createdAt,
  }) : dayLogs = dayLogs ?? [];

  /// Positive = started late. Negative = started early.
  int get deviation =>
      actualStart != null ? actualStart!.difference(predictedStart).inDays : 0;

  bool get hasActualStart => actualStart != null;
  bool get hasDayLogs => dayLogs.isNotEmpty;

  HathawayCycleLog copyWith({
    DateTime? actualStart,
    int? actualCycleLength,
    int? actualPeriodLength,
    List<HathawayDayLog>? dayLogs,
  }) =>
      HathawayCycleLog(
        id: id,
        predictedStart: predictedStart,
        actualStart: actualStart ?? this.actualStart,
        actualCycleLength: actualCycleLength ?? this.actualCycleLength,
        actualPeriodLength: actualPeriodLength ?? this.actualPeriodLength,
        dayLogs: dayLogs ?? List.from(this.dayLogs),
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'predictedStart': predictedStart.toIso8601String(),
        'actualStart': actualStart?.toIso8601String(),
        'actualCycleLength': actualCycleLength,
        'actualPeriodLength': actualPeriodLength,
        'dayLogs': dayLogs.map((d) => d.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory HathawayCycleLog.fromJson(Map<String, dynamic> j) =>
      HathawayCycleLog(
        id: j['id'] ?? '',
        predictedStart: DateTime.parse(j['predictedStart']),
        actualStart: j['actualStart'] != null
            ? DateTime.parse(j['actualStart'])
            : null,
        actualCycleLength: j['actualCycleLength'],
        actualPeriodLength: j['actualPeriodLength'],
        dayLogs: (j['dayLogs'] as List? ?? [])
            .map((d) => HathawayDayLog.fromJson(d as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['createdAt']),
      );
}
