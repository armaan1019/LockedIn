import 'package:cloud_firestore/cloud_firestore.dart';
import '../../diet/repositories/diet_repository.dart';

class StatsRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  StatsRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('users').doc(userId).collection('workoutSessions');

  Future<int> getWorkoutsThisWeek() async {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final snapshot = await _sessions
        .where('date', isGreaterThanOrEqualTo: oneWeekAgo)
        .where('date', isLessThanOrEqualTo: now)
        .get();

    final workouts = snapshot.docs.length;

    return workouts;
  }

  Future<int> getCaloriesToday() async {
    final dietRepo = DietRepository(userId: userId);

    final meals = await dietRepo.getMealsForDay(DateTime.now());

    return meals.fold<int>(0, (sum, mealEntry) => sum + mealEntry.meal.calories,);
  }
}
