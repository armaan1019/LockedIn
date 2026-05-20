import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/ingredient.dart';

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
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Ingredient', style: TextStyle(fontSize: 18)),

            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: calories,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: protein,
              decoration: const InputDecoration(labelText: 'Protein'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: carbs,
              decoration: const InputDecoration(labelText: 'Carbs'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: fat,
              decoration: const InputDecoration(labelText: 'Fat'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                final food = Food(
                  name: name.text,
                  caloriesPer100g: int.tryParse(calories.text) ?? 0,
                  proteinPer100g: int.tryParse(protein.text) ?? 0,
                  carbsPer100g: int.tryParse(carbs.text) ?? 0,
                  fatPer100g: int.tryParse(fat.text) ?? 0,
                );

                Navigator.pop(
                  context,
                  Ingredient(
                    id: '',
                    food: food,
                    servings: 1.0, // default serving size
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
