import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationManager {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    final silentChannel = AndroidNotificationChannel(
      'silent_channel',
      'Silent Notifications',
      description: 'For noticing, no sound, no vibration',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(silentChannel);
  }

  Future<void> scheduleHabitReminder({
    required int habitId,
    required String question,
    required TimeOfDay time,
    required List<int> reminderDays,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'silent_channel',
      'Habit Reminders',
      channelDescription: 'Reminders for your habits',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final now = DateTime.now();

    for (final day in reminderDays) {
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        habitId * 10 + day,
        'Habit Reminder',
        question,
        tzDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> showSimpleNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'silent_channel',
      'Test Notifications',
      channelDescription: 'Just for testing',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // Plattform-übergreifende Details
    const notificationDetails = NotificationDetails(android: androidDetails);

    // Notification anzeigen
    await _plugin.show(
      0,
      'Wenn du was brauchst,',
      'schick mir eine Benachrichtigung ;)',
      notificationDetails,
    );
  }

  /// Cancel all notifications for a specific habit
  Future<void> cancelHabitReminder(int habitId) async {
    await _plugin.cancel(habitId);
  }
}
