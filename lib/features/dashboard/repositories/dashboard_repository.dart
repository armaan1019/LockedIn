import 'package:cloud_firestore/cloud_firestore.dart';
import '../../workout/models/workout_session.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  DashboardRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('users').doc(userId).collection('workoutSessions');

  Future<List<WorkoutSession>> getRecentWorkouts() async {
    final snapshot = await _sessions
        .orderBy('date', descending: true)
        .limit(3)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutSession.fromMap(doc.id, doc.data()))
        .toList();
  }
}
