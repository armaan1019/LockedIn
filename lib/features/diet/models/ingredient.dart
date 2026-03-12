import 'food.dart';

class Ingredient {
  final String id;
  final Food food;
  double servings; // number of servings (e.g. 2 = 2 servings)

  Ingredient({required this.id, required this.food, required this.servings});

  Map<String, dynamic> toMap() {
    return {'food': food.toMap(), 'servings': servings};
  }

  factory Ingredient.fromMap(String id, Map<String, dynamic> map, Food food) {
    return Ingredient(
      id: id,
      food: Food.fromMap(map['food'] as Map<String, dynamic>),
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
