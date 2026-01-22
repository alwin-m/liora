/// Represents a single confirmed menstrual cycle in history
class CycleHistoryEntry {
  final DateTime cycleStartDate;
  final DateTime? cycleEndDate;
  final int cycleLength; // Days from start to next start
  final int bleedingLength; // Days of actual bleeding
  final bool isConfirmed; // true if both start and end are marked by user

  CycleHistoryEntry({
    required this.cycleStartDate,
    this.cycleEndDate,
    required this.cycleLength,
    required this.bleedingLength,
    this.isConfirmed = false,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'cycleStartDate': cycleStartDate.toIso8601String(),
      'cycleEndDate': cycleEndDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'bleedingLength': bleedingLength,
      'isConfirmed': isConfirmed,
    };
  }

  /// Create from JSON
  factory CycleHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CycleHistoryEntry(
      cycleStartDate: DateTime.parse(json['cycleStartDate']),
      cycleEndDate: json['cycleEndDate'] != null 
          ? DateTime.parse(json['cycleEndDate']) 
          : null,
      cycleLength: json['cycleLength'],
      bleedingLength: json['bleedingLength'],
      isConfirmed: json['isConfirmed'] ?? false,
    );
  }
}
