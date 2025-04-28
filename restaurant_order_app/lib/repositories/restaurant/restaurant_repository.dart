import '../../models/restaurant.dart';
import 'base_restaurant_repository.dart';
import '../../services/api/restaurant_api_service.dart';

class RestaurantRepository implements BaseRestaurantRepository {
  final RestaurantApiService _restaurantApiService;

  RestaurantRepository({required RestaurantApiService restaurantApiService})
      : _restaurantApiService = restaurantApiService;

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    return await _restaurantApiService.fetchRestaurants();
  }

  @override
  Future<Restaurant> fetchRestaurantById(String id) async {
    return await _restaurantApiService.fetchRestaurantById(id);
  }

  @override
  Future<Restaurant> toggleFavorite(Restaurant restaurant) async {
    return await _restaurantApiService.toggleFavorite(restaurant.id, !restaurant.isFavorite);
  }
} 