import 'set_entry.dart';

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

  factory ExerciseSession.fromMap(Map<String, dynamic> map) {
    final setList = map['sets'] as List<dynamic>? ?? [];

    return ExerciseSession(
      name: map['name'] as String,
      sets: setList
          .map((s) => SetEntry.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
