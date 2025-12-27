import 'package:flutter/material.dart';
import 'services/food_api.dart';
import 'models/food.dart';
import 'add_ingredient_page.dart';

class FoodSearchPage extends StatefulWidget {
  final String query;

  const FoodSearchPage({super.key, required this.query});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  late Future<List<Food>> _results;

  @override
  void initState() {
    super.initState();
    print('Searching for: "${widget.query}"');
    _results = FoodApi.searchFoods(widget.query).then((list) {
      print('Found ${list.length} items');
      for (var f in list) {
        print(f.name);
      }
      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results for "${widget.query}"')),
      body: FutureBuilder<List<Food>>(
        future: _results,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          final foods = snapshot.data!;

          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return ListTile(
                title: Text(food.name),
                subtitle: Text(
                  '${food.caloriesPer100g} kcal/100g · '
                  'P ${food.proteinPer100g}g · '
                  'C ${food.carbsPer100g}g · '
                  'F ${food.fatPer100g}g',
                ),
                onTap: () async {
                  // Go to the grams selector page
                  final ingredient = await Navigator.push<Ingredient>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddIngredientPage(food: food),
                    ),
                  );

                  if (ingredient != null) {
                    // Return the ingredient to CreateMealForm
                    Navigator.pop(context, ingredient);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}