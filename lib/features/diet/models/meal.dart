import 'ingredient.dart';

class Meal {
  final int? entryId;
  final int? mealId;
  final String name;
  final List<Ingredient> ingredients;

  Meal({
    this.entryId,
    this.mealId,
    required this.name,
    required this.ingredients,
  });

  factory Meal.fromMap(Map<String, Object?> map, List<Ingredient> ingredients) {
    return Meal(
      entryId: map['entryId'] as int?,
      mealId: map['mealId'] as int?,
      name: map['name'] as String,
      ingredients: ingredients,
    );
  }

  int get calories => ingredients.fold(0, (sum, i) => sum + i.calories);

  int get protein => ingredients.fold(0, (sum, i) => sum + i.protein);

  int get carbs => ingredients.fold(0, (sum, i) => sum + i.carbs);

  int get fat => ingredients.fold(0, (sum, i) => sum + i.fat);
}
