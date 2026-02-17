class Food {
  int? id;
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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': caloriesPer100g,
      'protein': proteinPer100g,
      'carbs': carbsPer100g,
      'fat': fatPer100g,
      'defaultServingGrams': defaultServingGrams
    };
  }

  factory Food.fromMap(Map<String, Object?> map) {
    return Food(
      id: map['id'] as int?,
      name: map['name'] as String,
      caloriesPer100g: map['calories'] as int,
      proteinPer100g: map['protein'] as int,
      carbsPer100g: map['carbs'] as int,
      fatPer100g: map['fat'] as int,
      defaultServingGrams: (map['defaultServingGrams'] as num).toDouble()
    );
  }

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
  final int? id;
  final Food food;
  double servings; // number of servings (e.g. 2 = 2 servings)

  Ingredient({
    this.id,
    required this.food, 
    required this.servings
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'foodId': food.id,
      'servings': servings,
    };
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

class Meal {
  final int? id;
  final String name;
  final List<Ingredient> ingredients;

  Meal({
    this.id,
    required this.name, 
    required this.ingredients
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      // Ingredients would be stored in a separate table with a mealId foreign key
    };
  }

  factory Meal.fromMap(Map<String, Object?> map, List<Ingredient> ingredients) {
    return Meal(
      id: map['id'] as int?,
      name: map['name'] as String,
      ingredients: ingredients,
    );
  }

  int get calories => ingredients.fold(0, (sum, i) => sum + i.calories);

  int get protein => ingredients.fold(0, (sum, i) => sum + i.protein);

  int get carbs => ingredients.fold(0, (sum, i) => sum + i.carbs);

  int get fat => ingredients.fold(0, (sum, i) => sum + i.fat);
}
