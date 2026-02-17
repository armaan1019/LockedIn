import 'package:flutter/material.dart';
import 'services/food_api.dart';
import 'models/food.dart';
import 'barcode_scanner_page.dart';
import 'saved_meals_page.dart';
import 'widgets/meal_card.dart';
import 'widgets/macro_info.dart';
import 'widgets/create_meal_form.dart';
import '../../core/local_db.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final List<Meal> _meals = [];
  final List<Meal> _savedMeals = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _loadTodayMeals();
    await _loadSavedMeals();
  }

  int get totalProtein => _meals.fold(0, (sum, meal) => sum + meal.protein);

  int get totalCarbs => _meals.fold(0, (sum, meal) => sum + meal.carbs);

  int get totalFat => _meals.fold(0, (sum, meal) => sum + meal.fat);

  Ingredient _ingredientFromFood(Food food) {
    return Ingredient(food: food, servings: 1.0);
  }

  Future<void> _loadSavedMeals() async {
    final db = LocalDb.instance;

    final meals = await db.getMeals();

    List<Meal> loaded = [];

    for (final meal in meals) {
      final mealId = meal['id'] as int;

      final ingredientMaps = await db.getIngredientsForMeal(mealId);
      List<Ingredient> ingredients = [];

      for (final ing in ingredientMaps) {
        ingredients.add(
          Ingredient(
            food: Food(
              id: ing['food_id'] as int,
              name: ing['name'] as String,
              caloriesPer100g: ing['calories'] as int,
              proteinPer100g: ing['protein'] as int,
              carbsPer100g: ing['carbs'] as int,
              fatPer100g: ing['fat'] as int,
            ),
            servings: ing['servings'] as double,
          ),
        );
      }
      loaded.add(
        Meal(
          id: mealId,
          name: meal['name'] as String,
          ingredients: ingredients,
        ),
      );
    }

    setState(() {
      _savedMeals
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _loadTodayMeals() async {
    final db = LocalDb.instance;

    final today = DateTime.now();
    final dateKey = DateTime(
      today.year,
      today.month,
      today.day,
    ).millisecondsSinceEpoch;

    final entries = await db.getDietEntriesByDate(dateKey);

    List<Meal> loadedMeals = [];

    for (final entry in entries) {
      final mealId = entry['meal_id'] as int;

      final mealMap = await db.getMealById(mealId);
      if (mealMap == null) continue; // skip if meal was deleted

      final ingredientMaps = await db.getIngredientsForMeal(mealId);

      List<Ingredient> ingredients = [];

      for (final ing in ingredientMaps) {
        final foodMap = await db.getFoodById(ing['food_id'] as int);
        if (foodMap == null) continue; // skip missing food

        ingredients.add(
          Ingredient(
            food: Food.fromMap(foodMap),
            servings: ing['servings'] as double,
          ),
        );
      }

      loadedMeals.add(
        Meal(name: mealMap['name'] as String, ingredients: ingredients),
      );
    }

    setState(() {
      _meals.clear();
      _meals.addAll(loadedMeals);
    });
  }

  void _saveMealTemplate(Meal meal) async {
    final db = LocalDb.instance;

    final mealId = await db.insertMeal({'name': meal.name});

    for (final ing in meal.ingredients) {
      await db.insertIngredient({
        'meal_id': mealId,
        'food_id': ing.food.id,
        'servings': ing.servings,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${meal.name} saved for future use')),
    );
  }

  void _deleteMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  void _editMeal(int index, Meal updatedMeal) {
    setState(() {
      _meals[index] = updatedMeal;
    });
  }

  void _openEditSheet(int index, Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateMealForm(
          onSave: (updatedMeal) {
            _editMeal(index, updatedMeal);
          },
          initialMeal: meal,
        ),
      ),
    );
  }

  Future<void> _scanBarcodeAndAddMeal() async {
    // Navigate to barcode scanner and wait for result
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (barcode == null) return;

    // Fetch food from API
    final food = await FoodApi.fetchByBarcode(barcode);

    if (food == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Food not found')));
      return;
    }

    // Open AddMealForm with auto-filled food
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateMealForm(
          onSave: _addMeal,
          onSaveTemplate: _saveMealTemplate,
          initialIngredient: _ingredientFromFood(food),
        ),
      ),
    );
  }

  void _addMeal(Meal meal) async {
    final db = LocalDb.instance;

    final mealId = await db.insertMeal({'name': meal.name});

    for (final ing in meal.ingredients) {

      int foodId;

      // SAFE CHECK
      if (ing.food.id == null) {
        foodId = await db.insertFood(ing.food.toMap());
        ing.food.id = foodId;
      } else {
        foodId = ing.food.id!;
      }

      await db.insertIngredient({
        'meal_id': mealId,
        'food_id': foodId,
        'servings': ing.servings,
      });
    }

    final today = DateTime.now();
    final dateKey =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

    await db.insertDietEntry({'meal_id': mealId, 'date': dateKey});

    await _loadTodayMeals();
  }

  void _showCreateMealSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateMealForm(
          onSave: _addMeal,
          onSaveTemplate: _saveMealTemplate,
        ),
      ),
    );
  }

  void _showAddOptionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Create meal manually'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateMealSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan barcode'),
                onTap: () {
                  Navigator.pop(context);
                  _scanBarcodeAndAddMeal();
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Use saved meal'),
                onTap: () async {
                  Navigator.pop(context);

                  final meal = await Navigator.push<Meal>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavedMealsPage(savedMeals: _savedMeals),
                    ),
                  );

                  if (meal != null) {
                    setState(() {
                      _meals.add(meal);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  int get totalCalories =>
      _meals.fold(0, (previousValue, meal) => previousValue + meal.calories);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Diet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MacroInfo(
                        label: 'Calories',
                        value: totalCalories.toString(),
                      ),
                      MacroInfo(label: 'Protein', value: '${totalProtein}g'),
                      MacroInfo(label: 'Carbs', value: '${totalCarbs}g'),
                      MacroInfo(label: 'Fat', value: '${totalFat}g'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _meals.length,
                  itemBuilder: (context, index) {
                    final meal = _meals[index];
                    return MealCard(
                      meal: meal,
                      index: index,
                      onDelete: _deleteMeal,
                      onEdit: (i, m) => _openEditSheet(i, m),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptionsSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
