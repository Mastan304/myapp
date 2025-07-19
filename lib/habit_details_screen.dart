import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // Assuming your Habit model is here
import 'package:myapp/models/completion.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/utils/date_utils.dart';
class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitDetailsScreenState createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  List<Completion> _completions = [];
  Map<int, int> _weeklyCompletionCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchCompletionData();
  }

  Future<void> _fetchCompletionData() async {
    if (widget.habit.id != null) {
      final completions = await DatabaseHelper().getCompletionsForHabit(widget.habit.id!);
      setState(() {
        _completions = completions;
        _weeklyCompletionCounts = _calculateWeeklyCompletionCounts(_completions);
      });
    }
  }

  Map<int, int> _calculateWeeklyCompletionCounts(List<Completion> completions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday

    final Map<int, int> counts = {
      1: 0, // Monday
      2: 0, // Tuesday
      3: 0, // Wednesday
      4: 0, // Thursday
      5: 0, // Friday
      6: 0, // Saturday
      7: 0, // Sunday
    };

    for (var completion in completions) {
      final completionDate = DateTime.fromMillisecondsSinceEpoch(completion.completionDate);
      if (completionDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && completionDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        counts[completionDate.weekday] = (counts[completionDate.weekday] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Name
              Text(
                widget.habit.name,
                style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Track your daily runs to improve fitness and mental clarity.', // Placeholder description
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.0),

              // Completion History Chart Placeholder
              Text(
                'Completion History',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
             Container(
                height: 150.0,
                color: Colors.grey[300], // Placeholder color
                // TODO: Implement Completion History Chart
              ),
              SizedBox(height: 24.0),

              // Statistics Placeholder
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey[100], // Placeholder color
                      child: Center(child: Text('Total Completions\nXX')), // Placeholder
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey[100], // Placeholder color
                      child: Center(child: Text('Current Streak\nXX')), // Placeholder
                    ),
                  ),
                   SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey[100], // Placeholder color
                      child: Center(child: Text('Longest Streak\nXX')), // Placeholder
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.0),

              // Milestones Placeholder
              Text(
                'Milestones',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 150.0,
                      height: 150.0,
                      color: Colors.green[200], // Placeholder color
                      margin: EdgeInsets.only(right: 16.0),
                      // TODO: Implement Milestones
                    ),
                    Container(
                      width: 150.0,
                      height: 150.0,
                      color: Colors.green[200], // Placeholder color
                      margin: EdgeInsets.only(right: 16.0),
                      // TODO: Implement Milestones
                    ),
                     Container(
                      width: 150.0,
                      height: 150.0,
                      color: Colors.green[200], // Placeholder color
                      margin: EdgeInsets.only(right: 16.0),
                      // TODO: Implement Milestones
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),

              // Notes Placeholder
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                height: 150.0,
                color: Colors.orange[200], // Placeholder color
                // TODO: Implement Notes Section
              ),
            ],
          ),
        ),
      ),
    );
  }
}