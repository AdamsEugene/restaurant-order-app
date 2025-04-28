import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../config/app_config.dart';

class RestaurantApiService {
  final http.Client _httpClient;
  final String _baseUrl = AppConfig.apiBaseUrl;

  RestaurantApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      // For development, return mock data instead of making API call
      return _getMockRestaurants();
      
      // Real API implementation (commented out for now)
      /*
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/restaurants'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch restaurants');
      }

      final List<dynamic> restaurantsJson = json.decode(response.body);
      return restaurantsJson
          .map((json) => Restaurant.fromJson(json))
          .toList();
      */
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  Future<Restaurant> fetchRestaurantById(String id) async {
    try {
      // For development, return mock data
      final mockRestaurants = _getMockRestaurants();
      final restaurant = mockRestaurants.firstWhere(
        (r) => r.id == id,
        orElse: () => throw Exception('Restaurant not found'),
      );
      return restaurant;
      
      // Real API implementation (commented out)
      /*
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/restaurants/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch restaurant details');
      }

      final restaurantJson = json.decode(response.body);
      return Restaurant.fromJson(restaurantJson);
      */
    } catch (e) {
      throw Exception('Failed to fetch restaurant details: $e');
    }
  }

  Future<Restaurant> toggleFavorite(String id, bool isFavorite) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('$_baseUrl/restaurants/$id/favorite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isFavorite': isFavorite}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update favorite status');
      }

      final restaurantJson = jsonDecode(response.body);
      return Restaurant.fromJson(restaurantJson);
    } catch (e) {
      throw Exception('Failed to update favorite status: ${e.toString()}');
    }
  }

  Future<List<MenuItem>> fetchMenuItems(String restaurantId) async {
    try {
      // For development, find in mock data
      final restaurants = _getMockRestaurants();
      final restaurant = restaurants.firstWhere(
        (restaurant) => restaurant.id == restaurantId,
        orElse: () => throw Exception('Restaurant not found'),
      );
      
      return restaurant.menu;
    } catch (e) {
      throw Exception('Failed to fetch menu items: $e');
    }
  }

  // Mock data for development
  List<Restaurant> _getMockRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Burger Paradise',
        description: 'Best burgers in town with a variety of sides and drinks.',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
        rating: 4.5,
        distance: 1.2,
        address: '123 Main St, Anytown',
        cuisineType: 'Fast Food',
        isFavorite: false,
        menu: [
          MenuItem(
            id: '101',
            name: 'Classic Burger',
            description: 'Beef patty with lettuce, tomato, onions, and our special sauce',
            price: 7.99,
            imageUrl: 'https://images.unsplash.com/photo-1565299507177-b0ac66763828?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
            isPopular: true,
            category: 'Burgers',
          ),
          MenuItem(
            id: '102',
            name: 'Cheeseburger',
            description: 'Classic burger with American cheese',
            price: 8.99,
            imageUrl: 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
            isPopular: true,
            category: 'Burgers',
          ),
        ],
      ),
      Restaurant(
        id: '2',
        name: 'Pizza Heaven',
        description: 'Authentic Italian pizzas made in wood-fired ovens.',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
        rating: 4.8,
        distance: 2.5,
        address: '456 Oak St, Anytown',
        cuisineType: 'Italian',
        isFavorite: false,
        menu: [
          MenuItem(
            id: '201',
            name: 'Margherita Pizza',
            description: 'Classic pizza with tomato sauce, mozzarella, and basil',
            price: 12.99,
            imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
            isPopular: true,
            category: 'Pizza',
          ),
          MenuItem(
            id: '202',
            name: 'Pepperoni Pizza',
            description: 'Tomato sauce, mozzarella, and pepperoni',
            price: 14.99,
            imageUrl: 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
            isPopular: false,
            category: 'Pizza',
          ),
        ],
      ),
      Restaurant(
        id: '3',
        name: 'Sushi Express',
        description: 'Fresh sushi and Japanese cuisine delivered quickly.',
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
        rating: 4.3,
        distance: 3.7,
        address: '789 Maple Ave, Anytown',
        cuisineType: 'Japanese',
        isFavorite: true,
        menu: [],
      ),
    ];
  }
} 