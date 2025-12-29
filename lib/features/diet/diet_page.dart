import 'package:flutter/material.dart';
import 'services/food_api.dart';
import 'models/food.dart';
import 'barcode_scanner_page.dart';
import 'food_search_page.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final List<Meal> _meals = [];

  int get totalProtein =>
    _meals.fold(0, (sum, meal) => sum + meal.protein);

  int get totalCarbs =>
      _meals.fold(0, (sum, meal) => sum + meal.carbs);

  int get totalFat =>
      _meals.fold(0, (sum, meal) => sum + meal.fat);

  Ingredient _ingredientFromFood(Food food) {
    return Ingredient(
      food: food,
      servings: 1.0,
    );
  }

  Future<void> _scanBarcodeAndAddMeal() async {
    // Navigate to barcode scanner and wait for result
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerPage(),
      ),
    );

    if (barcode == null) return;

    // Fetch food from API
    final food = await FoodApi.fetchByBarcode(barcode);

    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food not found')),
      );
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
          initialIngredient: _ingredientFromFood(food),
        ),
      ),
    );
  }


  void _addMeal(Meal meal) {
    setState(() {
      _meals.add(meal);
    });
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
                      _MacroInfo(label: 'Calories', value: totalCalories.toString()),
                      _MacroInfo(label: 'Protein', value: '${totalProtein}g'),
                      _MacroInfo(label: 'Carbs', value: '${totalCarbs}g'),
                      _MacroInfo(label: 'Fat', value: '${totalFat}g'),
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
                    return MealCard(meal: meal);
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

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(meal.name),
        subtitle: Text(
          meal.ingredients.map((i) => i.name).join(', '),
        ),
        trailing: Text('${meal.calories} cal'),
      ),
    );
  }
}

class _MacroInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MacroInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class CreateMealForm extends StatefulWidget {
  final void Function(Meal) onSave;
  final Ingredient? initialIngredient;

  const CreateMealForm({
    super.key,
    required this.onSave,
    this.initialIngredient,
  });

  @override
  State<CreateMealForm> createState() => _CreateMealFormState();
}

class _CreateMealFormState extends State<CreateMealForm> {
  final _mealNameController = TextEditingController();
  final List<Ingredient> _ingredients = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialIngredient != null) {
      _ingredients.add(widget.initialIngredient!);
    }
  }

  void _saveMeal() {
    if (_mealNameController.text.isEmpty || _ingredients.isEmpty) return;

    widget.onSave(
      Meal(
        name: _mealNameController.text,
        ingredients: _ingredients,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Meal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          TextField(
            controller: _mealNameController,
            decoration: const InputDecoration(labelText: 'Meal Name'),
          ),

          const SizedBox(height: 12),

          const Text('Ingredients',
              style: TextStyle(fontWeight: FontWeight.bold)),

          ..._ingredients.map(
            (i) => ListTile(
              title: Text(i.name),
              subtitle: Text('${(i.grams / i.food.defaultServingGrams).toStringAsFixed(1)} servings'),
              trailing: Text('${i.calories} cal'),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredient'),
            onPressed: () async {
              // Open the manual ingredient entry screen
              final ingredient = await showModalBottomSheet<Ingredient>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AddIngredientForm(),
              );

              if (ingredient != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _ingredients.add(ingredient);
                  });
                });
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Look up ingredient'),
            onPressed: () async {
              final queryController = TextEditingController();

              // Ask the user for a search query
              final query = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Search food'),
                  content: TextField(
                    controller: queryController,
                    decoration: const InputDecoration(labelText: 'Food name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, queryController.text),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              );

              if (query == null || query.isEmpty) return;

              // Open FoodSearchPage and wait for an Ingredient
              final ingredient = await Navigator.push<Ingredient>(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodSearchPage(query: query.trim()),
                ),
              );

              if (ingredient != null) {
                setState(() {
                  _ingredients.add(ingredient);
                });
              }
            },
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _saveMeal,
            child: const Text('Save Meal'),
          ),
        ],
      ),
    );
  }
}

class AddIngredientForm extends StatefulWidget {
  const AddIngredientForm({super.key});

  @override
  State<AddIngredientForm> createState() => _AddIngredientFormState();
}

class _AddIngredientFormState extends State<AddIngredientForm> {
  final name = TextEditingController();
  final calories = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fat = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add Ingredient',
              style: TextStyle(fontSize: 18)),

          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: calories, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
          TextField(controller: protein, decoration: const InputDecoration(labelText: 'Protein'), keyboardType: TextInputType.number),
          TextField(controller: carbs, decoration: const InputDecoration(labelText: 'Carbs'), keyboardType: TextInputType.number),
          TextField(controller: fat, decoration: const InputDecoration(labelText: 'Fat'), keyboardType: TextInputType.number),

          ElevatedButton(
            onPressed: () {
              final food = Food(
                name: name.text,
                caloriesPer100g: int.parse(calories.text),
                proteinPer100g: int.parse(protein.text),
                carbsPer100g: int.parse(carbs.text),
                fatPer100g: int.parse(fat.text),
              );

              Navigator.pop(
                context,
                Ingredient(
                  food: food,
                  servings: 1.0, // default serving size
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
