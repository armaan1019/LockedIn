import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../features/workout/models/workout.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._();
  LocalDb._();

  Database? _db;

  // =========================
  // Public DB Getter
  // =========================
  Future<Database> get db async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'locked_in.db');

    _db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _db!;
  }

  // =========================
  // DB Lifecycle
  // =========================

  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createWorkoutSessionsTable(db);
    }
    if(oldVersion < 3) {
      await _createDietTable(db);
    }
  }

  // =========================
  // Table Creation
  // =========================

  static Future<void> _createTables(Database db) async {
    await _createWorkoutsTable(db);
    await _createWorkoutSessionsTable(db);
    await _createDietTable(db);
  }

  static Future<void> _createDietTable(Database db) async {
    await db.execute('''
      CREATE TABLE diet (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein INTEGER NOT NULL,
        carbs INTEGER NOT NULL,
        fat INTEGER NOT NULL,
        defaultServingGrams INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createWorkoutsTable(Database db) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        exercises TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createWorkoutSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        exercises TEXT NOT NULL,
        date INTEGER NOT NULL
      )
    ''');
  }

  // =========================
  // CRUD: Workouts
  // =========================

  Future<int> insertWorkout(Map<String, Object?> row) async {
    final database = await db;
    return database.insert('workouts', row);
  }

  Future<List<Map<String, Object?>>> getWorkouts() async {
    final database = await db;
    return database.query('workouts', orderBy: 'id DESC');
  }

  Future<int> deleteWorkout(int id) async {
    final database = await db;
    return database.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWorkout(Map<String, Object?> row) async {
    final database = await db;

    final id = row['id'] as int;

    return database.update('workouts', row, where: 'id = ?', whereArgs: [id]);
  }

  // Workout Sessions CRUD

  Future<int> insertWorkoutSession(Map<String, Object?> row) async {
    final database = await db;
    return database.insert('workout_sessions', row);
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByTitle(String title) async {
    final database = await db;
    final rows = await database.query(
      'workout_sessions',
      where: 'title = ?',
      whereArgs: [title],
      orderBy: 'date DESC',
    );

    return rows.map((r) => WorkoutSession.fromMap(r)).toList();
  }

  Future<int> deleteWorkoutSession(int id) async {
    final database = await db;
    return database.delete(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
