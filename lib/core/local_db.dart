import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._();
  LocalDb._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'locked_in.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            exercises TEXT NOT NULL,
            duration INTEGER NOT NULL,
            calories INTEGER NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

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
}