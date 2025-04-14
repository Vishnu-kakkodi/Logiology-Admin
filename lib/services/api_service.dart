import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logiology_admin/models/product_model.dart';

class ApiService {
  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse("https://dummyjson.com/products"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<Product> productList =
          (jsonData['products'] as List)
              .map((item) => Product.fromJson(item))
              .toList();
      return productList;
    } else {
      throw Exception('Failed to load products');
    }
  }
}
