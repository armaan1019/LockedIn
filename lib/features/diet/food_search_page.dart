import 'package:flutter/material.dart';
import 'services/food_api.dart';
import 'models/food.dart';

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
                  '${food.calories} kcal · '
                  'P ${food.protein}g · '
                  'C ${food.carbs}g · '
                  'F ${food.fat}g',
                ),
                onTap: () => Navigator.pop(context, food),
              );
            },
          );
        },
      ),
    );
  }
}