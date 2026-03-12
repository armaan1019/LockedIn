import 'ingredient.dart';

class Meal {
  final String name;
  final List<Ingredient> ingredients;

  Meal({required this.name, required this.ingredients});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map, List<Ingredient> ingredients) {
    return Meal(name: map['name'] as String, ingredients: ingredients);
  }

  int get calories => ingredients.fold(0, (sum, i) => sum + i.calories);

  int get protein => ingredients.fold(0, (sum, i) => sum + i.protein);

  int get carbs => ingredients.fold(0, (sum, i) => sum + i.carbs);

  int get fat => ingredients.fold(0, (sum, i) => sum + i.fat);
}
