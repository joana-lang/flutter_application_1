import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/products';
    }
    // IP especial del emulador Android para llegar al localhost:8080 de tu PC
    return 'http://10.0.2.2:8080/products';
  }

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar productos (${response.statusCode})');
    }
  }
}
