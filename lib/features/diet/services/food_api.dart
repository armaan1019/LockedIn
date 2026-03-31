import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['USDA_API_KEY'];

class FoodApi {
  // --- Open Food Facts (Barcode) ---
  static Future<Food?> fetchByBarcode(String barcode) async {
    final url = 'https://world.openfoodfacts.org/api/v2/product/$barcode.json';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return null;

    final data = json.decode(res.body);
    if (data['status'] != 1) return null;

    final product = data['product'];
    final nutriments = product['nutriments'] ?? {};

    return Food(
      name: product['product_name'] ?? 'Unknown food',
      caloriesPer100g: (nutriments['energy-kcal_100g'] ?? 0).round(),
      proteinPer100g: (nutriments['proteins_100g'] ?? 0).round(),
      carbsPer100g: (nutriments['carbohydrates_100g'] ?? 0).round(),
      fatPer100g: (nutriments['fat_100g'] ?? 0).round(),
    );
  }

  // --- USDA FoodData Central Search by Name ---
  static Future<List<Food>> searchFoods(String query) async {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query.trim());
      final url =
          'https://api.nal.usda.gov/fdc/v1/foods/search?api_key=$apiKey&query=$encodedQuery&pageSize=25';

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        print('USDA HTTP error: ${res.statusCode}');
        return [];
      }

      final data = json.decode(res.body);
      final List foods = data['foods'] ?? [];

      return foods.map<Food>((f) {
        final nutrients = Map.fromIterable(
          f['foodNutrients'] ?? [],
          key: (n) => n['nutrientName'],
          value: (n) => n['value'],
        );

        // USDA gives values per 100g by default in "Foundation Foods"
        int calories = (nutrients['Energy'] ?? 0).round();
        int protein = (nutrients['Protein'] ?? 0).round();
        int carbs = (nutrients['Carbohydrate, by difference'] ?? 0).round();
        int fat = (nutrients['Total lipid (fat)'] ?? 0).round();

        return Food(
          name: f['description'] ?? 'Unknown food',
          caloriesPer100g: calories,
          proteinPer100g: protein,
          carbsPer100g: carbs,
          fatPer100g: fat,
        );
      }).toList();
    } catch (e, st) {
      print('Error searching USDA foods for "$query": $e');
      print(st);
      return [];
    }
  }

  // --- Fetch single Food by Name (first result) ---
  static Future<Food?> fetchByName(String query) async {
    final results = await searchFoods(query);
    if (results.isEmpty) return null;
    return results.first;
  }
}
