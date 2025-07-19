import 'package:flutter/material.dart' as flutter_material;
import 'package:myapp/models/habit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/completion.dart';
import 'package:myapp/utils/date_utils.dart';


class HabitCompletionScreen extends flutter_material.StatefulWidget {
  final Habit habit;

  HabitCompletionScreen({flutter_material.Key? key, required this.habit}) : super(key: key);

  @override
  _HabitCompletionScreenState createState() => _HabitCompletionScreenState();
}

class _HabitCompletionScreenState extends flutter_material.State<HabitCompletionScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _completedDates = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedDates();
  }

  Future<void> _loadCompletedDates() async {
    if (widget.habit.id == null) return;

    final completions = await DatabaseHelper().getCompletionsForHabit(widget.habit.id!);
    setState(() {
      _completedDates = completions
          .map((completion) => DateTime.fromMillisecondsSinceEpoch(completion.completionDate))
          .toList();
    });
  }


  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    return flutter_material.Scaffold(
      appBar: flutter_material.AppBar(
        title: flutter_material.Text(widget.habit.name),
      ),
      body: flutter_material.Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) async {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                // Check if the habit was completed on this day
                final isCompleted = _completedDates.any(
                    (date) => isSameDay(date, selectedDay));

                if (isCompleted) {
                  // Unmark completion
                  if (widget.habit.id != null) {
                    await DatabaseHelper().deleteCompletionForHabitAndDate(
                        widget.habit.id!, selectedDay.millisecondsSinceEpoch);
                    setState(() {
                      _completedDates.removeWhere(
                          (date) => isSameDay(date, selectedDay));
                    });

                    // Recalculate streaks after unmarking
                    final currentStreak = DateUtils.calculateCurrentStreak(_completedDates);
                    final longestStreak = DateUtils.calculateLongestStreak(_completedDates);

                    // Update habit object with new streaks
                    widget.habit.currentStreak = currentStreak;
                    widget.habit.longestStreak = longestStreak;

                    // Update the habit in the database
                    await DatabaseHelper().updateHabit(widget.habit);
                  }
                } else {
                  // Mark completion
                  if (widget.habit.id != null) {
                    final completion = Completion(
                        habitId: widget.habit.id!,
                        completionDate: selectedDay.millisecondsSinceEpoch);
                    await DatabaseHelper().insertCompletion(completion);
                    setState(() {
                      _completedDates.add(selectedDay);
                    });

                    // Recalculate streaks after marking
                    final currentStreak = DateUtils.calculateCurrentStreak(_completedDates);
                    final longestStreak = DateUtils.calculateLongestStreak(_completedDates);


                    // Update habit object with new streaks
                    widget.habit.currentStreak = currentStreak;
                    widget.habit.longestStreak = longestStreak;

                    // Update the habit in the database
                    await DatabaseHelper().updateHabit(widget.habit);
                  }
                }
              }
            },

            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _completedDates.any((completedDay) => isSameDay(completedDay, day))
                  ? [true] // Return a non-empty list if completed
                  : []; // Return an empty list if not completed
            },
          ),
          // TODO: Display habit completion status for the selected day
          // TODO: Add UI to mark/unmark completion
        ],
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}