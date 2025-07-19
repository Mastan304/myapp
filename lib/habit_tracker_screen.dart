import 'package:flutter/material.dart';
import '/home/runner/work/myapp/myapp/lib/models/habit.dart'; // Import the Habit model
import '/home/runner/work/myapp/myapp/lib/database/database_helper.dart'; // Import the DatabaseHelper
import '/home/runner/work/myapp/myapp/lib/new_habit_screen.dart'; // Import the NewHabitScreen
import '/home/runner/work/myapp/myapp/lib/models/completion.dart'; // Import the Completion model
import '/home/runner/work/myapp/myapp/lib/habit_details_screen.dart'; // Import HabitDetailsScreen
import '/home/runner/work/myapp/myapp/lib/utils/date_utils.dart'; // Import DateUtils


// A widget to display a single habit card
class HabitWidget extends StatefulWidget {
  final Habit habit;

  HabitWidget({required this.habit});

  @override
  _HabitWidgetState createState() => _HabitWidgetState();
}

class _HabitWidgetState extends State<HabitWidget> {
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


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () { // HabitWidget onTap
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HabitDetailsScreen(habit: widget.habit)));
        // TODO: Navigate to Habit Details/Completion screen
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Icon(
                IconData(widget.habit.iconCodePoint, fontFamily: 'MaterialIcons'),
                size: 80.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.habit.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
             Text(
              'Current: ${widget.habit.currentStreak} days | Longest: ${widget.habit.longestStreak} days',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.0),
             Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    _isCompletedToday ? Icons.check_box : Icons.check_box_outline_blank,
                    color: _isCompletedToday ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () async {
                    if (!_isCompletedToday && widget.habit.id != null) {
                      // Mark as completed
                      final now = DateTime.now();
                      final completion = Completion(
 key: now.millisecondsSinceEpoch, // Using timestamp as key for simplicity
 habitId: widget.habit.id!,
 completionDate: now.millisecondsSinceEpoch,
                      );
                      await DatabaseHelper().insertCompletion(completion);
                      final lastCompletionTimestamp = await DatabaseHelper().getLastCompletionDateForHabit(widget.habit.id!);
                      final DateTime? lastCompletionDate = lastCompletionTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(lastCompletionTimestamp) : null;

                      // Calculate the new current streak
                      int newCurrentStreak = widget.habit.currentStreak;
                      if (lastCompletionDate == null) {
                        // First completion
                        newCurrentStreak = 1;
                      } else if (DateUtils.isYesterday(lastCompletionDate.millisecondsSinceEpoch)) {
                        newCurrentStreak++;
                      } else {
                        // Completed after a gap
                        newCurrentStreak = 1;
 }
                      int newLongestStreak = newCurrentStreak > widget.habit.longestStreak ? newCurrentStreak : widget.habit.longestStreak;
                      }

                      // Update the habit in the database
                      await DatabaseHelper().updateHabit(widget.habit.copyWith(
                        currentStreak: newCurrentStreak,
                        longestStreak: newCurrentStreak > widget.habit.longestStreak ? newCurrentStreak : widget.habit.longestStreak,
                      ));

                      // Refresh the widget state to show updated streaks and completion status
                      _checkCompletionStatus();
                    } else if (_isCompletedToday && widget.habit.id != null) {
                      // Optional: Implement logic to unmark completion
                      // This would involve deleting the completion record for today
                      // and potentially recalculating streaks.
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HabitTrackerScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  List<Habit> _habits = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        actions: [
 IconButton(icon: Icon(Icons.add), onPressed: () async {
 await Navigator.push(context, MaterialPageRoute(builder: (context) => NewHabitScreen()));
 _loadHabits();  }),
      ),
      body: ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          return HabitWidget(habit: _habits[index]);
        },
      ),
    );
  }
}