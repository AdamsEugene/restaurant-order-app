import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../services/api/restaurant_api_service.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController _notesController = TextEditingController();
  bool isLoading = true;
  MenuItem? menuItem;
  Restaurant? restaurant;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadMenuItemDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMenuItemDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = RestaurantApiService(httpClient: http.Client());
      
      // Load all restaurants to find the menu item
      final restaurants = await apiService.fetchRestaurants();
      
      // Find the menu item in any restaurant
      for (var r in restaurants) {
        for (var item in r.menu) {
          if (item.id == widget.itemId) {
            if (mounted) {
              setState(() {
                menuItem = item;
                restaurant = r;
                isLoading = false;
              });
            }
            return;
          }
        }
      }
      
      // If we get here, the item wasn't found
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Menu item not found';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
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
  
  void _addToCart() {
    // In a real app, this would add the item to the cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menuItem?.name} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            context.go('/cart');
          },
        ),
      ),
    );
    
    // Navigate back
    if (restaurant != null) {
      context.go('/restaurants/${restaurant!.id}');
    } else {
      context.go('/home');
    }
  }
  
  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
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
                        'Error: $errorMessage',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : menuItem == null
                  ? Center(
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
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.go('/home'),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        // App bar with image
                        SliverAppBar(
                          expandedHeight: 250,
                          pinned: true,
                          leading: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
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
                              child: const Icon(Icons.arrow_back, color: Colors.black),
                            ),
                            onPressed: () {
                              if (restaurant != null) {
                                context.go('/restaurants/${restaurant!.id}');
                              } else {
                                context.go('/home');
                              }
                            },
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Image.network(
                              menuItem!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.restaurant, size: 64, color: Colors.white),
                                  ),
                                );
                              },
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
                                        menuItem!.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${menuItem!.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Restaurant name
                                if (restaurant != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'From ${restaurant!.name}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                                
                                // Description
                                const SizedBox(height: 16),
                                Text(
                                  menuItem!.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                
                                // Quantity selector
                                const SizedBox(height: 32),
                                const Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: _decrementQuantity,
                                            color: _quantity > 1 ? Colors.black : Colors.grey,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              '$_quantity',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: _incrementQuantity,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
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
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'E.g. No onions, extra spicy, etc.',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                
                                // Add to cart button
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _addToCart,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Add to Cart - \$${(menuItem!.price * _quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
} 