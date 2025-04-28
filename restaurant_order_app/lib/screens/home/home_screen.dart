import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/restaurant.dart';
import '../../models/category.dart';
import '../../widgets/search_field.dart';
import '../../services/api/restaurant_api_service.dart';
import '../../config/theme.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedCategories = [];
  List<Category> categories = [];
  List<Restaurant> restaurants = [];
  bool isLoadingCategories = true;
  bool isLoadingRestaurants = true;
  String? errorMessage;
  
  // For promotions
  final List<Map<String, String>> promotions = [
    {
      'title': 'Special Offer',
      'subtitle': 'Free delivery on your first order',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#FF5252',
    },
    {
      'title': 'New Restaurants',
      'subtitle': 'Discover new flavors near you',
      'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#448AFF',
    },
    {
      'title': '15% Discount',
      'subtitle': 'Use code: WELCOME15',
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#4CAF50',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRestaurants();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoadingCategories = true;
    });
    
    try {
      // Using mock categories for now
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        categories = [
          const Category(id: '1', name: 'Burgers', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60'),
          const Category(id: '2', name: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60'),
          const Category(id: '3', name: 'Sushi', imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60'),
          const Category(id: '4', name: 'Salads', imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60'),
          const Category(id: '5', name: 'Desserts', imageUrl: 'https://images.unsplash.com/photo-1495147466023-ac5c588e2e94?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60'),
          const Category(id: '6', name: 'Drinks', imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60'),
        ];
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
        errorMessage = 'Failed to load categories: ${e.toString()}';
      });
    }
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      isLoadingRestaurants = true;
    });
    
    try {
      final apiService = RestaurantApiService(httpClient: http.Client());
      final loadedRestaurants = await apiService.fetchRestaurants();
      
      setState(() {
        restaurants = loadedRestaurants;
        isLoadingRestaurants = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRestaurants = false;
        errorMessage = 'Failed to load restaurants: ${e.toString()}';
      });
    }
  }

  void _toggleCategory(String categoryName) {
    setState(() {
      if (selectedCategories.contains(categoryName)) {
        selectedCategories.remove(categoryName);
      } else {
        selectedCategories.add(categoryName);
      }
      
      // Here we would filter restaurants, but for simplicity we're not implementing this yet
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _loadCategories(),
              _loadRestaurants(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: Row(
                  children: [
                    FadeInLeft(
                      duration: const Duration(milliseconds: 500),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery to',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Current Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    FadeInRight(
                      duration: const Duration(milliseconds: 500),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () {
                                context.go('/notifications');
                              },
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: SearchField(
                        controller: _searchController,
                        hintText: 'Search for restaurants or dishes',
                        onSearch: (query) {
                          // Handle search
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // Promotions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Special Offers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // View all promotions
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: promotions.length,
                          itemBuilder: (context, index) {
                            final promo = promotions[index];
                            Color promoColor = _getColorFromHex(promo['color']!);
                            
                            return FadeInUp(
                              delay: Duration(milliseconds: 100 * index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                                width: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      promoColor.withOpacity(0.7),
                                      promoColor,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: promoColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: -20,
                                      bottom: -20,
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    Positioned(
                                      right: 20,
                                      bottom: 5,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          promo['image']!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            promo['title']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: 160,
                                            child: Text(
                                              promo['subtitle']!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Handle promotion action
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: promoColor,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: const Text(
                                              'Claim Now',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Categories Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(
                        child: const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: isLoadingCategories
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final isSelected = selectedCategories.contains(category.name);
                                  
                                  return FadeInRight(
                                    delay: Duration(milliseconds: 100 * index),
                                    child: GestureDetector(
                                      onTap: () => _toggleCategory(category.name),
                                      child: Container(
                                        width: 80,
                                        margin: const EdgeInsets.only(right: 16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                                  width: 2,
                                                ),
                                                boxShadow: isSelected ? [
                                                  BoxShadow(
                                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ] : null,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(14),
                                                child: Image.network(
                                                  category.imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              category.name,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
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
              ),
              
              // Restaurants Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FadeInLeft(
                        child: const Text(
                          'Popular Restaurants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FadeInRight(
                        child: TextButton.icon(
                          onPressed: () {
                            // Filter options
                          },
                          icon: const Icon(Icons.tune, size: 18),
                          label: const Text('Filter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Restaurant Cards
              isLoadingRestaurants
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : errorMessage != null
                ? SliverFillRemaining(
                    child: Center(
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
                            'Error: $errorMessage',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadRestaurants,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : restaurants.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No restaurants found',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final restaurant = restaurants[index];
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
                                              Wrap(
                                                spacing: 4,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      restaurant.cuisineType,
                                                      style: TextStyle(
                                                        color: AppTheme.primaryColor,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
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
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.location_on,
                                                        size: 14,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${restaurant.distance.toStringAsFixed(1)} km',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
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
                          childCount: restaurants.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper function to convert hex to color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
} 