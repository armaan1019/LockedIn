import 'food.dart';

class Ingredient {
  final int? id;
  final Food food;
  double servings; // number of servings (e.g. 2 = 2 servings)

  Ingredient({this.id, required this.food, required this.servings});

  Map<String, Object?> toMap() {
    return {'id': id, 'foodId': food.id, 'servings': servings};
  }

  factory Ingredient.fromMap(Map<String, Object?> map, Food food) {
    return Ingredient(
      id: map['id'] as int?,
      food: food,
      servings: (map['servings'] as num).toDouble(),
    );
  }

  String get name => food.name;

  double get grams => food.defaultServingGrams * servings;

  int get calories => food.caloriesForServings(servings);
  int get protein => food.proteinForServings(servings).round();
  int get carbs => food.carbsForServings(servings).round();
  int get fat => food.fatForServings(servings).round();
}
