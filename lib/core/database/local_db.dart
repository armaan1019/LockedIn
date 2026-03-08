import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/workout/models/workout.dart';
import '../services/auth_service.dart';
import '../../features/workout/models/workout_session.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._();
  LocalDb._();

  Database? _db;

  static String get userId {
    final id = AuthService.instance.currentUserId;
    if (id == null) {
      throw Exception("No user logged in");
    }
    return id;
  }

  // =========================
  // Public DB Getter
  // =========================
  Future<Database> get db async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'locked_in.db');

    _db = await openDatabase(
      path,
      version: 13,
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
    if (oldVersion < 3) {
      await _createDietEntriesTable(db);
      await _createFoodTable(db);
      await _createMealsTable(db);
      await _createIngredientsTable(db);
    }
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS diet_entries');
      await _createDietEntriesTable(db);
    }
    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE meals ADD COLUMN is_template INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 6) {
      await _createUsersTable(db);
      await db.execute(
        'ALTER TABLE workouts ADD COLUMN user_id TEXT NOT NULL DEFAULT "default_user"',
      );
      await db.execute(
        'ALTER TABLE workout_sessions ADD COLUMN user_id TEXT NOT NULL DEFAULT "default_user"',
      );
      await db.execute(
        'ALTER TABLE meals ADD COLUMN user_id TEXT NOT NULL DEFAULT "default_user"',
      );
      await db.execute(
        'ALTER TABLE diet_entries ADD COLUMN user_id TEXT NOT NULL DEFAULT "default_user"',
      );
    }
    if (oldVersion < 7) {
      await _createUsersTable(db);
    }
    if (oldVersion < 8) {
      await db.execute('DROP TABLE IF EXISTS workout_sessions');
      await _createWorkoutSessionsTable(db);
    }
    if (oldVersion < 9) {
      await _createPostsTable(db);
    }
    if (oldVersion < 10) {
      await _createCommentsTable(db);
    }
    if (oldVersion < 11) {
      await db.execute('DROP TABLE IF EXISTS comments');
      await _createCommentsTable(db);
    }
    if (oldVersion < 12) {
      await db.execute('DROP TABLE IF EXISTS comments');
      await _createCommentsTable(db);
    }
    if (oldVersion < 13) {
      await _createLikesTable(db);
    }
  }

  // =========================
  // Table Creation
  // =========================

  static Future<void> _createTables(Database db) async {
    await _createWorkoutsTable(db);
    await _createWorkoutSessionsTable(db);
    await _createDietEntriesTable(db);
    await _createFoodTable(db);
    await _createMealsTable(db);
    await _createIngredientsTable(db);
    await _createUsersTable(db);
    await _createPostsTable(db);
    await _createCommentsTable(db);
    await _createLikesTable(db);
  }

  static Future<void> _createLikesTable(Database db) async {
    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,
        post_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        FOREIGN KEY (post_id) references posts(id),
        FOREIGN KEY (user_id) references users(id),
        UNIQUE(post_id, user_id)
      )
    ''');
  }

  static Future<void> _createCommentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      remote_id TEXT UNIQUE,
      user_id TEXT NOT NULL,
      username TEXT NOT NULL,
      post_id INTEGER NOT NULL,
      remote_post_id TEXT,
      content TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) references users(id),
      FOREIGN KEY (post_id) references posts(id)
      )
    ''');
  }

  static Future<void> _createPostsTable(Database db) async {
    await db.execute('''
      CREATE TABLE posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      remote_id TEXT UNIQUE,
      user_id TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at INT NOT NULL,
      FOREIGN KEY (user_id) references users(id)
      )''');
  }

  static Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        profileImageUrl TEXT,
        bio TEXT DEFAULT ''
        )''');

    await db.execute(
      'CREATE INDEX idx_posts_user_ created ON posts(user_id, created_at DESC)',
    );
  }

  static Future<void> _createDietEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE diet_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        meal_id INTEGER NOT NULL,
        date INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (meal_id) REFERENCES meals (id)
      )
    ''');
  }

  static Future<void> _createFoodTable(Database db) async {
    await db.execute('''
      CREATE TABLE food (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER,
        protein INTEGER,
        carbs INTEGER,
        fat INTEGER,
        defaultServingGrams REAL
      )
    ''');
  }

  static Future<void> _createMealsTable(Database db) async {
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        is_template INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  static Future<void> _createIngredientsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_id INTEGER NOT NULL,
        food_id INTEGER NOT NULL,
        servings REAL NOT NULL,
        FOREIGN KEY (meal_id) REFERENCES meals (id),
        FOREIGN KEY (food_id) REFERENCES food (id)
      )
    ''');
  }

  static Future<void> _createWorkoutsTable(Database db) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        exercises TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  static Future<void> _createWorkoutSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        workout_id INTEGER NOT NULL,
        exercises TEXT NOT NULL,
        date INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (workout_id) REFERENCES workouts(id)
      )
    ''');
  }

  // CRUD: Workouts

  Future<int> insertWorkout(Map<String, Object?> row) async {
    final database = await db;
    row['user_id'] = userId;
    return database.insert('workouts', row);
  }

  Future<List<Map<String, Object?>>> getWorkouts() async {
    final database = await db;
    return database.query(
      'workouts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<Workout?> getWorkoutById(int id) async {
    final database = await db;
    final result = await database.query(
      'workouts',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Workout.fromMap(result.first);
  }

  Future<int> deleteWorkout(int id) async {
    final database = await db;
    return database.delete(
      'workouts',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> updateWorkout(Map<String, Object?> row) async {
    final database = await db;

    final id = row['id'] as int;

    return database.update(
      'workouts',
      row,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Workout Sessions CRUD

  Future<int> insertWorkoutSession(Map<String, Object?> row) async {
    final database = await db;
    final workoutId = row['workout_id'];
    if (workoutId == null) {
      throw Exception("workout_id is required");
    }
    row['user_id'] = userId;
    return database.insert('workout_sessions', row);
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByWorkoutId(
    int workoutId,
  ) async {
    final database = await db;
    final rows = await database.query(
      'workout_sessions',
      where: 'workout_id = ? AND user_id = ?',
      whereArgs: [workoutId, userId],
      orderBy: 'date DESC',
    );

    return rows.map((r) => WorkoutSession.fromMap(r)).toList();
  }

  Future<int> deleteWorkoutSession(int id) async {
    final database = await db;
    return database.delete(
      'workout_sessions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  //CRUD for Diet Entries, Food, Meals, Ingredients

  Future<int> insertFood(Map<String, Object?> row) async {
    final database = await db;
    return database.insert('food', row);
  }

  Future<List<Map<String, Object?>>> getFoods() async {
    final database = await db;
    return database.query('food', orderBy: 'id DESC');
  }

  Future<Map<String, Object?>?> getFoodById(int id) async {
    final database = await db;
    final rows = await database.query(
      'food',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> updateFood(Map<String, Object?> row) async {
    final database = await db;

    final id = row['id'] as int;

    return database.update('food', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFood(int id) async {
    final database = await db;
    return database.delete('food', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertMeal(
    Map<String, Object?> row, {
    bool isTemplate = false,
  }) async {
    final database = await db;
    row['is_template'] = isTemplate ? 1 : 0;
    row['user_id'] = userId;
    return database.insert('meals', row);
  }

  Future<List<Map<String, Object?>>> getMeals() async {
    final database = await db;
    return database.query(
      'meals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<Map<String, Object?>?> getMealById(int id) async {
    final database = await db;
    final rows = await database.query(
      'meals',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> deleteMeal(int id) async {
    final database = await db;
    return database.delete(
      'meals',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<void> updateMeal(int id, Map<String, Object?> row) async {
    final database = await db;

    await database.update(
      'meals',
      row,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> insertIngredient(Map<String, Object?> row) async {
    final database = await db;
    return database.insert('ingredients', row);
  }

  Future<void> deleteIngredientsForMeal(int mealId) async {
    final database = await db;
    await database.delete(
      'ingredients',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );
  }

  Future<List<Map<String, Object?>>> getIngredientsForMeal(int mealId) async {
    final database = await db;

    return database.rawQuery(
      '''
      SELECT ingredients.*, food.name, food.calories, food.protein, food.carbs, food.fat
      FROM ingredients
      JOIN food ON ingredients.food_id = food.id
      WHERE ingredients.meal_id = ?
    ''',
      [mealId],
    );
  }

  Future<int> deleteIngredient(int id) async {
    final database = await db;
    return database.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertDietEntry(Map<String, Object?> row) async {
    final database = await db;
    row['user_id'] = userId;
    return database.insert('diet_entries', row);
  }

  Future<List<Map<String, Object?>>> getDietEntriesByDate(int date) async {
    final database = await db;
    return database.query(
      'diet_entries',
      where: 'date = ? AND user_id = ?',
      whereArgs: [date, userId],
      orderBy: 'id DESC',
    );
  }

  Future<int> deleteDietEntry(int id) async {
    final database = await db;
    return database.delete(
      'diet_entries',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<void> updateDietEntryMeal(int entryId, int newMealId) async {
    final database = await db;

    await database.update(
      'diet_entries',
      {'meal_id': newMealId},
      where: 'id = ? AND user_id = ?',
      whereArgs: [entryId, userId],
    );
  }

  //CRUD for posts table

  Future<List<Map<String, Object?>>> getAllPosts(int? before) async {
    final database = await db;
    return database.rawQuery('''
    SELECT posts.*, users.username FROM posts
    JOIN users ON users.id = posts.user_id
    ${before != null ? 'WHERE posts.created_at < ?' : ''}
    ORDER BY posts.created_at DESC
    LIMIT 50
    ''', before != null ? [before] : []);
  }

  Future<int> insertPost(Map<String, Object?> row) async {
    final database = await db;
    row['user_id'] = userId;
    return database.insert('posts', row);
  }

  Future<int> deletePost(int id) async {
    final database = await db;
    return database.delete(
      'posts',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> updatePost(Map<String, Object?> row) async {
    final database = await db;

    final id = row['id'] as int;

    final updateRow = Map<String, Object?>.from(row)
      ..remove('id')
      ..remove('user_id');

    return database.update(
      'posts',
      updateRow,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Comments CRUD

  Future<int> insertComment(Map<String, Object?> row) async {
    final database = await db;
    row['user_id'] = userId;
    return database.insert('comments', row);
  }

  /*Future<List<Comment>> getCommentsByPostId(int postId) async {
    final database = await db;
    final rows = await database.query(
      'comments',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at DESC',
      limit: 50,
    );

    return rows.map((r) => Comment.fromMap(r)).toList();
  }*/

  //Get users

  Future<String> getCurrentUsername() async {
    final database = await db;

    final result = await database.query(
      'users',
      columns: ['username'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception("User not found");
    }

    return result.first['username'] as String;
  }

  //Likes Crud

  Future<bool> isPostLiked(int postId) async {
    final database = await db;

    final result = await database.query(
      'likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<int> insertLike(int postId) async {
    final database = await db;

    return database.insert('likes', {'post_id': postId, 'user_id': userId});
  }

  Future<int> deleteLike(int postId) async {
    final database = await db;

    return database.delete(
      'likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );
  }
}
