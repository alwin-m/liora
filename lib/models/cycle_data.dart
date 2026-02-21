import 'package:cloud_firestore/cloud_firestore.dart';

class CycleDataModel {
  final DateTime lastPeriodStartDate;
  final int averageCycleLength;
  final int averagePeriodDuration;

  CycleDataModel({
    required this.lastPeriodStartDate,
    required this.averageCycleLength,
    required this.averagePeriodDuration,
  });

  // Computed properties
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

  // Regularity is a placeholder for now as requested
  String get regularity => "Regular";

  Map<String, dynamic> toJson() => {
    'lastPeriodStartDate': lastPeriodStartDate.toIso8601String(),
    'averageCycleLength': averageCycleLength,
    'averagePeriodDuration': averagePeriodDuration,
  };

  factory CycleDataModel.fromJson(Map<String, dynamic> json) => CycleDataModel(
    lastPeriodStartDate: DateTime.parse(json['lastPeriodStartDate']),
    averageCycleLength: json['averageCycleLength'],
    averagePeriodDuration: json['averagePeriodDuration'],
  );

  factory CycleDataModel.fromFirestore(Map<String, dynamic> data) =>
      CycleDataModel(
        lastPeriodStartDate: (data['lastPeriodDate'] as Timestamp).toDate(),
        averageCycleLength: data['cycleLength'] ?? 28,
        averagePeriodDuration: data['periodLength'] ?? 5,
      );
}
