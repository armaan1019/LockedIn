import 'package:cloud_firestore/cloud_firestore.dart';
import '../../workout/models/workout_session.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;
  final String userId;
  final Map<String, String> _titleCache = {};

  DashboardRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('users').doc(userId).collection('workoutSessions');

  CollectionReference<Map<String, dynamic>> get _workouts =>
      _firestore.collection('users').doc(userId).collection('workouts');

  Future<List<WorkoutSession>> getRecentWorkouts() async {
    final snapshot = await _sessions
        .orderBy('date', descending: true)
        .limit(3)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutSession.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<String> getWorkoutTitle(String workoutId) async {
    if (_titleCache.containsKey(workoutId)) {
      return _titleCache[workoutId]!;
    }

    final doc = await _workouts.doc(workoutId).get();

    final title = doc.data()?['title'] ?? 'Unknown';
    _titleCache[workoutId] = title;

    return title;
  }
}
