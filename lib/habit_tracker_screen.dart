import 'package:flutter/material.dart' as flutter_material;
import 'package:myapp/models/habit.dart'; // Import the Habit model
import 'package:myapp/database/database_helper.dart'; // Import the DatabaseHelper
import 'package:myapp/new_habit_screen.dart'; // Import the NewHabitScreen
import 'package:myapp/models/completion.dart'; // Import the Completion model
import 'package:myapp/habit_details_screen.dart'; // Import HabitDetailsScreen
import 'package:myapp/utils/date_utils.dart'; // Import DateUtils
import 'package:myapp/services/notification_service.dart'; // Import NotificationService


// A widget to display a single habit card
class HabitWidget extends flutter_material.StatefulWidget {
  final Habit habit;
  final flutter_material.VoidCallback onDelete; // Callback to notify parent of deletion

  HabitWidget({flutter_material.Key? key, required this.habit, required this.onDelete}) : super(key: key);

  @override
  _HabitWidgetState createState() => _HabitWidgetState();
}

class _HabitWidgetState extends flutter_material.State<HabitWidget> {
  bool _isCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    if (widget.habit.id != null) {
      final completed = await DatabaseHelper().isHabitCompletedToday(widget.habit.id!);
      setState(() {
        _isCompletedToday = completed;
      });
    }
  }

  Future<void> _addCompletionWithNotes(flutter_material.BuildContext context) async {
    String? notes;
    flutter_material.TextEditingController _notesController = flutter_material.TextEditingController();

    await flutter_material.showDialog<String>(
      context: context,
      builder: (flutter_material.BuildContext dialogContext) {
        return flutter_material.AlertDialog(
          title: flutter_material.Text('Add Notes for ${widget.habit.name}'),
          content: flutter_material.TextField(
            controller: _notesController,
            decoration: flutter_material.InputDecoration(
              hintText: 'Enter your notes here (optional)',
            ),
            maxLines: 3,
          ),
          actions: <flutter_material.Widget>[
            flutter_material.TextButton(
              child: flutter_material.Text('Cancel'),
              onPressed: () {
                flutter_material.Navigator.of(dialogContext).pop();
              },
            ),
            flutter_material.TextButton(
              child: flutter_material.Text('Save'),
              onPressed: () {
                notes = _notesController.text;
                flutter_material.Navigator.of(dialogContext).pop(notes);
              },
            ),
          ],
        );
      },
    );

    if (!_isCompletedToday && widget.habit.id != null) {
      final now = DateTime.now();
      final completion = Completion(
        id: null,
        habitId: widget.habit.id!,
        completionDate: now.millisecondsSinceEpoch,
        notes: notes, // Save the notes
      );
      await DatabaseHelper().insertCompletion(completion);

      final lastCompletionTimestamp = await DatabaseHelper().getLastCompletionDateForHabit(widget.habit.id!);
      final DateTime? lastCompletionDate = lastCompletionTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(lastCompletionTimestamp) : null;

      int newCurrentStreak = widget.habit.currentStreak;
      if (lastCompletionDate == null) {
        newCurrentStreak = 1;
      } else if (DateUtils.isYesterday(lastCompletionDate)) { // Pass DateTime object directly
        newCurrentStreak++;
      } else {
        newCurrentStreak = 1;
      }

      await DatabaseHelper().updateHabit(widget.habit.copyWith(
        currentStreak: newCurrentStreak,
        longestStreak: newCurrentStreak > widget.habit.longestStreak ? newCurrentStreak : widget.habit.longestStreak,
      ));

      _checkCompletionStatus();
    }
  }


  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    return flutter_material.InkWell(
      onTap: () { // HabitWidget onTap
        flutter_material.Navigator.push(
          context,
          flutter_material.MaterialPageRoute(builder: (context) => HabitDetailsScreen(habit: widget.habit)));
        // TODO: Navigate to Habit Details/Completion screen
      },
      child: flutter_material.Card(
        margin: flutter_material.EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: flutter_material.Padding(
          padding: const flutter_material.EdgeInsets.all(16.0),
          child: flutter_material.Column(
          crossAxisAlignment: flutter_material.CrossAxisAlignment.start,
          children: <flutter_material.Widget>[
            flutter_material.ClipRRect(
              borderRadius: flutter_material.BorderRadius.circular(8.0),
              child: flutter_material.Icon(
                flutter_material.IconData(widget.habit.iconCodePoint, fontFamily: 'MaterialIcons'),
                size: 80.0,
              ),
            ),
            flutter_material.SizedBox(height: 8.0),
            flutter_material.Text(
              widget.habit.name,
              style: const flutter_material.TextStyle(
                fontSize: 18.0,
                fontWeight: flutter_material.FontWeight.bold,
              ),
            ),
            flutter_material.SizedBox(height: 4.0),
             flutter_material.Text(
              'Current: ${widget.habit.currentStreak} days | Longest: ${widget.habit.longestStreak} days',
              style: flutter_material.TextStyle( // Removed const
                fontSize: 14.0,
                color: flutter_material.Colors.grey[600],
              ),
            ),
            flutter_material.SizedBox(height: 8.0),
             flutter_material.Row(
              mainAxisAlignment: flutter_material.MainAxisAlignment.end,
              children: [
                flutter_material.IconButton(
                  icon: flutter_material.Icon(
                    _isCompletedToday ? flutter_material.Icons.check_box : flutter_material.Icons.check_box_outline_blank,
                    color: _isCompletedToday ? flutter_material.Colors.blue : flutter_material.Colors.grey,
                  ),
                  onPressed: () async {
                    if (!_isCompletedToday && widget.habit.id != null) {
                      _addCompletionWithNotes(context);
                    } else if (_isCompletedToday && widget.habit.id != null) {
                      final today = DateTime.now();
                      final startOfToday = DateTime(today.year, today.month, today.day);
                      await DatabaseHelper().deleteCompletionForHabitAndDate(widget.habit.id!, startOfToday.millisecondsSinceEpoch);

                      final completions = await DatabaseHelper().getCompletionsForHabit(widget.habit.id!);
                      final completedDates = completions.map((c) => DateTime.fromMillisecondsSinceEpoch(c.completionDate)).toList();
                      final updatedCurrentStreak = DateUtils.calculateCurrentStreak(completedDates);
                      final updatedLongestStreak = DateUtils.calculateLongestStreak(completedDates);

                      await DatabaseHelper().updateHabit(widget.habit.copyWith(
                        currentStreak: updatedCurrentStreak,
                        longestStreak: updatedLongestStreak,
                      ));

                      _checkCompletionStatus();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

class HabitTrackerScreen extends flutter_material.StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends flutter_material.State<HabitTrackerScreen> {
  List<Habit> _habits = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await DatabaseHelper().getHabits();
    setState(() {
      _habits = habits;
    });
  }

  Future<void> _deleteHabit(int habitId) async {
    await DatabaseHelper().deleteHabit(habitId);
    await _notificationService.cancelNotification(habitId);
    _loadHabits(); // Reload habits after deletion
  }

  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    return flutter_material.Scaffold(
      appBar: flutter_material.AppBar(
        title: flutter_material.Text('Habit Tracker'),
        actions: [
          flutter_material.IconButton(
            icon: flutter_material.Icon(flutter_material.Icons.add),
            onPressed: () async {
              await flutter_material.Navigator.push(
                context,
                flutter_material.MaterialPageRoute(builder: (context) => NewHabitScreen()),
              );
              _loadHabits(); // Reload habits after adding a new one
            },
          ),
        ],
      ),
      body: flutter_material.ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          return flutter_material.Dismissible(
            key: flutter_material.Key(habit.id.toString()), // Unique key for Dismissible
            direction: flutter_material.DismissDirection.endToStart,
            background: flutter_material.Container(
              color: flutter_material.Colors.red,
              alignment: flutter_material.Alignment.centerRight,
              padding: flutter_material.EdgeInsets.symmetric(horizontal: 20.0),
              child: flutter_material.Icon(flutter_material.Icons.delete, color: flutter_material.Colors.white),
            ),
            onDismissed: (direction) async {
              if (habit.id != null) {
                _deleteHabit(habit.id!); // Call delete function
                flutter_material.ScaffoldMessenger.of(context).showSnackBar(
                  flutter_material.SnackBar(content: flutter_material.Text('${habit.name} deleted')),
                );
              }
            },
            child: HabitWidget(
              habit: habit,
              onDelete: () => _deleteHabit(habit.id!), // Pass callback to HabitWidget
            ),
          );
        },
      ),
    );
  }
}
