class SetEntry {
  int reps;
  double? weight; // optional

  SetEntry({required this.reps, this.weight});

  Map<String, dynamic> toMap() {
    return {'reps': reps, 'weight': weight};
  }

  factory SetEntry.fromMap(Map<String, dynamic> map) {
    return SetEntry(
      reps: map['reps'] as int,
      weight: (map['weight'] as num?)?.toDouble(),
    );
  }
}
