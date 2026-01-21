import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local menstrual history stored only on device (no Firebase)
class LocalCycleStorage {
  static const String _periodEventsKey = 'period_events';
  static const String _notificationsKey = 'notifications';

  /// Period event stored locally
  static Future<void> savePeriodEvent({
    required DateTime date,
    required String type, // 'start' or 'end'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final events = _getEvents(prefs);
    
    // Remove any existing event on this date for this type
    events.removeWhere((e) => 
      e['date'] == date.toIso8601String().split('T')[0] && 
      e['type'] == type
    );
    
    // Add new event
    events.add({
      'date': date.toIso8601String().split('T')[0],
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_periodEventsKey, jsonEncode(events));
  }

  /// Get all stored period events
  static Future<List<Map<String, dynamic>>> getPeriodEvents() async {
    final prefs = await SharedPreferences.getInstance();
    return _getEvents(prefs);
  }

  /// Get period start date for a given month (local data)
  static Future<DateTime?> getPeriodStartForMonth(int month, int year) async {
    final events = await getPeriodEvents();
    
    for (var event in events) {
      if (event['type'] == 'start') {
        final eventDate = DateTime.parse(event['date']);
        if (eventDate.month == month && eventDate.year == year) {
          return eventDate;
        }
      }
    }
    return null;
  }

  /// Get period end date for a given month (local data)
  static Future<DateTime?> getPeriodEndForMonth(int month, int year) async {
    final events = await getPeriodEvents();
    
    DateTime? latestEnd;
    for (var event in events) {
      if (event['type'] == 'end') {
        final eventDate = DateTime.parse(event['date']);
        if (eventDate.month == month && eventDate.year == year) {
          latestEnd = eventDate;
        }
      }
    }
    return latestEnd;
  }

  /// Calculate actual bleeding days from stored events
  static Future<int> getActualPeriodLength() async {
    final events = await getPeriodEvents();
    
    DateTime? lastStart;
    DateTime? lastEnd;
    
    for (var event in events) {
      final eventDate = DateTime.parse(event['date']);
      if (event['type'] == 'start') {
        lastStart = eventDate;
      } else if (event['type'] == 'end') {
        lastEnd = eventDate;
      }
    }
    
    if (lastStart != null && lastEnd != null) {
      return lastEnd.difference(lastStart).inDays + 1;
    }
    return 0;
  }

  /// Calculate actual cycle length from consecutive period starts
  static Future<int> getActualCycleLength() async {
    final events = await getPeriodEvents();
    
    final startDates = events
        .where((e) => e['type'] == 'start')
        .map((e) => DateTime.parse(e['date']))
        .toList()
        ..sort();
    
    if (startDates.length < 2) return 0;
    
    // Average of all cycle lengths
    int totalDays = 0;
    for (int i = 1; i < startDates.length; i++) {
      totalDays += startDates[i].difference(startDates[i - 1]).inDays;
    }
    
    return (totalDays / (startDates.length - 1)).round();
  }

  /// Check if user manually marked period start today
  static Future<bool> isPeriodStartMarked(DateTime date) async {
    final events = await getPeriodEvents();
    
    final dateStr = date.toIso8601String().split('T')[0];
    return events.any((e) => 
      e['date'] == dateStr && e['type'] == 'start'
    );
  }

  /// Check if user manually marked period end today
  static Future<bool> isPeriodEndMarked(DateTime date) async {
    final events = await getPeriodEvents();
    
    final dateStr = date.toIso8601String().split('T')[0];
    return events.any((e) => 
      e['date'] == dateStr && e['type'] == 'end'
    );
  }

  /// Get notification settings
  static Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_notificationsKey);
    
    if (json == null) {
      return {
        'cycleReminder': true,
        'periodReminder': true,
      };
    }
    
    return Map<String, bool>.from(jsonDecode(json));
  }

  /// Save notification settings
  static Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, jsonEncode(settings));
  }

  /// Clear all local data (on logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_periodEventsKey);
    await prefs.remove(_notificationsKey);
  }

  // ==================== HELPERS ====================

  static List<Map<String, dynamic>> _getEvents(SharedPreferences prefs) {
    final json = prefs.getString(_periodEventsKey);
    if (json == null) return [];
    
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(json));
    } catch (e) {
      return [];
    }
  }
}
