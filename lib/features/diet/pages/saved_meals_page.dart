import 'package:flutter/material.dart';
import '../models/saved_meal.dart';
import '../widgets/create_meal_form.dart';

class SavedMealsPage extends StatefulWidget {
  final List<SavedMeal> savedMeals;
  final Future<void> Function(SavedMeal) onDelete;
  final Future<void> Function(SavedMeal) onEdit;

  const SavedMealsPage({
    super.key,
    required this.savedMeals,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<SavedMealsPage> createState() => _SavedMealsPageState();
}

class _SavedMealsPageState extends State<SavedMealsPage> {
  late final List<SavedMeal> _savedMeals;

  @override
  void initState() {
    super.initState();
    _savedMeals = List.from(widget.savedMeals);
  }

  void _showEditMealSheet(int index, SavedMeal savedMeal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateMealForm(
          initialMeal: savedMeal.meal,
          isEditing: true,
          onSave: (updatedMealEntry) async {
            final updatedSavedMeal = SavedMeal(
              mealId: savedMeal.mealId,
              meal: updatedMealEntry.meal,
            );

            await widget.onEdit(updatedSavedMeal);

            if (!mounted) return;

            setState(() {
              _savedMeals[index] = updatedSavedMeal;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${updatedSavedMeal.meal.name} updated')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Meals')),
      body: ListView.builder(
        itemCount: _savedMeals.length,
        itemBuilder: (context, index) {
          final saved = _savedMeals[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(saved.meal.name),
              subtitle: Text('${saved.meal.calories} cal'),
              onTap: () {
                Navigator.pop(context, saved);
              },
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      _showEditMealSheet(index, saved);
                      break;
                    case 'delete':
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Delete saved meal?'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Are you sure you want to delete "${saved.meal.name}"?',
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: const Text('Delete'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );

                      if (confirm == true) {
                        await widget.onDelete(saved);

                        if (!mounted) return;

                        setState(() {
                          _savedMeals.removeAt(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${saved.meal.name} deleted')),
                        );
                      }

                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
