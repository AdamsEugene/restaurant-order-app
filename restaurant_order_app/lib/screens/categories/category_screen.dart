import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/restaurant.dart';
import '../../services/api/restaurant_api_service.dart';
import '../../config/theme.dart';
import 'package:http/http.dart' as http;

class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryScreen({
    Key? key, 
    required this.categoryId, 
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final apiService = RestaurantApiService(httpClient: http.Client());
      final loadedRestaurants = await apiService.fetchRestaurants();
      
      // Define category restaurant mappings - each category should have specific restaurants
      Map<String, List<String>> categoryToRestaurantMap = {
        'burgers': ['American', 'Fast Food', 'Burger', 'Street Food'],
        'pizza': ['Italian', 'Fast Food', 'Pizza'],
        'sushi': ['Japanese', 'Asian', 'Sushi'],
        'salads': ['Healthy', 'Vegetarian', 'Salad', 'Fresh'],
        'desserts': ['Bakery', 'Dessert', 'Sweet', 'Cake', 'Ice Cream'],
        'drinks': ['Café', 'Coffee', 'Beverages', 'Juice', 'Bar'],
      };
      
      // Get appropriate cuisines for this category
      List<String> matchingCuisines = categoryToRestaurantMap[widget.categoryName.toLowerCase()] ?? [];
      
      // Filter restaurants by category
      final categoryRestaurants = loadedRestaurants.where((restaurant) {
        final lowerCatName = widget.categoryName.toLowerCase();
        final lowerCuisine = restaurant.cuisineType.toLowerCase();
        final lowerName = restaurant.name.toLowerCase();
        
        // Check for cuisine type match
        bool cuisineMatch = false;
        for (String cuisine in matchingCuisines) {
          if (lowerCuisine.contains(cuisine.toLowerCase())) {
            cuisineMatch = true;
            break;
          }
        }
        
        // Check for direct name match
        bool nameMatch = lowerName.contains(lowerCatName) || 
                         lowerCuisine.contains(lowerCatName);
        
        // Check for menu items that match category
        bool hasMatchingMenuItems = false;
        for (var menuItem in restaurant.menu) {
          if (menuItem.name.toLowerCase().contains(lowerCatName)) {
            hasMatchingMenuItems = true;
            break;
          }
        }
        
        // For demo purposes, make sure each category has at least some restaurants
        // We'll ensure every restaurant shows up in at least one category
        switch (lowerCatName) {
          case 'burgers':
            return cuisineMatch || nameMatch || hasMatchingMenuItems || 
                   restaurant.id == '3' || restaurant.id == '5'; // Street Food and Northern Ghana
          case 'pizza':
            return cuisineMatch || nameMatch || hasMatchingMenuItems || 
                   restaurant.id == '6'; // Holy Sabbath
          case 'sushi':
            return cuisineMatch || nameMatch || hasMatchingMenuItems || 
                   restaurant.id == '4'; // Kenkey Boutique
          case 'salads':
            return cuisineMatch || nameMatch || hasMatchingMenuItems || 
                   restaurant.id == '1' || restaurant.id == '2'; // Ghanaian restaurants
          case 'desserts':
            return cuisineMatch || nameMatch || hasMatchingMenuItems || 
                   restaurant.id == '2' || restaurant.id == '6'; // Asanka Local and Holy Sabbath
          case 'drinks':
            return cuisineMatch || nameMatch || hasMatchingMenuItems || 
                   restaurant.id == '1' || restaurant.id == '3'; // Auntie Muni and Katawodieso
          default:
            return true; // If unknown category, show all restaurants
        }
      }).toList();
      
      setState(() {
        _restaurants = categoryRestaurants;
        _filteredRestaurants = categoryRestaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load restaurants: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/home'),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new, 
              size: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _filteredRestaurants.isEmpty
                  ? _buildEmptyState()
                  : _buildRestaurantGrid(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $_errorMessage',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRestaurants,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${widget.categoryName} Restaurants Found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'We couldn\'t find any restaurants in this category. Try another category or check back later.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Explore Other Categories'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantGrid() {
    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            FadeInLeft(
              child: Text(
                '${_filteredRestaurants.length} ${widget.categoryName} ${_filteredRestaurants.length == 1 ? 'Restaurant' : 'Restaurants'} Found',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: GestureDetector(
                      onTap: () {
                        context.go('/restaurants/${restaurant.id}');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Restaurant image
                            Stack(
                              children: [
                                Hero(
                                  tag: 'restaurant-${restaurant.id}',
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      restaurant.imageUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.error_outline),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Toggle favorite functionality would go here
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        restaurant.isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: restaurant.isFavorite ? Colors.red : Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant.rating.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Restaurant details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      restaurant.cuisineType,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${restaurant.deliveryTime} min',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (restaurant.deliveryFee == 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Free Delivery',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 