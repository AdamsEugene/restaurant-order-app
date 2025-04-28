import '../../models/category.dart';

abstract class BaseCategoryRepository {
  Future<List<Category>> fetchCategories();
} 