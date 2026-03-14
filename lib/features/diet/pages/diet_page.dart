import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_api.dart';
import '../models/food.dart';
import 'barcode_scanner_page.dart';
import 'saved_meals_page.dart';
import '../widgets/meal_card.dart';
import '../widgets/macro_info.dart';
import '../widgets/create_meal_form.dart';
import '../models/saved_meal.dart';
import '../models/ingredient.dart';
import '../models/meal_entry.dart';
import '../repositories/diet_repository.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final List<MealEntry> _meals = [];
  final List<SavedMeal> _savedMeals = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await Future.wait([_loadTodayMeals(), _loadSavedMeals()]);
  }

  int get totalProtein =>
      _meals.fold(0, (sum, mealEntry) => sum + mealEntry.meal.protein);

  int get totalCarbs =>
      _meals.fold(0, (sum, mealEntry) => sum + mealEntry.meal.carbs);

  int get totalFat =>
      _meals.fold(0, (sum, mealEntry) => sum + mealEntry.meal.fat);

  int get totalCalories => _meals.fold(
    0,
    (previousValue, mealEntry) => previousValue + mealEntry.meal.calories,
  );

  Ingredient _ingredientFromFood(Food food) {
    return Ingredient(id: '', food: food, servings: 1.0);
  }

  Future<void> _logExistingMeal(SavedMeal template) async {
    final dietRepo = context.read<DietRepository?>();

    if (dietRepo == null) return;

    final mealEntry = MealEntry(
      entryId: '',
      meal: template.meal,
      date: DateTime.now(),
    );

    await dietRepo.addMealEntry(mealEntry);
    await _loadTodayMeals();
  }

  Future<void> _loadSavedMeals() async {
    final dietRepo = context.read<DietRepository?>();

    if (dietRepo == null) return;

    final loaded = await dietRepo.getSavedMeals();

    if (!mounted) return;
    setState(() {
      _savedMeals
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _loadTodayMeals() async {
    final dietRepo = context.read<DietRepository?>();

    if (dietRepo == null) return;

    final loadedMeals = await dietRepo.getMealsForDay(DateTime.now());

    if (!mounted) return;
    setState(() {
      _meals
        ..clear()
        ..addAll(loadedMeals);
    });
  }

  Future<void> _saveMealTemplate(SavedMeal savedMeal) async {
    final dietRepo = context.read<DietRepository?>();

    if (dietRepo == null) return;

    await dietRepo.saveMealTemplate(savedMeal);
    await _loadSavedMeals();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${savedMeal.meal.name} saved for future use')),
    );
  }

  Future<void> _deleteMeal(int index) async {
    final dietRepo = context.read<DietRepository?>();

    if (dietRepo == null) return;

    final mealEntry = _meals[index];
    await dietRepo.deleteMealEntry(mealEntry.entryId);

    await _loadTodayMeals();
  }

  Future<void> _editMeal(int index, MealEntry updatedMealEntry) async {
    final dietRepo = context.read<DietRepository?>();

    if (dietRepo == null) return;

    final oldMealEntry = _meals[index];

    final updated = MealEntry(
      entryId: oldMealEntry.entryId,
      meal: updatedMealEntry.meal,
      date: oldMealEntry.date,
    );

    await dietRepo.updateMealEntry(updated);

    await _loadTodayMeals();
  }

  void _openEditSheet(int index, MealEntry mealEntry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateMealForm(
          onSave: (updatedMealEntry) async {
            await _editMeal(index, updatedMealEntry);
          },
          initialMeal: mealEntry.meal,
          isEditing: true,
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Food not found')));
      return;
    }

    // Open AddMealForm with auto-filled food
    if (!mounted) return;
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

  Future<void> _addMeal(MealEntry mealEntry) async {
    final dietRepo = context.read<DietRepository?>();

    if (dietRepo == null) return;

    await dietRepo.addMealEntry(
      MealEntry(entryId: '', meal: mealEntry.meal, date: DateTime.now()),
    );

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

                  final selectedMeal = await Navigator.push<SavedMeal>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavedMealsPage(savedMeals: _savedMeals),
                    ),
                  );

                  if (selectedMeal != null) {
                    _logExistingMeal(selectedMeal);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
                    final mealEntry = _meals[index];
                    return MealCard(
                      mealEntry: mealEntry,
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
