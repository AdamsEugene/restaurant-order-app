import '../../models/restaurant.dart';

abstract class BaseRestaurantRepository {
  Future<List<Restaurant>> fetchRestaurants();
  Future<Restaurant> fetchRestaurantById(String id);
  Future<Restaurant> toggleFavorite(Restaurant restaurant);
} 