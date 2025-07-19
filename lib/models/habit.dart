import 'package:flutter/material.dart';

class Habit {
  int? id;
  final String name;
  int currentStreak;
  int longestStreak;
  final String imagePath;
  final int iconCodePoint;
  final int createdTime;
  String? reminderTime;
  String? reminderDays;
  String? goalType; // e.g., 'frequency', 'quantity'
  int? goalValue; // e.g., 3 (times per week), 20 (pages per day)
  String? goalUnit; // e.g., 'times', 'pages'
  String? goalFrequency; // e.g., 'daily', 'weekly'

  Habit({
    this.id,
    required this.name,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.imagePath = '',
    required this.iconCodePoint,
    required this.createdTime,
    this.reminderTime,
    this.reminderDays,
    this.goalType,
    this.goalValue,
    this.goalUnit,
    this.goalFrequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'imagePath': imagePath,
      'iconCodePoint': iconCodePoint,
      'createdTime': createdTime,
      'reminderTime': reminderTime,
      'reminderDays': reminderDays,
      'goalType': goalType,
      'goalValue': goalValue,
      'goalUnit': goalUnit,
      'goalFrequency': goalFrequency,
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      currentStreak: map['currentStreak'] as int,
      longestStreak: map['longestStreak'] as int,
      imagePath: map['imagePath'] as String,
      iconCodePoint: map['iconCodePoint'] as int,
      createdTime: map['createdTime'] as int,
      reminderTime: map['reminderTime'] as String?,
      reminderDays: map['reminderDays'] as String?,
      goalType: map['goalType'] as String?,
      goalValue: map['goalValue'] as int?,
      goalUnit: map['goalUnit'] as String?,
      goalFrequency: map['goalFrequency'] as String?,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    int? currentStreak,
    int? longestStreak,
    String? imagePath,
    int? iconCodePoint,
    int? createdTime,
    String? reminderTime,
    String? reminderDays,
    String? goalType,
    int? goalValue,
    String? goalUnit,
    String? goalFrequency,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      imagePath: imagePath ?? this.imagePath,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdTime: createdTime ?? this.createdTime,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      goalType: goalType ?? this.goalType,
      goalValue: goalValue ?? this.goalValue,
      goalUnit: goalUnit ?? this.goalUnit,
      goalFrequency: goalFrequency ?? this.goalFrequency,
    );
  }

  // Helper to get a MaterialColor from the iconCodePoint
  MaterialColor get iconColor {
    // In a real app, you might store color as a separate field or derive it more robustly
    // This is a placeholder for demonstration.
    return Colors.blue; 
  }

  IconData get iconData {
    return IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  }
}
