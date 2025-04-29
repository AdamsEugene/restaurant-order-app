import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../services/api/restaurant_api_service.dart';
import '../../services/api/menu_api_service.dart';
import '../../config/theme.dart';
import '../../widgets/search_field.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Tabs
  late TabController _tabController;
  
  // Search state
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isLoading = false;
  String? _error;
  
  // Filter state
  double _minRating = 0.0;
  List<String> _selectedCuisines = [];
  bool _freeDeliveryOnly = false;
  int _maxDeliveryTime = 60;
  String _sortBy = 'rating';
  
  // Data
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<MenuItem> _allMenuItems = [];
  List<MenuItem> _filteredMenuItems = [];
  List<String> _availableCuisines = [];
  
  // Recently viewed
  final List<Restaurant> _recentlyViewed = [];
  
  // Popular searches
  final List<String> _popularSearches = [
    'Burgers',
    'Pizza',
    'Coffee',
    'Salad',
    'Vegetarian',
    'Fast Food',
    'Dessert',
    'Breakfast',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  // Load initial data
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await Future.wait([
        _loadRestaurants(),
        _loadMenuItems(),
      ]);
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Load restaurants
  Future<void> _loadRestaurants() async {
    try {
      final apiService = RestaurantApiService(httpClient: http.Client());
      final restaurants = await apiService.fetchRestaurants();
      
      // Extract unique cuisine types
      final cuisines = restaurants
          .map((r) => r.cuisineType)
          .toSet()
          .toList();
      
      setState(() {
        _allRestaurants = restaurants;
        _filteredRestaurants = restaurants;
        _availableCuisines = cuisines;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load restaurants: ${e.toString()}';
      });
    }
  }
  
  // Load menu items
  Future<void> _loadMenuItems() async {
    try {
      final apiService = MenuApiService(httpClient: http.Client());
      final menuItems = await apiService.fetchPopularMenuItems();
      
      setState(() {
        _allMenuItems = menuItems;
        _filteredMenuItems = menuItems;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load menu items: ${e.toString()}';
      });
    }
  }
  
  // Handle tab change
  void _handleTabChange() {
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }
  
  // Perform search with current query
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredRestaurants = _allRestaurants;
        _filteredMenuItems = _allMenuItems;
      });
      return;
    }
    
    setState(() {
      _searchQuery = query;
      _isSearching = true;
      
      // Apply search query
      _filteredRestaurants = _allRestaurants.where((restaurant) {
        final matchesName = restaurant.name.toLowerCase().contains(query.toLowerCase());
        final matchesCuisine = restaurant.cuisineType.toLowerCase().contains(query.toLowerCase());
        return matchesName || matchesCuisine;
      }).toList();
      
      _filteredMenuItems = _allMenuItems.where((item) {
        final matchesName = item.name.toLowerCase().contains(query.toLowerCase());
        final matchesDescription = item.description.toLowerCase().contains(query.toLowerCase());
        return matchesName || matchesDescription;
      }).toList();
      
      // Apply filters
      _applyFilters();
    });
  }
  
  // Apply filters to search results
  void _applyFilters() {
    if (_tabController.index == 0) {
      // Apply filters to restaurants
      _filteredRestaurants = _filteredRestaurants.where((restaurant) {
        // Rating filter
        if (restaurant.rating < _minRating) return false;
        
        // Cuisine filter
        if (_selectedCuisines.isNotEmpty && 
            !_selectedCuisines.contains(restaurant.cuisineType)) return false;
        
        // Free delivery filter
        if (_freeDeliveryOnly && restaurant.deliveryFee > 0) return false;
        
        // Delivery time filter
        if (restaurant.deliveryTime > _maxDeliveryTime) return false;
        
        return true;
      }).toList();
      
      // Sort restaurants
      _sortRestaurants();
    }
  }
  
  // Sort restaurants based on selected sort option
  void _sortRestaurants() {
    switch (_sortBy) {
      case 'rating':
        _filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'deliveryTime':
        _filteredRestaurants.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
        break;
      case 'distance':
        _filteredRestaurants.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }
  }
  
  // Clear search and reset filters
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _filteredRestaurants = _allRestaurants;
      _filteredMenuItems = _allMenuItems;
      _resetFilters();
    });
  }
  
  // Reset filters
  void _resetFilters() {
    setState(() {
      _minRating = 0.0;
      _selectedCuisines = [];
      _freeDeliveryOnly = false;
      _maxDeliveryTime = 60;
      _sortBy = 'rating';
    });
  }
  
  // Show filter modal
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(context),
    );
  }
  
  // Build filter sheet
  Widget _buildFilterSheet(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort',
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
              const Divider(height: 24),
              
              // Sort by options
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: [
                  _sortOption('Highest Rating', 'rating', setModalState),
                  _sortOption('Fastest Delivery', 'deliveryTime', setModalState),
                  _sortOption('Nearest', 'distance', setModalState),
                ],
              ),
              const Divider(height: 24),
              
              // Rating filter
              const Text(
                'Minimum Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('0'),
                  Expanded(
                    child: Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating.toStringAsFixed(1),
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setModalState(() {
                          _minRating = value;
                        });
                      },
                    ),
                  ),
                  const Text('5'),
                ],
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_minRating.toStringAsFixed(1)}+',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              
              // Cuisine filter
              const Text(
                'Cuisine Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCuisines.map((cuisine) {
                      final isSelected = _selectedCuisines.contains(cuisine);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              _selectedCuisines.remove(cuisine);
                            } else {
                              _selectedCuisines.add(cuisine);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            cuisine,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 24),
              
              // Delivery options
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Max Delivery Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('${_maxDeliveryTime.toInt()} min'),
                            Expanded(
                              child: Slider(
                                value: _maxDeliveryTime.toDouble(),
                                min: 10,
                                max: 60,
                                divisions: 5,
                                activeColor: AppTheme.primaryColor,
                                onChanged: (value) {
                                  setModalState(() {
                                    _maxDeliveryTime = value.toInt();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Free delivery filter
              CheckboxListTile(
                title: const Text(
                  'Free Delivery Only',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: _freeDeliveryOnly,
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setModalState(() {
                    _freeDeliveryOnly = value ?? false;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _resetFilters();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppTheme.primaryColor),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _applyFilters();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Sort option widget
  Widget _sortOption(String label, String value, StateSetter setModalState) {
    final isSelected = _sortBy == value;
    
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  // Handle restaurant tap
  void _onRestaurantTap(Restaurant restaurant) {
    context.go('/restaurants/${restaurant.id}');
    
    // Add to recently viewed if not already in the list
    if (!_recentlyViewed.any((r) => r.id == restaurant.id)) {
      setState(() {
        _recentlyViewed.insert(0, restaurant);
        if (_recentlyViewed.length > 5) {
          _recentlyViewed.removeLast();
        }
      });
    }
  }
  
  // Handle menu item tap
  void _onMenuItemTap(MenuItem menuItem) {
    context.go('/menu/${menuItem.id}');
  }
  
  // Build restaurant card
  Widget _buildRestaurantCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: () => _onRestaurantTap(restaurant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    restaurant.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisineType,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTime} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
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
          ],
        ),
      ),
    );
  }
  
  // Build menu item card
  Widget _buildMenuItemCard(MenuItem menuItem) {
    return GestureDetector(
      onTap: () => _onMenuItemTap(menuItem),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Menu item image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                menuItem.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.restaurant, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            // Menu item details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${menuItem.restaurantName} • ${menuItem.restaurantLocation}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menuItem.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${menuItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                menuItem.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
    );
  }
  
  // Build popular search chips
  Widget _buildPopularSearchChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _popularSearches.map((search) {
        return GestureDetector(
          onTap: () {
            _searchController.text = search;
            _performSearch(search);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              search,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // Build recent searches
  Widget _buildRecentlyViewed() {
    if (_recentlyViewed.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently Viewed',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentlyViewed.length,
            itemBuilder: (context, index) {
              final restaurant = _recentlyViewed[index];
              
              return GestureDetector(
                onTap: () => _onRestaurantTap(restaurant),
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          restaurant.imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.restaurant, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              restaurant.cuisineType,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                title: const Text('Search'),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: SearchField(
                        controller: _searchController,
                        hintText: 'Search for restaurants, dishes, or cuisines',
                        onSearch: _performSearch,
                        onClear: _clearSearch,
                        showClearButton: _isSearching,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: _showFilterModal,
                  ),
                ],
              ),
            ];
          },
          body: Column(
            children: [
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Restaurants'),
                  Tab(text: 'Dishes'),
                ],
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Restaurants tab
                    _buildRestaurantsTab(),
                    
                    // Dishes tab
                    _buildDishesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build restaurants tab
  Widget _buildRestaurantsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    if (_isSearching && _filteredRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants found for "$_searchQuery"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or filters',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    if (!_isSearching) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPopularSearchChips(),
            const SizedBox(height: 24),
            
            // Recently viewed restaurants
            _buildRecentlyViewed(),
            if (_recentlyViewed.isNotEmpty) const SizedBox(height: 24),
            
            // Popular restaurants
            const Text(
              'Popular Restaurants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _allRestaurants.length > 5 ? 5 : _allRestaurants.length,
              (index) => _buildRestaurantCard(_allRestaurants[index]),
            ),
          ],
        ),
      );
    }
    
    // Search results
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRestaurants.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredRestaurants.length} results found',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _showFilterModal,
                  child: Row(
                    children: [
                      const Icon(Icons.tune, size: 16),
                      const SizedBox(width: 4),
                      const Text('Filter'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        final restaurant = _filteredRestaurants[index - 1];
        return _buildRestaurantCard(restaurant);
      },
    );
  }
  
  // Build dishes tab
  Widget _buildDishesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    if (_isSearching && _filteredMenuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No dishes found for "$_searchQuery"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or filters',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    if (!_isSearching) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Dishes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _allMenuItems.length > 5 ? 5 : _allMenuItems.length,
              (index) => _buildMenuItemCard(_allMenuItems[index]),
            ),
          ],
        ),
      );
    }
    
    // Search results
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMenuItems.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${_filteredMenuItems.length} results found',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        
        final menuItem = _filteredMenuItems[index - 1];
        return _buildMenuItemCard(menuItem);
      },
    );
  }
} 