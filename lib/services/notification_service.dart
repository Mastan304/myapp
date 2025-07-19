import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tzdata.initializeTimeZones(); // Initialize timezone data

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon'); // Replace 'app_icon' with your actual app icon name

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          // Handle notification taps if needed
        });
  }

  Future<void> scheduleNotification({
    int id = 0,
    String? title,
    String? body,
    TimeOfDay? time,
    List<int>? days, // List of weekdays (1 for Monday, 7 for Sunday)
  }) async {
    if (time == null) return;

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      tz.TZDateTime.now(tz.local).year,
      tz.TZDateTime.now(tz.local).month,
      tz.TZDateTime.now(tz.local).day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past for today, schedule for the next day
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local)) && (days == null || days.isEmpty)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (days != null && days.isNotEmpty) {
      // Schedule for specific days of the week
      for (int day in days) {
        tz.TZDateTime nextNotificationDate = _nextInstanceOfWeekday(time, day);
        await notificationsPlugin.zonedSchedule(
          id + day, // Unique ID for each day of the week
          title,
          body,
          nextNotificationDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'habit_tracker_channel',
              'Habit Reminders',
              channelDescription: 'Reminders for your daily habits',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } else {
      // Schedule daily notification
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_tracker_channel',
            'Habit Reminders',
            channelDescription: 'Reminders for your daily habits',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfWeekday(TimeOfDay time, int weekday) {
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        tz.TZDateTime.now(tz.local).year,
        tz.TZDateTime.now(tz.local).month,
        tz.TZDateTime.now(tz.local).day,
        time.hour,
        time.minute,
      );

      while (scheduledDate.weekday != weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

       if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
         scheduledDate = scheduledDate.add(const Duration(days: 7));
       }
       return scheduledDate;
     }

     Future<void> cancelNotification(int id) async {
       await notificationsPlugin.cancel(id);
     }

     Future<void> cancelAllNotifications() async {
       await notificationsPlugin.cancelAll();
     }
   }
