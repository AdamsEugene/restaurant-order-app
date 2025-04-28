import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/category.dart';
import '../../config/app_config.dart';

class CategoryApiService {
  final http.Client _httpClient;
  final String _baseUrl = AppConfig.apiBaseUrl;

  CategoryApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/categories'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch categories');
      }

      final categoriesJson = jsonDecode(response.body) as List;
      return categoriesJson
          .map((category) => Category.fromJson(category))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }
} 