import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/restaurant/restaurant_bloc.dart';
import '../../config/theme.dart';
import '../../widgets/app_bars/custom_app_bar.dart';
import '../../widgets/cards/restaurant_card.dart';
import '../../widgets/loading/loading_indicator.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadRestaurants() {
    context.read<RestaurantBloc>().add(const LoadRestaurants());
  }
  
  void _onSearch(String query) {
    if (query.isNotEmpty) {
      context.read<RestaurantBloc>().add(SearchRestaurants(query));
    } else {
      _loadRestaurants();
    }
  }
  
  void _toggleFavorite(String restaurantId, bool isFavorite) {
    context.read<RestaurantBloc>().add(
          ToggleFavorite(
            restaurantId: restaurantId,
            isFavorite: !isFavorite,
          ),
        );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Go back to home screen
            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _onSearch,
            ),
          ),
          
          // Restaurant list
          Expanded(
            child: BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                if (state is RestaurantLoading) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                } else if (state is RestaurantLoaded) {
                  final restaurants = state.filteredRestaurants;
                  
                  if (restaurants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No restaurants found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return RestaurantCard(
                        id: restaurant.id,
                        name: restaurant.name,
                        imageUrl: restaurant.imageUrl,
                        rating: restaurant.rating,
                        cuisine: restaurant.cuisineType,
                        deliveryTime: '${restaurant.distance.toStringAsFixed(1)} miles away',
                        onTap: () {
                          context.go('/restaurants/${restaurant.id}');
                        },
                        isFavorite: restaurant.isFavorite,
                        onFavoriteToggle: () {
                          _toggleFavorite(
                            restaurant.id,
                            restaurant.isFavorite,
                          );
                        },
                      );
                    },
                  );
                } else if (state is RestaurantError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.errorColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadRestaurants,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
} 