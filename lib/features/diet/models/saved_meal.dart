import 'ingredient.dart';
import 'meal.dart';

class SavedMeal {
  final String mealId;
  final Meal meal;

  SavedMeal({required this.mealId, required this.meal});

  factory SavedMeal.fromMap(
    String mealId,
    Map<String, dynamic> map,
    List<Ingredient> ingredients,
  ) {
    return SavedMeal(mealId: mealId, meal: Meal.fromMap(map, ingredients));
  }

  Map<String, dynamic> toMap() {
    return meal.toMap();
  }
}
