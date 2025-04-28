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
        name: 'Auntie Muni Waakye',
        description: 'Famous for authentic Waakye and traditional Ghanaian breakfast dishes served with all the classic sides.',
        imageUrl: 'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.8,
        distance: 1.2,
        address: '15 Labone St, Accra',
        cuisineType: 'Ghanaian',
        isFavorite: false,
        deliveryTime: 25,
        menu: [
          MenuItem(
            id: '101',
            name: 'Waakye Special',
            description: 'Traditional rice and beans dish served with fish, meat, boiled egg, spaghetti, gari, and spicy pepper sauce',
            price: 35.99,
            imageUrl: 'https://images.pexels.com/photos/7470545/pexels-photo-7470545.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '102',
            name: 'Jollof Rice',
            description: 'Spicy rice cooked in tomato sauce with your choice of grilled chicken or beef',
            price: 30.50,
            imageUrl: 'https://images.pexels.com/photos/7625056/pexels-photo-7625056.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
        ],
      ),
      Restaurant(
        id: '2',
        name: 'Asanka Local',
        description: 'Authentic Ghanaian cuisine made with locally sourced ingredients. Home of the best banku and tilapia.',
        imageUrl: 'https://images.pexels.com/photos/6260921/pexels-photo-6260921.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.7,
        distance: 2.5,
        address: '45 Cantonments Rd, Accra',
        cuisineType: 'Ghanaian',
        isFavorite: false,
        deliveryTime: 35,
        menu: [
          MenuItem(
            id: '201',
            name: 'Banku with Tilapia',
            description: 'Fermented corn and cassava dough served with grilled tilapia, hot pepper sauce and tomato gravy',
            price: 45.99,
            imageUrl: 'https://images.pexels.com/photos/8963961/pexels-photo-8963961.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '202',
            name: 'Fufu with Light Soup',
            description: 'Pounded cassava and plantain served with spicy light soup and your choice of meat',
            price: 40.99,
            imageUrl: 'https://images.pexels.com/photos/5949900/pexels-photo-5949900.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '203',
            name: 'Kelewele',
            description: 'Spicy fried plantains seasoned with ginger, cayenne pepper, and other spices',
            price: 15.99,
            imageUrl: 'https://images.pexels.com/photos/8240717/pexels-photo-8240717.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: false,
            category: 'Starters',
          ),
        ],
      ),
      Restaurant(
        id: '3',
        name: 'Katawodieso',
        description: 'Street food specialists offering the best of Ghanaian quick bites with authentic flavors.',
        imageUrl: 'https://images.pexels.com/photos/6048583/pexels-photo-6048583.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.5,
        distance: 1.7,
        address: '78 Spintex Rd, Accra',
        cuisineType: 'Street Food',
        isFavorite: true,
        deliveryTime: 20,
        menu: [
          MenuItem(
            id: '301',
            name: 'Kofi Brokeman (Roasted Plantain)',
            description: 'Roasted plantain served with groundnuts and spicy pepper sauce',
            price: 12.99,
            imageUrl: 'https://images.pexels.com/photos/918581/pexels-photo-918581.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Street Food',
          ),
          MenuItem(
            id: '302',
            name: 'Meat Pie',
            description: 'Flaky pastry filled with seasoned minced meat, onions and spices',
            price: 8.99,
            imageUrl: 'https://images.pexels.com/photos/6607314/pexels-photo-6607314.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: false,
            category: 'Street Food',
          ),
          MenuItem(
            id: '303',
            name: 'Red Red',
            description: 'Black-eyed peas stewed in palm oil and tomato sauce, served with fried plantain',
            price: 25.99,
            imageUrl: 'https://images.pexels.com/photos/5737241/pexels-photo-5737241.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
        ],
      ),
      Restaurant(
        id: '4',
        name: 'Kenkey Boutique',
        description: 'Specializing in different varieties of kenkey paired with fresh fish and pepper sauces.',
        imageUrl: 'https://images.pexels.com/photos/6605310/pexels-photo-6605310.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.6,
        distance: 3.2,
        address: '23 Oxford St, Osu, Accra',
        cuisineType: 'Ga Traditional',
        isFavorite: false,
        deliveryTime: 30,
        menu: [
          MenuItem(
            id: '401',
            name: 'Ga Kenkey with Fish',
            description: 'Fermented corn dough served with fried fish, shrimp, hot pepper and tomato sauce',
            price: 38.50,
            imageUrl: 'https://images.pexels.com/photos/7173319/pexels-photo-7173319.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '402',
            name: 'Fante Kenkey',
            description: 'Milder version of kenkey wrapped in plantain leaves, served with fried fish and hot pepper sauce',
            price: 35.99,
            imageUrl: 'https://images.pexels.com/photos/8240881/pexels-photo-8240881.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: false,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '403',
            name: 'Shito',
            description: 'Spicy black pepper sauce made with dried fish, shrimp, and spices',
            price: 10.99,
            imageUrl: 'https://images.pexels.com/photos/5737232/pexels-photo-5737232.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Sides',
          ),
        ],
      ),
      Restaurant(
        id: '5',
        name: 'TubaaniHQ',
        description: 'Northern Ghana specialties with a focus on tubaani, kuli-kuli and other regional delicacies.',
        imageUrl: 'https://images.pexels.com/photos/6546231/pexels-photo-6546231.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.4,
        distance: 4.1,
        address: '110 Atomic Road, Accra',
        cuisineType: 'Northern Ghana',
        isFavorite: false,
        deliveryTime: 40,
        menu: [
          MenuItem(
            id: '501',
            name: 'Tubaani',
            description: 'Steamed bean cake made from bambara beans, served with spicy sauce and kuli-kuli',
            price: 28.99,
            imageUrl: 'https://images.pexels.com/photos/4577379/pexels-photo-4577379.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Northern Specialties',
          ),
          MenuItem(
            id: '502',
            name: 'Tuo Zaafi (TZ)',
            description: 'Thick porridge made from millet or corn flour, served with ayoyo soup and meat',
            price: 32.99,
            imageUrl: 'https://images.pexels.com/photos/5835353/pexels-photo-5835353.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: false,
            category: 'Northern Specialties',
          ),
          MenuItem(
            id: '503',
            name: 'Kuli-Kuli',
            description: 'Crunchy groundnut snack made from peanut paste, spices and hot pepper',
            price: 8.99,
            imageUrl: 'https://images.pexels.com/photos/7172067/pexels-photo-7172067.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Snacks',
          ),
        ],
      ),
      // New Restaurant: Holy Sabbath
      Restaurant(
        id: '6',
        name: 'Holy Sabbath',
        description: 'Serving a variety of traditional Ghanaian dishes with recipes passed down through generations.',
        imageUrl: 'https://images.pexels.com/photos/3992656/pexels-photo-3992656.png?auto=compress&cs=tinysrgb&w=800',
        rating: 4.9,
        distance: 1.5,
        address: '38 Ring Road, East Legon, Accra',
        cuisineType: 'Traditional Ghanaian',
        isFavorite: false,
        deliveryTime: 30,
        menu: [
          MenuItem(
            id: '601',
            name: 'Banku with Okra Soup',
            description: 'Fermented corn dough served with spicy okra soup and assorted meat or fish',
            price: 42.99,
            imageUrl: 'https://images.pexels.com/photos/3662139/pexels-photo-3662139.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '602',
            name: 'Fufu with Palm Nut Soup',
            description: 'Pounded cassava and plantain served with rich palm nut soup and choice of protein',
            price: 44.99,
            imageUrl: 'https://images.pexels.com/photos/7172089/pexels-photo-7172089.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '603',
            name: 'Omotuo (Rice Balls)',
            description: 'Soft balls made from rice served with groundnut soup or palm nut soup',
            price: 38.50,
            imageUrl: 'https://images.pexels.com/photos/5835340/pexels-photo-5835340.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: false,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '604',
            name: 'Tuo Zaafi (TZ)',
            description: 'Traditional northern dish made from millet or corn flour, served with green leaf soup',
            price: 35.99,
            imageUrl: 'https://images.pexels.com/photos/5949897/pexels-photo-5949897.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: false,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '605',
            name: 'Jollof Rice with Chicken',
            description: 'Spicy rice cooked in tomato sauce and spices, served with grilled chicken and salad',
            price: 36.50,
            imageUrl: 'https://images.pexels.com/photos/7625059/pexels-photo-7625059.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: true,
            category: 'Main Dishes',
          ),
          MenuItem(
            id: '606',
            name: 'Yam and Kontomire Stew',
            description: 'Boiled yam served with kontomire (cocoyam leaves) stew and smoked fish',
            price: 32.99,
            imageUrl: 'https://images.pexels.com/photos/6697469/pexels-photo-6697469.jpeg?auto=compress&cs=tinysrgb&w=800',
            isPopular: false,
            category: 'Main Dishes',
          ),
        ],
      ),
    ];
  }
} 