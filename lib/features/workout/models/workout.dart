import 'exercise.dart';

class Workout {
  final String id;
  final String title;
  final List<Exercise> exercises;
  final int duration;
  final int calories;

  Workout({
    required this.id,
    required this.title,
    required this.exercises,
    required this.duration,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'duration': duration,
      'calories': calories,
    };
  }
  factory Workout.fromMap(String id, Map<String, dynamic> map) {
    return Workout(
      id: id,
      title: map['title'] as String,
      exercises: (map['exercises'] as List<dynamic>? ?? []).map((e) => Exercise.fromMap(e)).toList(),
      duration: map['duration'] as int,
      calories: map['calories'] as int,
    );
  }

  Workout copyWith({
    String? id,
    String? title,
    List<Exercise>? exercises,
    int? duration,
    int? calories,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
    );
  }
}
