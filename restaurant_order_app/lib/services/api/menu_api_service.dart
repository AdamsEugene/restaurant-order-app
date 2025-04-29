import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/menu_item.dart';
import '../../config/constants.dart';

class MenuApiService {
  final http.Client httpClient;
  final String baseUrl = AppConstants.apiBaseUrl;
  
  MenuApiService({required this.httpClient});
  
  Future<List<MenuItem>> fetchPopularMenuItems() async {
    try {
      // This would typically call a real API endpoint
      // For demo purposes, we'll return mock data after a delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      return [
        MenuItem(
          id: '1',
          name: 'Jollof Rice with Chicken',
          description: 'Spicy rice cooked in tomato sauce with grilled chicken',
          price: 12.99,
          imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26',
          rating: 4.8,
          restaurantName: 'Asanka Local',
          restaurantId: '1',
          restaurantLocation: 'Accra',
          categories: ['Rice', 'Local', 'Spicy'],
          isSpicy: true,
        ),
        MenuItem(
          id: '2',
          name: 'Waakye with Fish',
          description: 'Rice and beans with grilled tilapia and pepper sauce',
          price: 14.50,
          imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19',
          rating: 4.6,
          restaurantName: 'Holy Sabbath',
          restaurantId: '2',
          restaurantLocation: 'Kumasi',
          categories: ['Rice', 'Beans', 'Fish'],
        ),
        MenuItem(
          id: '3',
          name: 'Banku with Okro Soup',
          description: 'Fermented corn dough with okro soup and grilled tilapia',
          price: 16.99,
          imageUrl: 'https://images.unsplash.com/photo-1562403492-454d4b075cac',
          rating: 4.5,
          restaurantName: 'Auntie Muni Waakye',
          restaurantId: '3',
          restaurantLocation: 'Cape Coast',
          categories: ['Local', 'Soup'],
        ),
        MenuItem(
          id: '4',
          name: 'Kelewele with Groundnut',
          description: 'Spicy fried plantain with groundnut',
          price: 8.99,
          imageUrl: 'https://images.pexels.com/photos/7172067/pexels-photo-7172067.jpeg?auto=compress&cs=tinysrgb&w=800',
          rating: 4.9,
          restaurantName: 'Asanka Local',
          restaurantId: '1',
          restaurantLocation: 'Accra',
          categories: ['Snack', 'Spicy'],
          isSpicy: true,
        ),
        MenuItem(
          id: '5',
          name: 'Fufu with Light Soup',
          description: 'Pounded cassava and plantain with light soup and goat meat',
          price: 18.99,
          imageUrl: 'https://images.pexels.com/photos/5835353/pexels-photo-5835353.jpeg?auto=compress&cs=tinysrgb&w=800',
          rating: 4.7,
          restaurantName: 'Holy Sabbath',
          restaurantId: '2',
          restaurantLocation: 'Kumasi',
          categories: ['Soup', 'Local'],
        ),
        MenuItem(
          id: '6',
          name: 'Red Red with Plantain',
          description: 'Bean stew with fried plantain and palm oil',
          price: 11.99,
          imageUrl: 'https://images.unsplash.com/photo-1551462419-7611a890d477',
          rating: 4.4,
          restaurantName: 'Auntie Muni Waakye',
          restaurantId: '3',
          restaurantLocation: 'Cape Coast',
          categories: ['Beans', 'Vegetarian'],
          isVegetarian: true,
        ),
        MenuItem(
          id: '7',
          name: 'Omo Tuo with Groundnut Soup',
          description: 'Rice balls with groundnut soup and chicken',
          price: 13.99,
          imageUrl: 'https://images.unsplash.com/photo-1572695147233-e9313670e6a5',
          rating: 4.3,
          restaurantName: 'Asanka Local',
          restaurantId: '1',
          restaurantLocation: 'Accra',
          categories: ['Rice', 'Soup'],
        ),
        MenuItem(
          id: '8',
          name: 'Yam with Palava Sauce',
          description: 'Boiled yam with spinach stew and fish',
          price: 12.50,
          imageUrl: 'https://images.unsplash.com/photo-1590167491218-26910adc330f',
          rating: 4.5,
          restaurantName: 'Holy Sabbath',
          restaurantId: '2',
          restaurantLocation: 'Kumasi',
          categories: ['Yam', 'Stew'],
        ),
      ];
    } catch (e) {
      throw Exception('Failed to load menu items: $e');
    }
  }
  
  Future<List<MenuItem>> searchMenuItems(String query) async {
    try {
      // This would typically call a real API endpoint with the search query
      // For demo purposes, we'll filter our mock data after a delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      final allItems = await fetchPopularMenuItems();
      
      if (query.isEmpty) {
        return allItems;
      }
      
      return allItems.where((item) {
        final matchesName = item.name.toLowerCase().contains(query.toLowerCase());
        final matchesDescription = item.description.toLowerCase().contains(query.toLowerCase());
        final matchesRestaurant = item.restaurantName.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = item.categories.any((category) => 
          category.toLowerCase().contains(query.toLowerCase()));
          
        return matchesName || matchesDescription || matchesRestaurant || matchesCategory;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }
  
  Future<MenuItem> getMenuItemDetails(String itemId) async {
    try {
      // This would typically call a real API endpoint
      // For demo purposes, we'll use the mock data and find the item by ID
      await Future.delayed(const Duration(milliseconds: 500));
      
      final allItems = await fetchPopularMenuItems();
      final item = allItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw Exception('Menu item not found'),
      );
      
      return item;
    } catch (e) {
      throw Exception('Failed to get menu item details: $e');
    }
  }
} 