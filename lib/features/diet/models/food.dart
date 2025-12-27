class Food {
  final String name;
  final int caloriesPer100g;
  final int proteinPer100g;
  final int carbsPer100g;
  final int fatPer100g;

  Food({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });

  // Scaling logic
  int caloriesFor(double grams) =>
      (caloriesPer100g * grams / 100).round();

  int proteinFor(double grams) =>
      (proteinPer100g * grams / 100).round();

  int carbsFor(double grams) =>
      (carbsPer100g * grams / 100).round();

  int fatFor(double grams) =>
      (fatPer100g * grams / 100).round();
}

class Ingredient {
  final Food food;
  double grams;

  Ingredient({
    required this.food,
    required this.grams,
  });

  String get name => food.name;

  int get calories => food.caloriesFor(grams);
  int get protein => food.proteinFor(grams);
  int get carbs => food.carbsFor(grams);
  int get fat => food.fatFor(grams);
}

class Meal {
  final String name;
  final List<Ingredient> ingredients;

  Meal({
    required this.name,
    required this.ingredients,
  });

  int get calories =>
      ingredients.fold(0, (sum, i) => sum + i.calories);

  int get protein =>
      ingredients.fold(0, (sum, i) => sum + i.protein);

  int get carbs =>
      ingredients.fold(0, (sum, i) => sum + i.carbs);

  int get fat =>
      ingredients.fold(0, (sum, i) => sum + i.fat);
}

