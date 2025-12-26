class Food {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  Food({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class Ingredient {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  Ingredient({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
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

