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