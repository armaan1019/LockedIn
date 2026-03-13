import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_entry.dart';
import '../models/ingredient.dart';
import '../models/food.dart';
import '../models/meal.dart';
import '../models/saved_meal.dart';

class DietRepository {
  final FirebaseFirestore _firestore;

  DietRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _dietEntries =>
      _firestore.collection('diet_entries');

  CollectionReference<Map<String, dynamic>> get _savedMeals =>
      _firestore.collection('saved_meals');

  Future<List<MealEntry>> getMealsForDay(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final nextDay = dayStart.add(const Duration(days: 1));

    final snapshot = await _dietEntries
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('date', isLessThan: Timestamp.fromDate(nextDay))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => _mealEntryFromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<List<SavedMeal>> getSavedMeals() async {
    final snapshot = await _savedMeals
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => _savedMealFromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<void> addMealEntry(MealEntry mealEntry) async {
    final entryRef = _dietEntries.doc();

    final meal = mealEntry.meal;

    await entryRef.set({
      'meal': meal.toMap(),
      'date': Timestamp.fromDate(mealEntry.date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveMealTemplate(SavedMeal savedMeal) async {
    final ref = _savedMeals.doc();
    await ref.set({
      ...savedMeal.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMealEntry(String entryId) async {
    await _dietEntries.doc(entryId).delete();
  }

  Future<void> updateMealEntry(MealEntry mealEntry) async {
    await _dietEntries.doc(mealEntry.entryId).update({
      'meal': mealEntry.meal.toMap(),
    });
  }

  MealEntry _mealEntryFromDoc(String id, Map<String, dynamic> data) {
    final mealMap = (data['meal'] as Map<String, dynamic>?) ?? {};
    final ingredients = _ingredientsFromMealMap(mealMap);

    return MealEntry(
      entryId: id,
      meal: Meal.fromMap(mealMap, ingredients),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  SavedMeal _savedMealFromDoc(String id, Map<String, dynamic> data) {
    final ingredients = _ingredientsFromMealMap(data);
    return SavedMeal(mealId: id, meal: Meal.fromMap(data, ingredients));
  }

  List<Ingredient> _ingredientsFromMealMap(Map<String, dynamic> mealMap) {
    final rawIngredients =
        (mealMap['ingredients'] as List<dynamic>? ?? const []);

    return rawIngredients.asMap().entries.map((entry) {
      final ingredientMap = entry.value as Map<String, dynamic>;
      final foodMap = ingredientMap['food'] as Map<String, dynamic>;

      return Ingredient(
        id: (ingredientMap['id'] as String?) ?? entry.key.toString(),
        food: Food.fromMap(foodMap),
        servings: (ingredientMap['servings'] as num?)?.toDouble() ?? 1.0,
      );
    }).toList();
  }
}
