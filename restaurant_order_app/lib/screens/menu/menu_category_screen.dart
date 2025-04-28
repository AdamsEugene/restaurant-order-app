import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/restaurant/restaurant_bloc.dart';
import '../../config/theme.dart';
import '../../widgets/cards/menu_item_card.dart';
import '../../widgets/loading/loading_indicator.dart';

class MenuCategoryScreen extends StatefulWidget {
  final String restaurantId;
  final String categoryId;

  const MenuCategoryScreen({
    Key? key,
    required this.restaurantId,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<MenuCategoryScreen> createState() => _MenuCategoryScreenState();
}

class _MenuCategoryScreenState extends State<MenuCategoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId),
        centerTitle: true,
      ),
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantLoading) {
            return const Center(
              child: LoadingIndicator(),
            );
          } else if (state is RestaurantDetailLoaded) {
            final restaurant = state.restaurant;
            final categoryItems = restaurant.menu
                .where((item) => item.category == widget.categoryId)
                .toList();

            if (categoryItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_food,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items found in this category',
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
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              itemCount: categoryItems.length,
              itemBuilder: (context, index) {
                final menuItem = categoryItems[index];
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
                    context.read<CartBloc>().add(
                          AddItemToCart(
                            menuItem: menuItem,
                            restaurantId: widget.restaurantId,
                            restaurantName: restaurant.name,
                          ),
                        );
                    
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