class CycleRecord {
  final DateTime startDate;
  final int cycleLength;
  final DateTime predictedDate;
  final int deviation;

  CycleRecord({
    required this.startDate,
    required this.cycleLength,
    required this.predictedDate,
    required this.deviation,
  });

  // ================= JSON ENCODE =================

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'cycleLength': cycleLength,
      'predictedDate': predictedDate.toIso8601String(),
      'deviation': deviation,
    };
  }

  // ================= JSON DECODE =================

  factory CycleRecord.fromJson(Map<String, dynamic> json) {
    return CycleRecord(
      startDate: DateTime.parse(json['startDate']),
      cycleLength: json['cycleLength'],
      predictedDate: DateTime.parse(json['predictedDate']),
      deviation: json['deviation'],
    );
  }
}