import 'package:flutter/material.dart';
import '../models/saved_meal.dart';

class SavedMealsPage extends StatelessWidget {
  final List<SavedMeal> savedMeals;

  const SavedMealsPage({super.key, required this.savedMeals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Meals')),
      body: ListView.builder(
        itemCount: savedMeals.length,
        itemBuilder: (context, index) {
          final saved = savedMeals[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(saved.meal.name),
              subtitle: Text('${saved.meal.calories} cal'),
              onTap: () {
                Navigator.pop(context, saved);
              },
            ),
          );
        },
      ),
    );
  }
}