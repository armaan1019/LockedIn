import 'dart:convert';

class WorkoutSession {
  final int? id;
  final int workoutId;
  final List<ExerciseSession> exercises;
  final DateTime date;

  WorkoutSession({
    this.id,
    required this.workoutId,
    required this.exercises,
    required this.date,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercises': jsonEncode(exercises.map((e) => e.toMap()).toList()),
      'date': date.millisecondsSinceEpoch,
    };
  }

  WorkoutSession copyWith({int? id}) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId,
      exercises: exercises,
      date: date,
    );
  }

  factory WorkoutSession.fromMap(Map<String, Object?> map) {
    final exerciseList = jsonDecode(map['exercises'] as String) as List;

    return WorkoutSession(
      id: map['id'] as int,
      workoutId: map['workout_id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      exercises: exerciseList.map((e) {
        final setsList = e['sets'] as List;

        return ExerciseSession(
          name: e['name'],
          sets: setsList.map((s) {
            return SetEntry(reps: s['reps'], weight: s['weight']?.toDouble());
          }).toList(),
        );
      }).toList(),
    );
  }
}

class ExerciseSession {
  final String name;
  final List<SetEntry> sets;

  ExerciseSession({required this.name, required this.sets});

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'sets': sets.map((s) => {'reps': s.reps, 'weight': s.weight}).toList(),
    };
  }
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

  Workout copyWith({
    int? id,
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
