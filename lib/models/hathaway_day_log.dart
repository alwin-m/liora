/// PRIVACY: LOCAL ONLY — never transmitted, never stored in cloud.
class HathawayDayLog {
  final int dayNumber;   // 1-based
  final DateTime date;
  final int flowPercent; // 0–100 (user-reported)
  final int painLevel;   // 0=none 1=mild 2=moderate 3=severe
  final bool confirmed;

  const HathawayDayLog({
    required this.dayNumber,
    required this.date,
    required this.flowPercent,
    required this.painLevel,
    this.confirmed = true,
  });

  HathawayDayLog copyWith({int? flowPercent, int? painLevel}) =>
      HathawayDayLog(
        dayNumber: dayNumber,
        date: date,
        flowPercent: flowPercent ?? this.flowPercent,
        painLevel: painLevel ?? this.painLevel,
        confirmed: true,
      );

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'date': date.toIso8601String(),
        'flowPercent': flowPercent,
        'painLevel': painLevel,
        'confirmed': confirmed,
      };

  factory HathawayDayLog.fromJson(Map<String, dynamic> j) => HathawayDayLog(
        dayNumber: j['dayNumber'],
        date: DateTime.parse(j['date']),
        flowPercent: j['flowPercent'],
        painLevel: j['painLevel'],
        confirmed: j['confirmed'] ?? true,
      );
}
