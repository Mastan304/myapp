import 'package:flutter/material.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/habit.dart';

class NewHabitScreen extends StatefulWidget {
  @override
  _NewHabitScreenState createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  final TextEditingController _habitNameController = TextEditingController();
  IconData? _selectedIcon = null;

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

  @override
  void dispose() {
    _habitNameController.dispose();
    super.dispose();
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
      body: Padding(
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
            Expanded(
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
            Expanded(
              child: Container(),
            ),
            ElevatedButton(
              onPressed: () async {
                final newHabit = Habit(
                  id: null, // Let the database handle the ID
                  name: _habitNameController.text,
                  currentStreak: 0,
                  longestStreak: 0,
                  imagePath: 'assets/images/default_habit.png', // Use a default image path
                  iconCodePoint: _selectedIcon?.codePoint ?? 0, // Store icon code point, default to 0 if none selected
                );

                await DatabaseHelper().insertHabit(newHabit);
                Navigator.of(context).pop();
              },
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}