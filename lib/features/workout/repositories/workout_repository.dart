import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore;

  WorkoutRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addWorkout(Workout workout) async {
    final workoutRef = _firestore.collection('workouts').doc();

    final newWorkout = workout.copyWith(id: workoutRef.id);

    await workoutRef.set(newWorkout.toMap());
  }

  Future<List<Workout>> getWorkouts() async {
    final snapshot = await _firestore.collection('workouts').get();

    return snapshot.docs
        .map((doc) => Workout.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> deleteWorkout(String id) async {
    await _firestore.collection('workouts').doc(id).delete();
  }

  Future<void> updateWorkout(Workout workout) async {
    await _firestore
        .collection('workouts')
        .doc(workout.id)
        .update(workout.toMap());
  }

  Future<Workout?> getWorkoutById(String id) async {
    final doc = await _firestore.collection('workouts').doc(id).get();

    if (!doc.exists) return null;
    return Workout.fromMap(doc.id, doc.data()!);
  }
}
