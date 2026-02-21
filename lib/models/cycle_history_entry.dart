class CycleHistoryEntry {
  final DateTime predictedStartDate;
  final DateTime? actualStartDate;
  final int cycleLength;
  final int periodDuration;
  final int predictionDeviationDays;

  CycleHistoryEntry({
    required this.predictedStartDate,
    this.actualStartDate,
    required this.cycleLength,
    required this.periodDuration,
    required this.predictionDeviationDays,
  });

  Map<String, dynamic> toJson() => {
    'predictedStartDate': predictedStartDate.toIso8601String(),
    'actualStartDate': actualStartDate?.toIso8601String(),
    'cycleLength': cycleLength,
    'periodDuration': periodDuration,
    'predictionDeviationDays': predictionDeviationDays,
  };

  factory CycleHistoryEntry.fromJson(Map<String, dynamic> json) =>
      CycleHistoryEntry(
        predictedStartDate: DateTime.parse(json['predictedStartDate']),
        actualStartDate: json['actualStartDate'] != null
            ? DateTime.parse(json['actualStartDate'])
            : null,
        cycleLength: json['cycleLength'],
        periodDuration: json['periodDuration'],
        predictionDeviationDays: json['predictionDeviationDays'],
      );
}
