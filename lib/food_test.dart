import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = 'tortilla';
  final encoded = Uri.encodeQueryComponent(query);

  final url =
      'https://world.openfoodfacts.org/cgi/search.pl'
      '?search_terms=$encoded'
      '&search_simple=1'
      '&action=process'
      '&json=1'
      '&page_size=5'
      '&fields=product_name,nutriments,code';

  print('Fetching: $url');

  final res = await http.get(Uri.parse(url));

  if (res.statusCode != 200) {
    print('HTTP error: ${res.statusCode}');
    return;
  }

  final data = json.decode(res.body);
  final List products = data['products'] ?? [];

  print('Found ${products.length} products');

  for (var p in products) {
    final nutriments = p['nutriments'] ?? {};
    print('---');
    print('Name: ${p['product_name']}');
    print('Calories: ${nutriments['energy-kcal_100g'] ?? 'N/A'}');
    print('Protein: ${nutriments['proteins_100g'] ?? 'N/A'}');
    print('Carbs: ${nutriments['carbohydrates_100g'] ?? 'N/A'}');
    print('Fat: ${nutriments['fat_100g'] ?? 'N/A'}');
    print('Code: ${p['code']}');
  }
}