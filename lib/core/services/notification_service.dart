import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'storage_service.dart';

/// NotificationService - Gentle, Emotionally Neutral Reminders
///
/// Notifications are:
/// - Optional
/// - Customizable
/// - Emotionally neutral (no fear, shame, or urgency)
/// 
/// Note: This is a simplified web-compatible implementation.
/// Actual device notifications require platform-specific code.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Notification IDs
  static const int periodApproachingId = 1;
  static const int periodStartId = 2;
  static const int wellnessNudgeId = 3;
  static const int logReminderId = 4;

  // Gentle notification messages
  static const Map<String, List<String>> _gentleMessages = {
    'period_approaching': [
      "Your cycle is gently approaching 🌸",
      "A little heads up: your period may arrive soon",
      "Your body's rhythm suggests your period is near",
      "Gentle reminder: your cycle continues its natural flow",
    ],
    'period_start': [
      "Welcome to a new cycle 🌷",
      "Your period has likely begun today",
      "A new cycle begins. Take care of yourself 💕",
    ],
    'wellness': [
      "How are you feeling today? 🌺",
      "Remember to hydrate and rest well 💧",
      "Your wellbeing matters. Check in with yourself 🌸",
      "A gentle moment for self-care 🌹",
    ],
    'log_reminder': [
      "Take a moment to log how you're feeling today",
      "Your daily check-in awaits 🌸",
      "A quick log helps you understand your rhythm",
    ],
  };

  /// Initialize notification service (web-safe implementation)
  Future<void> init() async {
    // Initialize timezone database
    tz_data.initializeTimeZones();
    
    // On web, notifications are not supported, but we initialize gracefully
    if (kIsWeb) {
      debugPrint('NotificationService: Running on web - notifications disabled');
      return;
    }
    
    // Platform-specific initialization would go here
    // For now, this is a no-op to maintain compatibility
    debugPrint('NotificationService initialized');
  }

  /// Schedule period approaching reminder
  Future<void> schedulePeriodApproachingReminder(
      DateTime expectedPeriodDate) async {
    if (kIsWeb) return;

    final storage = StorageService.instance;
    if (!storage.getPeriodReminderEnabled()) return;

    final daysBefore = storage.getReminderDaysBefore();
    final reminderDate =
        expectedPeriodDate.subtract(Duration(days: daysBefore));

    if (reminderDate.isBefore(DateTime.now())) return;

    final message = _getRandomMessage('period_approaching');
    debugPrint('Would schedule: $message at $reminderDate');
  }

  /// Schedule period start day reminder
  Future<void> schedulePeriodStartReminder(DateTime expectedPeriodDate) async {
    if (kIsWeb) return;

    final storage = StorageService.instance;
    if (!storage.getPeriodReminderEnabled()) return;

    if (expectedPeriodDate.isBefore(DateTime.now())) return;

    final message = _getRandomMessage('period_start');
    debugPrint('Would schedule: $message at $expectedPeriodDate');
  }

  /// Schedule daily wellness nudge
  Future<void> scheduleDailyWellnessNudge() async {
    if (kIsWeb) return;

    final storage = StorageService.instance;
    if (!storage.getDailyReminderEnabled()) return;

    final message = _getRandomMessage('wellness');
    debugPrint('Would schedule daily: $message');
  }

  /// Schedule log reminder
  Future<void> scheduleLogReminder() async {
    if (kIsWeb) return;

    final storage = StorageService.instance;
    if (!storage.getDailyReminderEnabled()) return;

    final message = _getRandomMessage('log_reminder');
    debugPrint('Would schedule log reminder: $message');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    debugPrint('Would cancel all notifications');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    debugPrint('Would cancel notification: $id');
  }

  /// Reschedule all notifications based on current predictions
  Future<void> rescheduleNotifications(DateTime? nextPeriodDate) async {
    await cancelAllNotifications();

    if (nextPeriodDate != null) {
      await schedulePeriodApproachingReminder(nextPeriodDate);
      await schedulePeriodStartReminder(nextPeriodDate);
    }

    await scheduleDailyWellnessNudge();
    await scheduleLogReminder();
  }

  // =====================
  // PRIVATE HELPERS
  // =====================

  String _getRandomMessage(String category) {
    final messages = _gentleMessages[category] ?? [''];
    return messages[DateTime.now().microsecond % messages.length];
  }
}
