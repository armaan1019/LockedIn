import 'meal.dart';
import 'ingredient.dart';

class MealEntry {
  final String entryId;
  final Meal meal;
  final DateTime date;

  MealEntry({required this.entryId, required this.meal, required this.date});

  Map<String, dynamic> toMap() {
    return {'meal': meal.toMap(), 'date': date};
  }

  factory MealEntry.fromMap(
    String entryId,
    Map<String, dynamic> map,
    List<Ingredient> ingredients,
  ) {
    return MealEntry(
      entryId: entryId,
      meal: Meal.fromMap(map['meal'] as Map<String, dynamic>, ingredients),
      date: (map['date'] as dynamic).toDate(),
    );
  }
}
