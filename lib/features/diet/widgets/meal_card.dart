import 'package:flutter/material.dart';
import '../models/meal_entry.dart';

class MealCard extends StatelessWidget {
  final MealEntry mealEntry;
  final int index;
  final void Function(int) onDelete;
  final void Function(int, MealEntry) onEdit;

  const MealCard({
    super.key,
    required this.mealEntry,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(mealEntry.meal.name),
        subtitle: Text(mealEntry.meal.ingredients.map((i) => i.name).join(', ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${mealEntry.meal.calories} cal'),

            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                onEdit(index, mealEntry);
              },
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete meal?'),
                    content: Text('Delete ${mealEntry.meal.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  onDelete(index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
