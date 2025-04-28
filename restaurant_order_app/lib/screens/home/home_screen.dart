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
  final List<Map<String, dynamic>> promotions = [
    {
      'title': 'Special Offer',
      'subtitle': 'Free delivery on your first order',
      'description': 'Enjoy free delivery on your first order with us. No minimum spend required.',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#FF5252',
      'expiryDate': '2023-12-31',
      'code': 'FIRSTDELIVERY',
    },
    {
      'title': 'New Restaurants',
      'subtitle': 'Discover new flavors near you',
      'description': '10% off your first order from our newly added restaurant partners.',
      'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#448AFF',
      'expiryDate': '2023-12-15',
      'code': 'NEWPLACE10',
    },
    {
      'title': '15% Discount',
      'subtitle': 'Use code: WELCOME15',
      'description': 'Get 15% off your order with a minimum spend of \$20.',
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#4CAF50',
      'expiryDate': '2023-12-10',
      'code': 'WELCOME15',
    },
  ];

  String _currentLocation = 'Current Location';
  final List<String> _savedLocations = [
    'Home - 123 Main St, Accra',
    'Work - 45 Independence Ave, Accra',
    'University - 78 Campus Road, Accra',
  ];

  // Notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Your order is on the way!',
      'message': 'Your order #1234 has been picked up by our delivery partner.',
      'time': 'Just now',
      'read': false,
      'type': 'delivery',
    },
    {
      'title': 'Get 50% off on your next order!',
      'message': 'Use code WELCOME50 for 50% off on your next order.',
      'time': '2 hours ago',
      'read': false,
      'type': 'promotion',
    },
    {
      'title': 'New Restaurant Added',
      'message': 'Check out our new restaurant partner "The Seafood Shack"!',
      'time': 'Yesterday',
      'read': true,
      'type': 'info',
    },
  ];

  int get _unreadNotificationsCount => 
      _notifications.where((n) => n['read'] == false).length;

  // Sample cart items
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Jollof Rice with Chicken',
      'quantity': 1,
      'price': 12.99,
      'imageUrl': 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
    },
    {
      'name': 'Waakye with Fish',
      'quantity': 2,
      'price': 14.50,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
    },
  ];

  double get _cartTotal => _cartItems.fold(
      0, (total, item) => total + (item['price'] as double) * (item['quantity'] as int));

  int get _cartItemCount => _cartItems.fold(
      0, (total, item) => total + (item['quantity'] as int));

  // Search-related variables
  String _searchQuery = '';
  List<Restaurant> _filteredRestaurants = [];
  bool _isSearching = false;

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
        _filteredRestaurants = loadedRestaurants;
        isLoadingRestaurants = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRestaurants = false;
        errorMessage = 'Failed to load restaurants: ${e.toString()}';
      });
    }
  }

  // Search restaurants based on query
  void _searchRestaurants(String query) {
    setState(() {
      _searchQuery = query.trim();
      _isSearching = _searchQuery.isNotEmpty;
      
      if (_searchQuery.isEmpty) {
        _filteredRestaurants = restaurants;
      } else {
        _filteredRestaurants = restaurants.where((restaurant) {
          return restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 restaurant.cuisineType.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _filteredRestaurants = restaurants;
    });
  }

  void _toggleCategory(String categoryName) {
    // Navigate to the category screen instead of just toggling selection
    final selectedCategory = categories.firstWhere(
      (category) => category.name == categoryName,
      orElse: () => const Category(id: '0', name: 'Unknown', imageUrl: ''),
    );
    
    // If we have a valid category, navigate to its screen
    if (selectedCategory.id != '0') {
      context.go('/categories/${selectedCategory.id}', extra: {'name': categoryName});
    }
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
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => _buildLocationSheet(context),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 18),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery to',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _currentLocation.length > 20 
                                            ? '${_currentLocation.substring(0, 18)}...' 
                                            : _currentLocation,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(Icons.keyboard_arrow_down, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    FadeInRight(
                      duration: const Duration(milliseconds: 500),
                      child: Row(
                        children: [
                          // Cart button
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showMiniCart(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 20),
                                ),
                              ),
                              if (_cartItems.isNotEmpty)
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
                                  child: Text(
                                    _cartItemCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Notification button
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showNotificationsPanel(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 20),
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
                                child: Text(
                                  _unreadNotificationsCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
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
                        onSearch: _searchRestaurants,
                        onClear: _clearSearch,
                        showClearButton: _isSearching,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Search results indicator
              if (_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Results for "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _clearSearch,
                              child: const Text('Clear Search'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_filteredRestaurants.length} ${_filteredRestaurants.length == 1 ? 'restaurant' : 'restaurants'} found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Divider(height: 24),
                      ],
                    ),
                  ),
                ),
              
              // Promotions Section
              if (!_isSearching)
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
                                  context.go('/special-offers');
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
                              Color promoColor = _getColorFromHex(promo['color']);
                              
                              return FadeInUp(
                                delay: Duration(milliseconds: 100 * index),
                                child: GestureDetector(
                                  onTap: () => _showPromoDetails(context, promo),
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
                                                  _showPromoDetails(context, promo);
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
                                                  'View Details',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
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
                ),
              
              // Categories Section
              if (!_isSearching)
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
                                              Container(
                                                height: 60,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
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
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
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
                        child: Text(
                          _isSearching ? 'Search Results' : 'Popular Restaurants',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!_isSearching)
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
                : _filteredRestaurants.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching 
                                  ? 'No results found for "$_searchQuery"' 
                                  : 'No restaurants available',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            if (_isSearching)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Try a different search term or browse our categories',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 24),
                            if (_isSearching)
                              ElevatedButton(
                                onPressed: _clearSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Clear Search'),
                              ),
                          ],
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
                          childCount: _filteredRestaurants.length,
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

  // Calculate discount value based on promo type
  double _getDiscountValue(Map<String, dynamic> promo) {
    // This is a simplified implementation
    // In a real app, you would have more complex logic based on promo type
    
    final title = promo['title'].toString().toLowerCase();
    
    if (title.contains('free delivery')) {
      return 5.0; // Assuming $5 delivery fee
    } else if (title.contains('10%')) {
      return 0.1; // 10% discount
    } else if (title.contains('15%')) {
      return 0.15; // 15% discount
    } else if (title.contains('20%')) {
      return 0.2; // 20% discount
    } else if (title.contains('25%')) {
      return 0.25; // 25% discount
    } else if (title.contains('buy 1 get 1')) {
      return 0.5; // 50% off (effectively buy one get one free)
    } else {
      return 0.1; // Default 10% discount
    }
  }

  // Build the location selection sheet
  Widget _buildLocationSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Search address bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search address',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          
          // Current location option
          GestureDetector(
            onTap: () {
              setState(() {
                _currentLocation = 'Current Location';
              });
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _currentLocation == 'Current Location' 
                    ? AppTheme.primaryColor.withOpacity(0.1) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentLocation == 'Current Location' 
                      ? AppTheme.primaryColor 
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: AppTheme.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Using GPS',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentLocation == 'Current Location')
                    const Icon(Icons.check_circle, color: AppTheme.primaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Saved locations header
          const Text(
            'Saved Locations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Saved locations list
          Expanded(
            child: ListView.builder(
              itemCount: _savedLocations.length,
              itemBuilder: (context, index) {
                final location = _savedLocations[index];
                final isHome = location.startsWith('Home');
                final isWork = location.startsWith('Work');
                final isUniversity = location.startsWith('University');
                
                IconData locationIcon;
                if (isHome) {
                  locationIcon = Icons.home;
                } else if (isWork) {
                  locationIcon = Icons.work;
                } else if (isUniversity) {
                  locationIcon = Icons.school;
                } else {
                  locationIcon = Icons.location_on;
                }
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentLocation = location;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _currentLocation == location 
                          ? AppTheme.primaryColor.withOpacity(0.1) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _currentLocation == location 
                            ? AppTheme.primaryColor 
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isHome ? Colors.green.shade100 
                                : isWork ? Colors.blue.shade100 
                                : isUniversity ? Colors.purple.shade100 
                                : Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            locationIcon,
                            color: isHome ? Colors.green 
                                : isWork ? Colors.blue 
                                : isUniversity ? Colors.purple 
                                : Colors.orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_currentLocation == location)
                          const Icon(Icons.check_circle, color: AppTheme.primaryColor),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Add new address button
          ElevatedButton.icon(
            onPressed: () {
              _showAddAddressMap(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show the notifications panel
  void _showNotificationsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildNotificationsPanel(context),
    );
  }

  // Build the notifications panel
  Widget _buildNotificationsPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_unreadNotificationsCount > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var notification in _notifications) {
                            notification['read'] = true;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Mark all as read'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notifications list
          _notifications.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You will be notified when there are new updates',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final bool isRead = notification['read'] as bool;
                      final String type = notification['type'] as String;
                      
                      IconData notificationIcon;
                      Color iconColor;
                      
                      switch (type) {
                        case 'delivery':
                          notificationIcon = Icons.delivery_dining;
                          iconColor = Colors.blue;
                          break;
                        case 'promotion':
                          notificationIcon = Icons.local_offer;
                          iconColor = Colors.deepOrange;
                          break;
                        case 'info':
                          notificationIcon = Icons.info_outline;
                          iconColor = Colors.green;
                          break;
                        default:
                          notificationIcon = Icons.notifications;
                          iconColor = Colors.grey;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.white : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isRead ? Colors.grey.shade200 : Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                notificationIcon,
                                color: iconColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification['message'] as String,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        notification['time'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (!isRead)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              notification['read'] = true;
                                            });
                                          },
                                          child: const Text(
                                            'Mark as read',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // Show the mini cart
  void _showMiniCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildMiniCartSheet(context),
    );
  }

  // Build the mini cart sheet
  Widget _buildMiniCartSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Cart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Cart items
          _cartItems.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add items to your cart to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['imageUrl'] as String,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Item details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${(item['price'] as double).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Quantity selector
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 16),
                                              onPressed: () {
                                                // Decrease quantity
                                                if (item['quantity'] > 1) {
                                                  setState(() {
                                                    item['quantity'] = item['quantity'] - 1;
                                                  });
                                                  Navigator.pop(context);
                                                  _showMiniCart(context);
                                                } else {
                                                  // Remove item if quantity becomes 0
                                                  setState(() {
                                                    _cartItems.removeAt(index);
                                                  });
                                                  if (_cartItems.isEmpty) {
                                                    Navigator.pop(context);
                                                  } else {
                                                    Navigator.pop(context);
                                                    _showMiniCart(context);
                                                  }
                                                }
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 30,
                                                minHeight: 30,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                '${item['quantity']}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 16),
                                              onPressed: () {
                                                // Increase quantity
                                                setState(() {
                                                  item['quantity'] = item['quantity'] + 1;
                                                });
                                                Navigator.pop(context);
                                                _showMiniCart(context);
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 30,
                                                minHeight: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () {
                                          // Remove item
                                          setState(() {
                                            _cartItems.removeAt(index);
                                          });
                                          if (_cartItems.isEmpty) {
                                            Navigator.pop(context);
                                          } else {
                                            Navigator.pop(context);
                                            _showMiniCart(context);
                                          }
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          
          // Footer with total and checkout button
          if (_cartItems.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/cart');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Add New Address with map selection
  void _showAddAddressMap(BuildContext context) {
    Navigator.pop(context); // Close the location sheet first
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddAddressMapSheet(context),
    );
  }

  // Build the map selection sheet for adding a new address
  Widget _buildAddAddressMapSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search address input
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for a location',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Map container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for map (in a real implementation, this would be a Google Maps widget)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/staticmap?center=Accra,Ghana&zoom=13&size=600x600&maptype=roadmap&key=YOUR_API_KEY',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map, size: 80, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'Map preview unavailable',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'In a real implementation, this would be an interactive Google Map',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Center pin marker
                  const Center(
                    child: Icon(
                      Icons.location_pin,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  ),
                  
                  // Current location button
                  Positioned(
                    right: 16,
                    bottom: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.blue),
                        onPressed: () {
                          // In a real implementation, this would get the user's current location
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Getting your current location...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Selected location info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Move the map to pinpoint your exact location',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Address details input
          TextField(
            decoration: InputDecoration(
              hintText: 'Address Label (e.g., Home, Work)',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          
          // Save button
          ElevatedButton(
            onPressed: () {
              // Add the new address to saved locations
              setState(() {
                _savedLocations.add('New Location - Selected from Map');
                _currentLocation = 'New Location - Selected from Map';
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New address added successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save This Location'),
          ),
        ],
      ),
    );
  }

  // Show promo details
  void _showPromoDetails(BuildContext context, Map<String, dynamic> promo) {
    Color promoColor = _getColorFromHex(promo['color']);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image with gradient overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Image.network(
                      promo['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        promoColor.withOpacity(0.5),
                        promoColor.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.black87),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        promo['subtitle'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2.0,
                              color: Color.fromARGB(130, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Promotion details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      promo['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Promo code
                    const Text(
                      'Promo Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            promo['code'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Copy to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied ${promo['code']} to clipboard'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Expiry date
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          'Valid until ${promo['expiryDate']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Claim button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Apply promo to current order
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Promotion ${promo['code']} applied!'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          // Navigate to cart with promotion data
                          context.go(
                            '/cart',
                            extra: {
                              'promoCode': promo['code'],
                              'promoDiscount': _getDiscountValue(promo),
                              'promoTitle': promo['title'],
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Promotion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 