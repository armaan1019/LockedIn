class Food {
  final String name;
  final int caloriesPer100g;
  final int proteinPer100g;
  final int carbsPer100g;
  final int fatPer100g;
  final double defaultServingGrams; // e.g., 28g for 1 slice of bacon

  Food({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.defaultServingGrams = 100.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': caloriesPer100g,
      'protein': proteinPer100g,
      'carbs': carbsPer100g,
      'fat': fatPer100g,
      'defaultServingGrams': defaultServingGrams,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      name: map['name'] as String,
      caloriesPer100g: map['calories'] as int,
      proteinPer100g: map['protein'] as int,
      carbsPer100g: map['carbs'] as int,
      fatPer100g: map['fat'] as int,
      defaultServingGrams: (map['defaultServingGrams'] as num?)?.toDouble() ?? 100.0,
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
