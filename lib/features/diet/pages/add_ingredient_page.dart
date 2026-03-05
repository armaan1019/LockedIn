import 'package:flutter/material.dart';
import '../models/food.dart';

class AddIngredientPage extends StatefulWidget {
  final Food food;

  const AddIngredientPage({super.key, required this.food});

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final _servingsController = TextEditingController(text: '1');

  double get servings {
    final v = double.tryParse(_servingsController.text);
    return (v != null && v > 0) ? v : 1;
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of servings',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _servingsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'e.g. 2',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            Text('Calories: ${food.caloriesForServings(servings)}'),
            Text('Protein: ${food.proteinForServings(servings).toStringAsFixed(1)} g'),
            Text('Carbs: ${food.carbsForServings(servings).toStringAsFixed(1)} g'),
            Text('Fat: ${food.fatForServings(servings).toStringAsFixed(1)} g'),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Ingredient(
                    food: food,
                    servings: servings,
                  ),
                );
              },
              child: const Text('Add Ingredient'),
            ),
          ],
        ),
      ),
    );
  }
}