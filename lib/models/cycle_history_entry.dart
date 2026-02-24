class CycleHistoryEntry {
  final String recordId;
  final DateTime initialInputDate;
  final DateTime predictedNextDate;
  final DateTime? actualLoggedDate;
  final int observedCycleLengthDays;
  final int deviationDays;
  final DateTime modificationTimestamp;
  final int version;

  CycleHistoryEntry({
    required this.recordId,
    required this.initialInputDate,
    required this.predictedNextDate,
    this.actualLoggedDate,
    required this.observedCycleLengthDays,
    required this.deviationDays,
    required this.modificationTimestamp,
    required this.version,
  });

  Map<String, dynamic> toJson() => {
    'recordId': recordId,
    'initialInputDate': initialInputDate.toIso8601String(),
    'predictedNextDate': predictedNextDate.toIso8601String(),
    'actualLoggedDate': actualLoggedDate?.toIso8601String(),
    'observedCycleLengthDays': observedCycleLengthDays,
    'deviationDays': deviationDays,
    'modificationTimestamp': modificationTimestamp.toIso8601String(),
    'version': version,
  };

  factory CycleHistoryEntry.fromJson(Map<String, dynamic> json) =>
      CycleHistoryEntry(
        recordId: json['recordId'] ?? '',
        initialInputDate: DateTime.parse(json['initialInputDate']),
        predictedNextDate: DateTime.parse(json['predictedNextDate']),
        actualLoggedDate: json['actualLoggedDate'] != null
            ? DateTime.parse(json['actualLoggedDate'])
            : null,
        observedCycleLengthDays: json['observedCycleLengthDays'],
        deviationDays: json['deviationDays'],
        modificationTimestamp: DateTime.parse(json['modificationTimestamp']),
        version: json['version'] ?? 1,
      );
}
