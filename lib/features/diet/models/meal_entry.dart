class MealEntry {
  final String entryId;
  final String mealId;
  final DateTime date;

  MealEntry({required this.entryId, required this.mealId, required this.date});

  Map<String, dynamic> toMap() {
    return {'mealId': mealId, 'date': date};
  }

  factory MealEntry.fromMap(String entryId, Map<String, dynamic> map) {
    return MealEntry(
      entryId: entryId,
      mealId: map['mealId'] as String,
      date: (map['date'] as dynamic).toDate(),
    );
  }
}
