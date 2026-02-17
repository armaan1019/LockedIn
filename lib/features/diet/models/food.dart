class Food {
  final int? id;
  final String name;
  final int caloriesPer100g;
  final int proteinPer100g;
  final int carbsPer100g;
  final int fatPer100g;
  final double defaultServingGrams; // e.g., 28g for 1 slice of bacon

  Food({
    this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.defaultServingGrams = 100.0,
  });

  // Calculate nutrition for a given serving count
  int caloriesForServings(double servings) =>
      ((caloriesPer100g / 100) * defaultServingGrams * servings).round();

  double proteinForServings(double servings) =>
      ((proteinPer100g / 100) * defaultServingGrams * servings);

  double carbsForServings(double servings) =>
      ((carbsPer100g / 100) * defaultServingGrams * servings);

  double fatForServings(double servings) =>
      ((fatPer100g / 100) * defaultServingGrams * servings);
}

class Ingredient {
  final Food food;
  double servings; // number of servings (e.g. 2 = 2 servings)

  Ingredient({required this.food, required this.servings});

  String get name => food.name;

  double get grams => food.defaultServingGrams * servings;

  int get calories => food.caloriesForServings(servings);
  int get protein => food.proteinForServings(servings).round();
  int get carbs => food.carbsForServings(servings).round();
  int get fat => food.fatForServings(servings).round();
}

class Meal {
  final String name;
  final List<Ingredient> ingredients;

  Meal({required this.name, required this.ingredients});

  int get calories => ingredients.fold(0, (sum, i) => sum + i.calories);

  int get protein => ingredients.fold(0, (sum, i) => sum + i.protein);

  int get carbs => ingredients.fold(0, (sum, i) => sum + i.carbs);

  int get fat => ingredients.fold(0, (sum, i) => sum + i.fat);
}
