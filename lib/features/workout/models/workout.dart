import 'dart:convert';

class WorkoutSession {
  final String id;
  final String title;
  final List<ExerciseSession> exercises;
  final DateTime date;

  WorkoutSession({
    required this.id,
    required this.title,
    required this.exercises,
    required this.date,
  });
}

class ExerciseSession {
  final String name;
  final List<SetEntry> sets;

  ExerciseSession({required this.name, required this.sets});
}

class SetEntry {
  int reps;
  double? weight; // optional

  SetEntry({required this.reps, this.weight});
}

class Workout {
  final int? id;
  final String title;
  final List<Exercise> exercises;
  final int duration;
  final int calories;

  Workout({
    this.id,
    required this.title,
    required this.exercises,
    required this.duration,
    required this.calories,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'exercises': jsonEncode(exercises.map((e) => e.toMap()).toList()),
      'duration': duration,
      'calories': calories,
    };
  }

  factory Workout.fromMap(Map<String, Object?> map) {
    final exerciseList = jsonDecode(map['exercises'] as String) as List;

    return Workout(
      id: map['id'] as int,
      title: map['title'] as String,
      exercises: exerciseList.map((e) => Exercise.fromMap(e)).toList(),
      duration: map['duration'] as int,
      calories: map['calories'] as int,
    );
  }
}

class Exercise {
  final String name;
  final int sets;
  final int reps;

  Exercise({required this.name, required this.sets, required this.reps});

  Map<String, dynamic> toMap() {
    return {'name': name, 'sets': sets, 'reps': reps};
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
    );
  }
}
