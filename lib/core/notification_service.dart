import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'cycle_session.dart';
import 'cycle_algorithm.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int reminderTwoDaysId = 100;
  static const int reminderOneDayId = 101;
  static const int reminderPeriodDayId = 102;
  static const int dailyCycleAlertId = 200;

  static const String periodChannelId = 'period_channel';
  static const String dailyChannelId = 'daily_cycle_channel';

  // ================= INITIALIZE =================

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initializationSettings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  // ================= TEST NOTIFICATION (10 SECONDS) =================

  static Future<void> showTestNotification() async {

    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    await _notifications.zonedSchedule(
      999,
      "🔔 Test Notification",
      "Test notification from Liora scheduled for 10 seconds from now.",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Testing notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ================= SCHEDULE REMINDERS =================

  static Future<void> reschedulePeriodReminder(
      DateTime nextPeriodDate) async {
    await cancelPeriodReminder();

    await _scheduleReminder(
      reminderTwoDaysId,
      nextPeriodDate.subtract(const Duration(days: 2)),
      "🌸 Period Reminder",
      "Your cycle is approaching in 2 days. Stay prepared 💖",
    );

    await _scheduleReminder(
      reminderOneDayId,
      nextPeriodDate.subtract(const Duration(days: 1)),
      "🌸 Period Tomorrow",
      "Your period may start tomorrow. Take care 💕",
    );

    await _scheduleReminder(
      reminderPeriodDayId,
      nextPeriodDate,
      "🌸 Period Today",
      "Your cycle may begin today. Stay comfortable and take care 🌷",
    );

    // ✅ New: Schedule Daily Alerts for next 30 days
    await scheduleDailyCycleAlerts();
  }

  // ================= DAILY CYCLE UPDATES =================

  static Future<void> scheduleDailyCycleAlerts() async {
    // 1. Cancel existing
    await cancelDailyAlerts();

    // 2. Scheduled daily updates for next 30 days
    if (!CycleSession.isInitialized) return;

    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
       final day = now.add(Duration(days: i));
       final cycleDay = CycleSession.algorithm.getCycleDay(day);
       final dayType = CycleSession.algorithm.getType(day);
       
       String title = "🌸 Liora: Cycle Day $cycleDay";
       String body = "Stay tracking your health today! 🌷";

       if (dayType == DayType.period) {
          body = "Cycle Day $cycleDay of your expected period. Take care! 💖";
       } else if (dayType == DayType.ovulation) {
          body = "Today is your highly fertile ovulation day! 🌟";
       } else if (dayType == DayType.fertile) {
          body = "You are in your fertile window. 💖";
       }

       await _scheduleDailyReminder(
          dailyCycleAlertId + i,
          day,
          title,
          body,
       );
    }
  }

  static Future<void> _scheduleDailyReminder(
      int id, DateTime date, String title, String body) async {
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      10, // Daily alert at 10:00 AM
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          dailyChannelId,
          'Daily Cycle Updates',
          channelDescription: 'Updates on your cycle status',
          importance: Importance.low, 
          priority: Priority.low,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ================= SCHEDULE SINGLE REMINDER =================

  static Future<void> _scheduleReminder(
      int id, DateTime date, String title, String body) async {

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      9,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate =
          tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          periodChannelId,
          'Period Reminders',
          channelDescription: 'Reminder for upcoming period',
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFFE91E63),
          playSound: true,
          enableVibration: true,
          vibrationPattern:
              Int64List.fromList([0, 800, 400, 800]),
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: "Liora",
          ),
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ================= CANCEL =================

  static Future<void> cancelPeriodReminder() async {
    await _notifications.cancel(reminderTwoDaysId);
    await _notifications.cancel(reminderOneDayId);
    await _notifications.cancel(reminderPeriodDayId);
  }

  static Future<void> cancelDailyAlerts() async {
    for (int i = 0; i < 30; i++) {
      await _notifications.cancel(dailyCycleAlertId + i);
    }
  }
}