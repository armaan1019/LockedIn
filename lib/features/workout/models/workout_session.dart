import 'exercise_session.dart';

class WorkoutSession {
  final String id;
  final String workoutId;
  final List<ExerciseSession> exercises;
  final DateTime date;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.exercises,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'date': date,
    };
  }

  WorkoutSession copyWith({String? id}) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId,
      exercises: exercises,
      date: date,
    );
  }

  factory WorkoutSession.fromMap(String id, Map<String, dynamic> map) {
    final exerciseList = map['exercises'] as List<dynamic>? ?? [];

    return WorkoutSession(
      id: id,
      workoutId: map['workoutId'] as String,
      date: (map['date'] as dynamic).toDate(),
      exercises: exerciseList.map((e) => ExerciseSession.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }
}
