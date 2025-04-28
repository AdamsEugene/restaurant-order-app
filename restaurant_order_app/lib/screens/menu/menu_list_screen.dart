import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/restaurant/restaurant_bloc.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../widgets/cards/menu_item_card.dart';
import '../../widgets/loading/loading_indicator.dart';

class MenuListScreen extends StatefulWidget {
  final String restaurantId;

  const MenuListScreen({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final Set<String> _uniqueCategories = <String>{};
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
  }

  void _loadRestaurantDetails() {
    context.read<RestaurantBloc>().add(
          LoadRestaurantDetails(widget.restaurantId),
        );
  }

  void _addToCart(MenuItem menuItem) {
    context.read<CartBloc>().add(
          AddToCart(
            menuItem: menuItem,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RestaurantBloc, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantDetailLoaded) {
            // Extract unique categories from the menu
            _uniqueCategories.clear();
            for (var item in state.restaurant.menu) {
              _uniqueCategories.add(item.category);
            }
            
            // Set the first category as selected if none is selected
            if (_selectedCategory == null && _uniqueCategories.isNotEmpty) {
              setState(() {
                _selectedCategory = _uniqueCategories.first;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is RestaurantLoading) {
            return const Center(
              child: LoadingIndicator(),
            );
          } else if (state is RestaurantDetailLoaded) {
            final restaurant = state.restaurant;
            
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // Restaurant header
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        context.go('/restaurants');
                      },
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          restaurant.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: restaurant.isFavorite
                              ? AppTheme.errorColor
                              : Colors.white,
                        ),
                        onPressed: () {
                          context.read<RestaurantBloc>().add(
                                ToggleFavorite(
                                  restaurantId: restaurant.id,
                                ),
                              );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // Share restaurant
                        },
                      ),
                    ],
                  ),
                  
                  // Restaurant info
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  restaurant.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.rating.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            restaurant.cuisineType,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            restaurant.description,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Menu Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Category tabs
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: _uniqueCategories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[800],
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  // Category header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _selectedCategory ?? 'Menu',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: restaurant.menu
                    .where((item) => item.category == _selectedCategory)
                    .length,
                itemBuilder: (context, index) {
                  final filteredItems = restaurant.menu
                      .where((item) => item.category == _selectedCategory)
                      .toList();
                  final menuItem = filteredItems[index];
                  
                  return MenuItemCard(
                    id: menuItem.id,
                    name: menuItem.name,
                    description: menuItem.description,
                    imageUrl: menuItem.imageUrl,
                    price: menuItem.price,
                    isVegetarian: menuItem.isVegetarian,
                    isSpicy: menuItem.name.toLowerCase().contains('spicy'),
                    onTap: () {
                      context.go('/menu-item/${menuItem.id}');
                    },
                    onAddToCart: () {
                      _addToCart(menuItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${menuItem.name} added to cart'),
                          action: SnackBarAction(
                            label: 'VIEW CART',
                            onPressed: () {
                              context.go('/cart');
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
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
                    onPressed: _loadRestaurantDetails,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.cart.items.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () {
                context.go('/cart');
              },
              label: Text('${state.cart.totalQuantity} items'),
              icon: const Icon(Icons.shopping_cart),
              backgroundColor: AppTheme.primaryColor,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
} 