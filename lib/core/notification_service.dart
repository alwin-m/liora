import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int reminderTwoDaysId = 100;
  static const int reminderOneDayId = 101;
  static const int reminderPeriodDayId = 102;

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
      "Login ചെയ്തിട്ട് 10 seconds കഴിഞ്ഞ് വരുന്ന test notification",
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
          'period_channel',
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
}