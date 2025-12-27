import 'package:flutter/material.dart';
import 'models/food.dart';

class AddIngredientPage extends StatefulWidget {
  final Food food;

  const AddIngredientPage({super.key, required this.food});

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  double grams = 100;

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
            Text('Serving Size (grams)', style: Theme.of(context).textTheme.titleMedium),

            Slider(
              min: 1,
              max: 500,
              divisions: 499,
              value: grams,
              label: grams.round().toString(),
              onChanged: (v) => setState(() => grams = v),
            ),

            Text('${grams.round()} g'),

            const SizedBox(height: 16),

            Text('Calories: ${food.caloriesFor(grams)}'),
            Text('Protein: ${food.proteinFor(grams)} g'),
            Text('Carbs: ${food.carbsFor(grams)} g'),
            Text('Fat: ${food.fatFor(grams)} g'),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Ingredient(food: food, grams: grams),
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