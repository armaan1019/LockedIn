import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  WorkoutRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workouts =>
      _firestore.collection('users').doc(userId).collection('workouts');

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('users').doc(userId).collection('workoutSessions');

  Future<void> addWorkout(Workout workout) async {
    final workoutRef = _workouts.doc();

    final newWorkout = workout.copyWith(id: workoutRef.id);

    await workoutRef.set(newWorkout.toMap());
  }

  Future<List<Workout>> getWorkouts() async {
    final snapshot = await _workouts.get();

    return snapshot.docs
        .map((doc) => Workout.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> deleteWorkout(String id) async {
    final snapshot = await _sessions.where('workoutId', isEqualTo: id).get();

    await Future.wait(
      snapshot.docs.map((doc) => doc.reference.delete()),
    );

    await _workouts.doc(id).delete();
  }

  Future<void> updateWorkout(Workout workout) async {
    await _workouts.doc(workout.id).update(workout.toMap());
  }

  Future<Workout?> getWorkoutById(String id) async {
    final doc = await _workouts.doc(id).get();

    if (!doc.exists) return null;
    return Workout.fromMap(doc.id, doc.data()!);
  }
}
