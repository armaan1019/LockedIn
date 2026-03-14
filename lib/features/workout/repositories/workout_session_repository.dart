import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_session.dart';

class WorkoutSessionRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  WorkoutSessionRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workoutSessions =>
      _firestore.collection('users').doc(userId).collection('workoutSessions');

  Future<List<WorkoutSession>> getPastWorkoutsByWorkoutId(
    String workoutId,
  ) async {
    final snapshot = await _workoutSessions
        .where('workoutId', isEqualTo: workoutId)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutSession.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addWorkoutSession(WorkoutSession session) async {
    final sessionRef = _workoutSessions.doc();
    final newSession = session.copyWith(id: sessionRef.id);
    await sessionRef.set(newSession.toMap());
  }
}
