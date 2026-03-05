import 'package:flutter/material.dart';
import '../models/food.dart';

class SavedMealsPage extends StatelessWidget {
  final List<Meal> savedMeals;

  const SavedMealsPage({super.key, required this.savedMeals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Meals')),
      body: ListView.builder(
        itemCount: savedMeals.length,
        itemBuilder: (context, index) {
          final meal = savedMeals[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(meal.name),
              subtitle: Text('${meal.calories} cal'),
              onTap: () {
                Navigator.pop(context, meal);
              },
            ),
          );
        },
      ),
    );
  }
}