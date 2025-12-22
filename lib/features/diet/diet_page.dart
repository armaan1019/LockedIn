import 'package:flutter/material.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final List<Meal> _meals = [
    Meal(name: 'Breakfast', items: 'Oatmeal, Banana, Coffee', calories: 350),
    Meal(name: 'Lunch', items: 'Grilled Chicken Salad', calories: 600),
    Meal(name: 'Dinner', items: 'Salmon, Rice, Veggies', calories: 700),
  ];

  void _addMeal(Meal meal) {
    setState(() {
      _meals.add(meal);
    });
    Navigator.pop(context);
  }

  void _showAddMealSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddMealForm(onSave: _addMeal),
      ),
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
                      _MacroInfo(label: 'Protein', value: '75g'),
                      _MacroInfo(label: 'Carbs', value: '200g'),
                      _MacroInfo(label: 'Fat', value: '60g'),
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
        onPressed: _showAddMealSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Meal {
  final String name;
  final String items;
  final int calories;

  Meal({required this.name, required this.items, required this.calories});
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
        subtitle: Text(meal.items),
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

class AddMealForm extends StatefulWidget {
  final void Function(Meal) onSave;

  const AddMealForm({super.key, required this.onSave});

  @override
  State<AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<AddMealForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _itemsController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _itemsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final meal = Meal(
        name: _nameController.text,
        items: _itemsController.text,
        calories: int.parse(_caloriesController.text),
      );
      widget.onSave(meal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            const Text(
              'Add New Meal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Meal Name'),
              validator: (v) => v == null || v.isEmpty ? 'Enter meal name' : null,
            ),
            TextFormField(
              controller: _itemsController,
              decoration: const InputDecoration(labelText: 'Items'),
              validator: (v) => v == null || v.isEmpty ? 'Enter items' : null,
            ),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || int.tryParse(v) == null ? 'Enter a number' : null,
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Meal'),
            ),
          ],
        ),
      ),
    );
  }
}
