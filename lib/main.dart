import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/habit_tracker_screen.dart'; // Assuming this is your main screen
import 'package:myapp/database/database_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon'); // Replace 'app_icon' with your app's launcher icon name

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // iOS initialization settings are handled by the DarwinInitializationSettings
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
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
      home: HabitTrackerScreen(), // Set your main habit tracker screen here
    );
  }
}
