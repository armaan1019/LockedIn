import 'package:flutter/material.dart';
import '../models/saved_meal.dart';

class SavedMealsPage extends StatefulWidget {
  final List<SavedMeal> savedMeals;
  final Future<void> Function(SavedMeal) onDelete;

  const SavedMealsPage({
    super.key,
    required this.savedMeals,
    required this.onDelete,
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
                  if (value == 'delete') {
                    await widget.onDelete(saved);

                    if (!mounted) return;

                    setState(() {
                      _savedMeals.removeAt(index);
                    });
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
