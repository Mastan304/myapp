import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/completion.dart';

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
      version: 4, // Increment the version for schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add onUpgrade callback
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
        iconCodePoint INTEGER,
        createdTime INTEGER,
        reminderTime TEXT,
        reminderDays TEXT,
        goalType TEXT,
        goalValue INTEGER,
        goalUnit TEXT,
        goalFrequency TEXT
      )
      '''
    );
    await db.execute(
      '''
      CREATE TABLE completions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER,
        completionDate INTEGER,
        notes TEXT
        FOREIGN KEY (habitId) REFERENCES habits(id) ON DELETE CASCADE
      )
      '''
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns if upgrading from version 1 to 2 (reminder fields)
      await db.execute('ALTER TABLE habits ADD COLUMN createdTime INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE habits ADD COLUMN reminderTime TEXT');
      await db.execute('ALTER TABLE habits ADD COLUMN reminderDays TEXT');
    }
    if (oldVersion < 3) {
      // Add new columns if upgrading from version 2 to 3 (goal fields)
      await db.execute('ALTER TABLE habits ADD COLUMN goalType TEXT');
      await db.execute('ALTER TABLE habits ADD COLUMN goalValue INTEGER');
      await db.execute('ALTER TABLE habits ADD COLUMN goalUnit TEXT');
      await db.execute('ALTER TABLE habits ADD COLUMN goalFrequency TEXT');
    }
    if (oldVersion < 4) {
      // Add new column if upgrading from version 3 to 4 (notes field)
      await db.execute('ALTER TABLE completions ADD COLUMN notes TEXT');
    }
  }

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');

    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  Future<int?> getLastCompletionDateForHabit(int habitId) async {
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
      whereArgs: [habitId],
    );

    return List.generate(maps.length, (i) {
      return Completion.fromMap(maps[i]);
    });
  }

  Future<bool> isHabitCompletedToday(int habitId) async {
    final db = await database;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final count = await db.rawQuery('SELECT COUNT(*) FROM completions WHERE habitId = ? AND completionDate >= ?', [habitId, startOfToday.millisecondsSinceEpoch]);
    return Sqflite.firstIntValue(count)! > 0;
  }

  Future<int> deleteCompletionForHabitAndDate(int habitId, int dateTimestamp) async {
    final db = await database;
    return await db.delete(
      'completions',
      where: 'habitId = ? AND completionDate = ?',
      whereArgs: [habitId, dateTimestamp],
    );
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
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
}
