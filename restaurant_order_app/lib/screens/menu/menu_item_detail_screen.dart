import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/restaurant/restaurant_bloc.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../models/cart_item.dart';
import '../../widgets/app_bars/custom_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/loading/loading_indicator.dart';

class MenuItemDetailScreen extends StatefulWidget {
  final String itemId;

  const MenuItemDetailScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  int _quantity = 1;
  final List<CustomizationSelection> _selectedCustomizations = [];
  final TextEditingController _notesController = TextEditingController();
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }
  
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }
  
  void _addToCart(MenuItem menuItem, String restaurantId, String restaurantName) {
    context.read<CartBloc>().add(
          AddItemToCart(
            menuItem: menuItem,
            quantity: _quantity,
            customizations: _selectedCustomizations,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
          ),
        );
    
    // Navigate back to the restaurant menu list
    context.go('/restaurants/$restaurantId');
    
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
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantDetailLoaded) {
            final restaurant = state.restaurant;
            final menuItem = restaurant.menu.firstWhere(
              (item) => item.id == widget.itemId,
              orElse: () => MenuItem(
                id: '',
                name: 'Not Found',
                description: 'Item not found',
                price: 0,
                imageUrl: '',
                category: '',
                allergens: [],
              ),
            );
            
            if (menuItem.id.isEmpty) {
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
                    const Text(
                      'Menu item not found',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }
            
            return CustomScrollView(
              slivers: [
                // App bar with image
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      // Navigate back to the restaurant menu list
                      context.go('/restaurants/${restaurant.id}');
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'menu-item-${menuItem.id}',
                      child: Image.network(
                        menuItem.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                // Menu item details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                menuItem.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '\$${menuItem.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        // Badges
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (menuItem.isVegetarian)
                              _buildBadge(
                                icon: Icons.eco,
                                label: 'Vegetarian',
                                color: AppTheme.successColor,
                              ),
                            if (menuItem.isVegan)
                              _buildBadge(
                                icon: Icons.spa,
                                label: 'Vegan',
                                color: Colors.green,
                              ),
                            if (menuItem.isGlutenFree)
                              _buildBadge(
                                icon: Icons.new_releases,
                                label: 'Gluten Free',
                                color: Colors.blue,
                              ),
                            if (menuItem.isPopular)
                              _buildBadge(
                                icon: Icons.favorite,
                                label: 'Popular',
                                color: AppTheme.errorColor,
                              ),
                          ],
                        ),
                        
                        // Description
                        const SizedBox(height: 16),
                        Text(
                          menuItem.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        
                        // Allergens
                        if (menuItem.allergens.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Allergens',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: menuItem.allergens.map((allergen) {
                              return Chip(
                                label: Text(allergen),
                                backgroundColor: Colors.red.shade100,
                              );
                            }).toList(),
                          ),
                        ],
                        
                        // Notes
                        const SizedBox(height: 24),
                        const Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            hintText: 'Any special requests?',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          maxLines: 2,
                        ),
                        
                        // Quantity selector
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: _decrementQuantity,
                            ),
                            Container(
                              width: 50,
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: _incrementQuantity,
                            ),
                          ],
                        ),
                        
                        // Total and add to cart
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${(menuItem.price * _quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        PrimaryButton(
                          text: 'Add to Cart',
                          onPressed: () {
                            _addToCart(menuItem, restaurant.id, restaurant.name);
                          },
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: LoadingIndicator(),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Icon(icon),
      ),
    );
  }
} 