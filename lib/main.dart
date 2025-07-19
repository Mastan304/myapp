import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/habit_tracker_screen.dart'; // Assuming this is your main screen
import 'package:myapp/database/database_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {},
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('app_icon'), // Replace 'app_icon' with your app's launcher icon name
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      // Handle notification tap
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
    },
  );

  // Access the database getter to ensure initialization
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HabitTrackerScreen(), // Set your main habit tracker screen here
    );
  }
}
