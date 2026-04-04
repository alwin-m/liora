import 'package:cloud_firestore/cloud_firestore.dart';

class SleepSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SleepInterruption> interruptions;
  final Duration totalSleepTime;
  final double qualityScore; // 0-1
  final bool isActive;

  SleepSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.interruptions = const [],
    this.totalSleepTime = Duration.zero,
    this.qualityScore = 0.0,
    this.isActive = false,
  });

  Duration get duration =>
      endTime != null ? endTime!.difference(startTime) : Duration.zero;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'interruptions': interruptions.map((i) => i.toMap()).toList(),
      'totalSleepTime': totalSleepTime.inSeconds,
      'qualityScore': qualityScore,
      'isActive': isActive,
    };
  }

  factory SleepSession.fromMap(Map<String, dynamic> map) {
    return SleepSession(
      id: map['id'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      interruptions:
          (map['interruptions'] as List<dynamic>?)
              ?.map((i) => SleepInterruption.fromMap(i))
              .toList() ??
          [],
      totalSleepTime: Duration(seconds: map['totalSleepTime'] ?? 0),
      qualityScore: map['qualityScore'] ?? 0.0,
      isActive: map['isActive'] ?? false,
    );
  }

  SleepSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<SleepInterruption>? interruptions,
    Duration? totalSleepTime,
    double? qualityScore,
    bool? isActive,
  }) {
    return SleepSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      interruptions: interruptions ?? this.interruptions,
      totalSleepTime: totalSleepTime ?? this.totalSleepTime,
      qualityScore: qualityScore ?? this.qualityScore,
      isActive: isActive ?? this.isActive,
    );
  }
}

class SleepInterruption {
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final String type; // 'wake_up', 'bathroom', 'unknown'

  SleepInterruption({
    required this.startTime,
    this.endTime,
    this.duration = Duration.zero,
    this.type = 'unknown',
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration.inSeconds,
      'type': type,
    };
  }

  factory SleepInterruption.fromMap(Map<String, dynamic> map) {
    return SleepInterruption(
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      duration: Duration(seconds: map['duration'] ?? 0),
      type: map['type'] ?? 'unknown',
    );
  }
}

class DailySleepData {
  final DateTime date;
  final List<SleepSession> sessions;
  final Duration totalSleep;
  final double averageQuality;

  DailySleepData({
    required this.date,
    this.sessions = const [],
    this.totalSleep = Duration.zero,
    this.averageQuality = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'totalSleep': totalSleep.inSeconds,
      'averageQuality': averageQuality,
    };
  }

  factory DailySleepData.fromMap(Map<String, dynamic> map) {
    return DailySleepData(
      date: (map['date'] as Timestamp).toDate(),
      sessions:
          (map['sessions'] as List<dynamic>?)
              ?.map((s) => SleepSession.fromMap(s))
              .toList() ??
          [],
      totalSleep: Duration(seconds: map['totalSleep'] ?? 0),
      averageQuality: map['averageQuality'] ?? 0.0,
    );
  }
}
