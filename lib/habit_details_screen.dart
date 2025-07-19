import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // Assuming your Habit model is here
import 'package:myapp/models/completion.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/utils/date_utils.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitDetailsScreenState createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  List<Completion> _completions = [];
  Map<int, int> _weeklyCompletionCounts = {};
  int _currentStreak = 0;
  int _longestStreak = 0;
  double _overallCompletionRate = 0.0;
  double _weeklyCompletionRate = 0.0;

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
        final completedDates = completions
            .map((completion) => DateTime.fromMillisecondsSinceEpoch(completion.completionDate))
            .toList();
        _currentStreak = DateUtils.calculateCurrentStreak(completedDates);
        _longestStreak = DateUtils.calculateLongestStreak(completedDates);

        // Calculate completion rates
        final habitCreationDate = DateTime.fromMillisecondsSinceEpoch(widget.habit.createdTime);
        _overallCompletionRate = DateUtils.calculateOverallCompletionRate(completedDates, habitCreationDate);

        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        _weeklyCompletionRate = DateUtils.calculateCompletionRate(completedDates, startOfWeek, now);

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

   List<BarChartGroupData> _generateCompletionChartData() {
    // Group completions by day
    final Map<int, int> dailyCompletions = {};
    for (var completion in _completions) {
      final date = DateTime.fromMillisecondsSinceEpoch(completion.completionDate);
      final dayTimestamp = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      dailyCompletions[dayTimestamp] = (dailyCompletions[dayTimestamp] ?? 0) + 1;
    }

    // Sort days and create BarChartGroupData
    final sortedDays = dailyCompletions.keys.toList()..sort();
    return sortedDays.asMap().entries.map((entry) {
      final index = entry.key;
      final dayTimestamp = entry.value;
      final date = DateTime.fromMillisecondsSinceEpoch(dayTimestamp);
      final completionCount = dailyCompletions[dayTimestamp] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: completionCount.toDouble(),
            color: Colors.blue,
          ),
        ],
      );
    }).toList();
  }

   FlTitlesData get _buildChartTitles {
    final sortedDays = _completions
        .map((completion) => DateTime.fromMillisecondsSinceEpoch(completion.completionDate))
        .toList()
      ..sort((a, b) => a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch));

    if (sortedDays.isEmpty) {
      return const FlTitlesData(show: false);
    }

    // Show a maximum of 7 labels on the x-axis
    final interval = (sortedDays.length / 7).ceil();

    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= sortedDays.length || index % interval != 0) {
              return const Text('');
            }
            final date = sortedDays[index];
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 4.0,
              child: Text(DateFormat('MMM dd').format(date), style: const TextStyle(fontSize: 10)),
            );
          },
           reservedSize: 20,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
           getTitlesWidget: (value, meta) {
            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
          },
           reservedSize: 28,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

   Widget _buildHeatmapCalendar() {
    if (_completions.isEmpty) {
      return const Center(child: Text('No completion data yet.'));
    }

    final completedDates = _completions
        .map((completion) => DateTime.fromMillisecondsSinceEpoch(completion.completionDate))
        .toList();

    // Determine the date range for the heatmap
    final now = DateTime.now();
    final startDate = completedDates.isNotEmpty
        ? completedDates.reduce((a, b) => a.isBefore(b) ? a : b)
        : now;
    final endDate = now;

    // Generate all dates within the range
    final allDates = List<DateTime>.generate(
      endDate.difference(startDate).inDays + 1,
      (i) => DateTime(startDate.year, startDate.month, startDate.day).add(Duration(days: i)),
    );

    // Create a map of completion counts per day
    final Map<int, int> dailyCompletionCounts = {};
    for (var completion in _completions) {
      final date = DateTime.fromMillisecondsSinceEpoch(completion.completionDate);
      final dayTimestamp = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      dailyCompletionCounts[dayTimestamp] = (dailyCompletionCounts[dayTimestamp] ?? 0) + 1;
    }

    // Find the maximum completion count for color scaling
    int maxCompletionCount = dailyCompletionCounts.values.isEmpty
        ? 1 // Default to 1 if no completions to avoid division by zero
        : dailyCompletionCounts.values.reduce(max);

    // Ensure maxCompletionCount is at least 1 to prevent issues with single completions
    if (maxCompletionCount == 0) maxCompletionCount = 1;


    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days a week
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: allDates.length,
      itemBuilder: (context, index) {
        final date = allDates[index];
        final dayTimestamp = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
        final completionCount = dailyCompletionCounts[dayTimestamp] ?? 0;

        // Determine the color based on completion count
        Color cellColor = Colors.grey.shade200; // Default color for no completions
        if (completionCount > 0) {
          // Calculate a normalized value for color interpolation
          // Ensure at least a base intensity for 1 completion
          final double normalizedCompletion = completionCount / maxCompletionCount;
          cellColor = Color.lerp(Colors.green.shade100, Colors.green.shade800, normalizedCompletion)!;
        }

        return Container(
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 10.0,
                color: completionCount > 0 ? Colors.white : Colors.grey, // Text color for visibility
              ),
            ),
          ),
        );
      },
    );
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

              // Completion History Chart
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add some padding
                //color: Colors.grey[300], // Placeholder color
                 child: BarChart(
                 BarChartData(
                  barGroups: _generateCompletionChartData(),
                   titlesData: _buildChartTitles, // Use the customized titles data
                   borderData: FlBorderData(show: false),
                   gridData: FlGridData(show: false),
                   alignment: BarChartAlignment.spaceAround,
                    maxY: _completions.isNotEmpty
                      ? _completions
                          .map((c) => c.completionDate)
                          .toList()
                          .length
                          .toDouble()
                      : 1.0, // Set maxY based on the number of completions

                   ),), // TODO: Implement Completion History Chart
              ),
              SizedBox(height: 24.0),
               Text(
                'Completion Heatmap',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                height: 250.0, // Adjust height as needed
                child: _buildHeatmapCalendar(),
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
                      child: Center(child: Text('Total Completions
${_completions.length}')), // Placeholder
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey[100], // Placeholder color
                      child: Center(child: Text('Current Streak
${_currentStreak}')), // Placeholder
                    ),
                  ),
                   SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey[100], // Placeholder color
                      child: Center(child: Text('Longest Streak
${_longestStreak}')), // Placeholder
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
               Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey[100], // Placeholder color
                      child: Center(child: Text('Overall Completion Rate
${_overallCompletionRate.toStringAsFixed(1)}%')), // Placeholder
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey[100], // Placeholder color
                      child: Center(child: Text('Weekly Completion Rate
${_weeklyCompletionRate.toStringAsFixed(1)}%')), // Placeholder
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