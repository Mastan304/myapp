import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/completion.dart';


class HabitCompletionScreen extends StatefulWidget {
  final Habit habit;

  HabitCompletionScreen({required this.habit});

  @override
  _HabitCompletionScreenState createState() => _HabitCompletionScreenState();
}

class _HabitCompletionScreenState extends State<HabitCompletionScreen> {
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
          .map((completion) => DateTime.fromMillisecondsSinceEpoch(completion.completionDate * 1000))
          .toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
      ),
      body: Column(
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
        (date) => DateUtils.isSameDay(date.millisecondsSinceEpoch, selectedDay.millisecondsSinceEpoch));

    if (isCompleted) {
      // Unmark completion
      if (widget.habit.id != null) {
        await DatabaseHelper().deleteCompletionForHabitAndDate(
            widget.habit.id!, selectedDay.millisecondsSinceEpoch);
        setState(() {
          _completedDates.removeWhere(
              (date) => DateUtils.isSameDay(date.millisecondsSinceEpoch, selectedDay.millisecondsSinceEpoch));
        });

        // Recalculate streaks after unmarking
        final sortedCompletedDates = _completedDates.toList()..sort();
        int currentStreak = 0;
        int longestStreak = 0;

        if (sortedCompletedDates.isNotEmpty) {
          // Calculate current streak
          final now = DateTime.now();
          if (DateUtils.isSameDay(sortedCompletedDates.last.millisecondsSinceEpoch, now.millisecondsSinceEpoch)) {
             currentStreak = 1;
             DateTime lastDate = sortedCompletedDates.last;
             for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
               if (DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
                 currentStreak++;
                 lastDate = sortedCompletedDates[i];
               } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)) {
                  break;
               }
             }
          } else {
              final yesterday = now.subtract(const Duration(days: 1));
               if (DateUtils.isSameDay(sortedCompletedDates.last.millisecondsSinceEpoch, yesterday.millisecondsSinceEpoch)) {
                 currentStreak = 1;
                 DateTime lastDate = sortedCompletedDates.last;
                 for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
                   if (DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
                     currentStreak++;
                     lastDate = sortedCompletedDates[i];
                   } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)) {
                     break;
                   }
                 }
               } else {
                 currentStreak = 0;
               }
          }


          // Calculate longest streak
          int tempStreak = 0;
          DateTime? lastDate = null;
          for (int i = 0; i < sortedCompletedDates.length; i++) {
             if (lastDate == null || DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
              tempStreak++;
            } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)){
              tempStreak = 1;
            }

            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
            lastDate = sortedCompletedDates[i];
          }
        }

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
        final sortedCompletedDates = _completedDates.toList()..sort();
        int currentStreak = 0;
        int longestStreak = 0;

        if (sortedCompletedDates.isNotEmpty) {
          // Calculate current streak
          final now = DateTime.now();
          if (DateUtils.isSameDay(sortedCompletedDates.last.millisecondsSinceEpoch, now.millisecondsSinceEpoch)) {
             currentStreak = 1;
             DateTime lastDate = sortedCompletedDates.last;
             for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
               if (DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
                 currentStreak++;
                 lastDate = sortedCompletedDates[i];
               } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)) {
                  break;
               }
             }
          } else {
              final yesterday = now.subtract(const Duration(days: 1));
               if (DateUtils.isSameDay(sortedCompletedDates.last.millisecondsSinceEpoch, yesterday.millisecondsSinceEpoch)) {
                 currentStreak = 1;
                 DateTime lastDate = sortedCompletedDates.last;
                 for (int i = sortedCompletedDates.length - 2; i >= 0; i--) {
                   if (DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
                     currentStreak++;
                     lastDate = sortedCompletedDates[i];
                   } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)) {
                     break;
                   }
                 }
               } else {
                 currentStreak = 0;
               }
          }


          // Calculate longest streak
          int tempStreak = 0;
          DateTime? lastDate = null;
          for (int i = 0; i < sortedCompletedDates.length; i++) {
             if (lastDate == null || DateUtils.isYesterday(sortedCompletedDates[i].millisecondsSinceEpoch)) {
              tempStreak++;
            } else if (!DateUtils.isSameDay(sortedCompletedDates[i].millisecondsSinceEpoch, lastDate.millisecondsSinceEpoch)){
              tempStreak = 1;
            }

            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
            lastDate = sortedCompletedDates[i];
          }
        }


        // Update habit object with new streaks
        widget.habit.currentStreak = currentStreak;
        widget.habit.longestStreak = longestStreak;

        // Update the habit in the database
        await DatabaseHelper().updateHabit(widget.habit);
      }
    }
  }
},

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