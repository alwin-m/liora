import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  factory NotificationService() {
    return _instance;
  }

  Future<void> _initializeNotifications() async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iOSInitializationSettings,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Request notification permission from the device
  Future<bool> requestNotificationPermission() async {
    try {
      final granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Schedule a notification for 3 days before the period start date
  Future<void> scheduleCycleReminder(DateTime periodStartDate) async {
    try {
      // Calculate 3 days before the period
      final reminderDate = periodStartDate.subtract(const Duration(days: 3));

      // Only schedule if the reminder date is in the future
      if (reminderDate.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          0, // notification id
          'Period Reminder',
          'Your period is expected to start in 3 days',
          tz.TZDateTime.from(reminderDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'cycle_reminders_channel',
              'Cycle Reminders',
              channelDescription: 'Notifications for cycle reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        // Save preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('cycle_reminders_enabled', true);
      }
    } catch (e) {
      debugPrint('Error scheduling cycle reminder: $e');
    }
  }

  /// Cancel all cycle reminders
  Future<void> cancelCycleReminders() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(0);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cycle_reminders_enabled', false);
    } catch (e) {
      debugPrint('Error canceling cycle reminders: $e');
    }
  }

  /// Check if cycle reminders are enabled
  Future<bool> isCycleRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('cycle_reminders_enabled') ?? false;
  }

  /// Schedule a delivery reminder notification
  Future<void> scheduleDeliveryReminder(
    DateTime deliveryDate,
    String productName,
  ) async {
    try {
      // Schedule notification 1 day before delivery
      final reminderDate = deliveryDate.subtract(const Duration(days: 1));

      if (reminderDate.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          1, // notification id for delivery reminders
          'Delivery Reminder',
          'Your order for "$productName" will be delivered tomorrow',
          tz.TZDateTime.from(reminderDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'delivery_reminders_channel',
              'Delivery Reminders',
              channelDescription: 'Notifications for order deliveries',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('delivery_reminders_enabled', true);
      }
    } catch (e) {
      debugPrint('Error scheduling delivery reminder: $e');
    }
  }

  /// Cancel delivery reminders
  Future<void> cancelDeliveryReminders() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(1);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('delivery_reminders_enabled', false);
    } catch (e) {
      debugPrint('Error canceling delivery reminders: $e');
    }
  }

  /// Check if delivery reminders are enabled
  Future<bool> isDeliveryRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('delivery_reminders_enabled') ?? false;
  }
}
