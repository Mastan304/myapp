import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/models/habit.dart'; // Adjust the import path if necessary

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'habitual.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        currentStreak INTEGER,
        longestStreak INTEGER,
        imagePath TEXT,
        iconCodePoint INTEGER
      )
      '''
    );
 await db.execute(
 '''
 CREATE TABLE completions(
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 habitId INTEGER,
 completionDate INTEGER,
 FOREIGN KEY (habitId) REFERENCES habits(id) ON DELETE CASCADE
 )
 '''
 );
  }

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
 return await db.insert('habits', habit.toMapWithoutId());
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');

    return List.generate(maps.length, (i) {
      return Habit(
        id: maps[i]['id'],
        name: maps[i]['name'],
        currentStreak: maps[i]['currentStreak'],
        longestStreak: maps[i]['longestStreak'],
        imagePath: maps[i]['imagePath'],
 iconCodePoint: maps[i]['iconCodePoint'],
      );
    });
  }
  
  Future<int?> getLastCompletionDateForHabit(int habitId) async { // Corrected method signature
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completions',
      columns: ['completionDate'],
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completionDate DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) return maps.first['completionDate'];
    return null;
  }

  Future<int> insertCompletion(Completion completion) async {
    final db = await database;
    return await db.insert('completions', completion.toMap());
  }

  Future<List<Completion>> getCompletionsForHabit(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completions',
      where: 'habitId = ?',
      whereArgs: [habitId], // Use habitId directly
    );

    return List.generate(maps.length, (i) {
      return Completion(
        id: maps[i]['id'],
        habitId: maps[i]['habitId'],
        completionDate: DateTime.fromMillisecondsSinceEpoch(maps[i]['completionDate']),
      ); // Convert timestamp to DateTime
    });
  }

  Future<bool> isHabitCompletedToday(int habitId) async {
    final db = await database;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final count = await db.rawQuery('SELECT COUNT(*) FROM completions WHERE habitId = ? AND completionDate >= ?', [habitId, startOfToday.millisecondsSinceEpoch]);
    return Sqflite.firstIntValue(count)! > 0; // Use null assertion operator
  }

  Future<int> deleteCompletionForHabitAndDate(int habitId, int dateTimestamp) async {
    final db = await database;
    return await db.delete(
      'completions',
      where: 'habitId = ? AND completionDate = ?',
      whereArgs: [habitId, dateTimestamp],
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(), // Assuming toMap includes the iconCodePoint now
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> deleteCompletionForHabitAndDate(int habitId, int dateTimestamp) async {
  final db = await database;
  return await db.delete(
    'completions',
    where: 'habitId = ? AND completionDate = ?',
    whereArgs: [habitId, dateTimestamp],
  );
}
}

// Add this method to your Habit class (in lib/models/habit.dart)
// This is needed to convert Habit objects to a Map for database operations.

extension HabitToMap on Habit {
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Make id nullable in the Habit class or handle null
      'name': name,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'imagePath': imagePath,
 'iconCodePoint': iconCodePoint,
    };
  }
 Map<String, dynamic> toMapWithoutId() {
 return {
 'name': name,
 'currentStreak': currentStreak,
 'longestStreak': longestStreak,
 'imagePath': imagePath,
 'iconCodePoint': iconCodePoint,
 };
  }
  Future<int> deleteCompletionForHabitAndDate(int habitId, int dateTimestamp) async {
  final db = await database;
  return await db.delete(
    'completions',
    where: 'habitId = ? AND completionDate = ?',
    whereArgs: [habitId, dateTimestamp],
  );
}

}
// You will also need to update your Habit class to include an optional 'id' field
// and potentially update the constructor.
/*
class Habit {
  final int? id; // Make id nullable
  final String name;
  final int currentStreak;
  final int longestStreak;
  final String imagePath;

  Habit({
    this.id, // Add id to constructor
    required this.name,
    required this.currentStreak,
    required this.longestStreak,
    required this.imagePath,
  });

  // ... rest of your Habit class
}
*/