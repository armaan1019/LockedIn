import 'package:flutter/material.dart';
import '../pages/food_search_page.dart';
import 'add_ingredient_form.dart';
import '../models/saved_meal.dart';
import '../models/ingredient.dart';

class CreateMealForm extends StatefulWidget {
  final bool isEditing;
  final void Function(Meal) onSave;
  final void Function(Meal)? onSaveTemplate;
  final Ingredient? initialIngredient;
  final Meal? initialMeal;

  const CreateMealForm({
    this.isEditing = false,
    super.key,
    required this.onSave,
    this.onSaveTemplate,
    this.initialIngredient,
    this.initialMeal,
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

    if (widget.initialMeal != null) {
      _mealNameController.text = widget.initialMeal!.name;
      _ingredients.addAll(widget.initialMeal!.ingredients);
    } else if (widget.initialIngredient != null) {
      _ingredients.add(widget.initialIngredient!);
    }
  }

  void _saveMeal() {
    if (_mealNameController.text.isEmpty || _ingredients.isEmpty) return;

    widget.onSave(
      Meal(name: _mealNameController.text, ingredients: _ingredients),
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
          const Text(
            'Create Meal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          TextField(
            controller: _mealNameController,
            decoration: const InputDecoration(labelText: 'Meal Name'),
          ),

          const SizedBox(height: 12),

          const Text(
            'Ingredients',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          ..._ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;

            return ListTile(
              title: Text(ingredient.name),
              subtitle: Text(
                '${ingredient.servings.toStringAsFixed(1)} servings',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${ingredient.calories} cal'),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Remove ingredient?'),
                          content: Text('Remove ${ingredient.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        setState(() {
                          _ingredients.removeAt(index);
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          }),
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
                      onPressed: () =>
                          Navigator.pop(context, queryController.text),
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

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  child: Text(
                    widget.isEditing ? 'Save Changes' : 'Add to Today',
                  ),
                ),
              ),

              const SizedBox(width: 8),
              if (!widget.isEditing)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onSaveTemplate == null) return;
                      if (_mealNameController.text.isEmpty ||
                          _ingredients.isEmpty)
                        return;

                      final meal = Meal(
                        name: _mealNameController.text,
                        ingredients: _ingredients,
                      );

                      widget.onSaveTemplate!(meal);
                      Navigator.pop(context);
                    },
                    child: const Text('Save Template'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
