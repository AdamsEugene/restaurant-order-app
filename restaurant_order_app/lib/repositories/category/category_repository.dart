import '../../models/category.dart';
import '../../services/api/category_api_service.dart';
import 'base_category_repository.dart';

class CategoryRepository implements BaseCategoryRepository {
  final CategoryApiService _categoryApiService;

  CategoryRepository({required CategoryApiService categoryApiService})
      : _categoryApiService = categoryApiService;

  @override
  Future<List<Category>> fetchCategories() async {
    return await _categoryApiService.fetchCategories();
  }
} 