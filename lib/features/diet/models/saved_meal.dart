import 'ingredient.dart';

class SavedMeal {
  final String mealId;
  final String name;
  final List<Ingredient> ingredients;

  SavedMeal({
    required this.mealId,
    required this.name,
    required this.ingredients,
  });

  factory SavedMeal.fromMap(
    String mealId,
    Map<String, dynamic> map,
    List<Ingredient> ingredients,
  ) {
    return SavedMeal(
      mealId: mealId,
      name: map['name'] as String,
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'ingredients': ingredients.map((i) => i.toMap()).toList()};
  }

  int get calories => ingredients.fold(0, (sum, i) => sum + i.calories);

  int get protein => ingredients.fold(0, (sum, i) => sum + i.protein);

  int get carbs => ingredients.fold(0, (sum, i) => sum + i.carbs);

  int get fat => ingredients.fold(0, (sum, i) => sum + i.fat);
}
