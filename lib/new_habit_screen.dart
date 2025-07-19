import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/notification_service.dart';

class NewHabitScreen extends StatefulWidget {
  @override
  _NewHabitScreenState createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _goalValueController = TextEditingController();

  IconData? _selectedIcon;
  TimeOfDay? _selectedTime;
  List<int> _selectedDays = []; // 1 for Monday, 7 for Sunday

  String? _selectedGoalType; // 'frequency' or 'quantity'
  String? _selectedGoalUnit; // e.g., 'times', 'pages', 'minutes'
  String? _selectedGoalFrequency; // e.g., 'daily', 'weekly'

  final List<IconData> _icons = [
    Icons.book,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.wb_sunny,
    Icons.group,
    Icons.local_florist,
    Icons.water_drop,
    Icons.edit_note,
    Icons.language,
    Icons.directions_run,
    Icons.star,
  ];

  final List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _habitNameController.dispose();
    _goalValueController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Habit'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'What habit do you want to build?',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _habitNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Exercise, Read, Meditate',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Choose an Icon',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 100, // Fixed height for icon grid
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Icon(icon,
                        size: 30.0,
                        color: _selectedIcon == icon ? Colors.blue : Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Reminder Time (Optional)',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(_selectedTime == null
                  ? 'Select Time'
                  : _selectedTime!.format(context)),
            ),
            SizedBox(height: 16.0),
            Text(
              'Repeat On (Optional)',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final day = index + 1; // Monday = 1, Sunday = 7
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(_dayNames[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                  selectedColor: Colors.blue,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }),
            ),
            SizedBox(height: 24.0),
            Text(
              'Set a Goal (Optional)',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Goal Type',
              ),
              value: _selectedGoalType,
              hint: Text('Select Goal Type'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGoalType = newValue;
                  _goalValueController.clear(); // Clear value when type changes
                  _selectedGoalUnit = null;
                  _selectedGoalFrequency = null;
                });
              },
              items: <String>['Frequency', 'Quantity']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value == 'Frequency' ? 'frequency' : 'quantity',
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            if (_selectedGoalType != null) ...[
              TextField(
                controller: _goalValueController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: 'e.g., 3, 20',
                  border: OutlineInputBorder(),
                  labelText: _selectedGoalType == 'frequency'
                      ? 'Times per week/day'
                      : 'Amount',
                ),
              ),
              SizedBox(height: 16.0),
              if (_selectedGoalType == 'frequency')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Frequency',
                  ),
                  value: _selectedGoalFrequency,
                  hint: Text('Select Frequency'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGoalFrequency = newValue;
                    });
                  },
                  items: <String>['Daily', 'Weekly']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value.toLowerCase(),
                      child: Text(value),
                    );
                  }).toList(),
                ) else if (_selectedGoalType == 'quantity')
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _selectedGoalUnit = value; // Directly use text as unit
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g., pages, minutes, km',
                    border: OutlineInputBorder(),
                    labelText: 'Unit',
                  ),
                ),
            ],
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                if (_habitNameController.text.isEmpty || _selectedIcon == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a habit name and choose an icon.')),
                  );
                  return;
                }

                int? goalValue = int.tryParse(_goalValueController.text);
                if (_selectedGoalType != null) {
                  if (goalValue == null || goalValue <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid goal value.')),
                    );
                    return;
                  }
                  if (_selectedGoalType == 'quantity' && (_selectedGoalUnit == null || _selectedGoalUnit!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a unit for your quantity goal.')),
                    );
                    return;
                  }
                   if (_selectedGoalType == 'frequency' && _selectedGoalFrequency == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a frequency for your frequency goal.')),
                    );
                    return;
                  }
                }

                final newHabit = Habit(
                  id: null, // Let the database handle the ID
                  name: _habitNameController.text,
                  currentStreak: 0,
                  longestStreak: 0,
                  imagePath: '', // You can set a default or allow selection later
                  iconCodePoint: _selectedIcon!.codePoint,
                  createdTime: DateTime.now().millisecondsSinceEpoch,
                  reminderTime: _selectedTime?.format(context), // Store as string
                  reminderDays: _selectedDays.isNotEmpty ? _selectedDays.join(',') : null, // Store as comma-separated string
                  goalType: _selectedGoalType,
                  goalValue: goalValue,
                  goalUnit: _selectedGoalType == 'quantity' ? _selectedGoalUnit : null,
                  goalFrequency: _selectedGoalType == 'frequency' ? _selectedGoalFrequency : null,
                );

                final habitId = await DatabaseHelper().insertHabit(newHabit);

                if (_selectedTime != null) {
                  await NotificationService().scheduleDailyNotification(
                    id: habitId, // Use the habit's ID for notification ID
                    title: 'Habit Reminder',
                    body: 'Time to ${_habitNameController.text}!',
                    time: _selectedTime!,
                    days: _selectedDays.isNotEmpty ? _selectedDays : null,
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}