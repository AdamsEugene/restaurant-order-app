import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../services/api/restaurant_api_service.dart';
import '../../services/api/menu_api_service.dart';
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
  
  // Customization options
  // Common options
  String? _selectedSoup;
  bool _withOkra = false;
  String? _selectedMeat;
  int _numberOfBalls = 2;
  int _numberOfPieces = 3;
  String? _selectedRiceType;
  String? _selectedSideDish;
  bool _withGinger = false;
  bool _withGarlic = false;
  bool _spicyLevel = false;
  
  // Custom prices for add-ons
  final Map<String, double> _meatPrices = {
    'Beef': 2.0,
    'Chicken': 2.5,
    'Fish (Tilapia)': 3.0,
    'Goat Meat': 3.5,
    'No Meat (Vegetarian)': 0.0
  };
  
  final Map<String, double> _soupPrices = {
    'Light Soup': 0.0,
    'Palm Nut Soup': 1.0,
    'Groundnut Soup': 1.0,
    'Pepper Sauce (Shito)': 0.5,
    'Okro Stew': 1.5,
    'Abunuabunu (Green Soup)': 2.0
  };
  
  // Extras pricing
  final double _okraPrice = 1.0;
  final double _extraBallPrice = 1.0;
  final double _spicyLevelPrice = 0.5;
  final double _eggPrice = 1.0;
  final double _extraPlantainPrice = 1.5;
  final double _groundnutsPrice = 0.5;
  
  // Define available options
  final List<String> _soupOptions = [
    'Light Soup', 
    'Palm Nut Soup', 
    'Groundnut Soup', 
    'Pepper Sauce (Shito)',
    'Okro Stew'
  ];
  
  final List<String> _meatOptions = [
    'Beef', 
    'Chicken', 
    'Fish (Tilapia)', 
    'Goat Meat',
    'No Meat (Vegetarian)'
  ];
  
  final List<String> _riceTypes = [
    'Plain White Rice',
    'Basmati Rice',
    'Brown Rice',
    'Local Rice'
  ];
  
  final List<String> _sideDishes = [
    'Garden Egg Stew',
    'Mixed Vegetables',
    'Coleslaw',
    'Fried Plantain',
    'Green Salad',
    'None'
  ];
  
  final List<String> _futuSoups = [
    'Light Soup',
    'Palm Nut Soup',
    'Groundnut Soup',
    'Abunuabunu (Green Soup)'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadMenuItemDetails();
    // Set default selections
    _selectedSoup = _soupOptions[0];
    _selectedMeat = _meatOptions[0];
    _selectedRiceType = _riceTypes[0];
    _selectedSideDish = _sideDishes[0];
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
      final restaurantApiService = RestaurantApiService(httpClient: http.Client());
      final menuApiService = MenuApiService(httpClient: http.Client());
      
      // First try to get the menu item directly from MenuApiService
      try {
        final item = await menuApiService.getMenuItemDetails(widget.itemId);
        if (mounted) {
          setState(() {
            menuItem = item;
            // Find the corresponding restaurant
            restaurantApiService.fetchRestaurants().then((restaurants) {
              final r = restaurants.firstWhere(
                (r) => r.id == item.restaurantId,
                orElse: () => Restaurant(
                  id: '',
                  name: 'Unknown Restaurant',
                  imageUrl: '',
                  rating: 0.0,
                  cuisineType: '',
                  distance: 0.0,
                  isFavorite: false,
                  address: '',
                  description: '',
                ),
              );
              if (mounted) {
                setState(() {
                  restaurant = r;
                });
              }
            });
            isLoading = false;
          });
        }
        return;
      } catch (e) {
        // If we couldn't find it in MenuApiService, continue with the fallback approach
        print('Could not find menu item in MenuApiService: $e');
      }
      
      // Fallback: Load all restaurants to find the menu item
      final restaurants = await restaurantApiService.fetchRestaurants();
      
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
  
  Widget _buildCustomizationSection() {
    if (menuItem == null) {
      return const SizedBox.shrink();
    }
    
    final String itemNameLower = menuItem!.name.toLowerCase();
    
    // Banku customization
    if (itemNameLower.contains('banku')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Customize Your Banku',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Number of Banku Balls
          Text(
            'Number of Banku Balls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildNumberSelector(_numberOfBalls, (value) {
            setState(() {
              _numberOfBalls = value;
            });
          }),
          
          // Soup Selection
          const SizedBox(height: 16),
          Text(
            'Select Soup/Stew',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_soupOptions, _selectedSoup, (newValue) {
            setState(() {
              _selectedSoup = newValue;
            });
          }),
          
          // Okra Toggle
          const SizedBox(height: 16),
          _buildToggle('Add Okra', _withOkra, (value) {
            setState(() {
              _withOkra = value;
            });
          }),
          
          // Meat Selection
          const SizedBox(height: 16),
          Text(
            'Select Meat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_meatOptions, _selectedMeat, (newValue) {
            setState(() {
              _selectedMeat = newValue;
            });
          }),
          
          const SizedBox(height: 8),
        ],
      );
    }
    
    // Fufu customization
    else if (itemNameLower.contains('fufu')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Customize Your Fufu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Soup Selection
          Text(
            'Select Soup',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_futuSoups, _selectedSoup, (newValue) {
            setState(() {
              _selectedSoup = newValue;
            });
          }),
          
          // Meat Selection
          const SizedBox(height: 16),
          Text(
            'Select Meat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_meatOptions, _selectedMeat, (newValue) {
            setState(() {
              _selectedMeat = newValue;
            });
          }),
          
          const SizedBox(height: 8),
        ],
      );
    }
    
    // Jollof Rice customization
    else if (itemNameLower.contains('jollof')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Customize Your Jollof Rice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Rice Type Selection
          Text(
            'Select Rice Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_riceTypes, _selectedRiceType, (newValue) {
            setState(() {
              _selectedRiceType = newValue;
            });
          }),
          
          // Protein Selection
          const SizedBox(height: 16),
          Text(
            'Select Protein',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_meatOptions, _selectedMeat, (newValue) {
            setState(() {
              _selectedMeat = newValue;
            });
          }),
          
          // Side Dish Selection
          const SizedBox(height: 16),
          Text(
            'Select Side Dish',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_sideDishes, _selectedSideDish, (newValue) {
            setState(() {
              _selectedSideDish = newValue;
            });
          }),
          
          // Spicy Level
          const SizedBox(height: 16),
          _buildToggle('Extra Spicy', _spicyLevel, (value) {
            setState(() {
              _spicyLevel = value;
            });
          }),
          
          const SizedBox(height: 8),
        ],
      );
    }
    
    // Waakye customization
    else if (itemNameLower.contains('waakye')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Customize Your Waakye',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Protein Selection
          Text(
            'Select Protein',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_meatOptions, _selectedMeat, (newValue) {
            setState(() {
              _selectedMeat = newValue;
            });
          }),
          
          // With Gari
          const SizedBox(height: 16),
          _buildToggle('Add Gari', _withGinger, (value) {
            setState(() {
              _withGinger = value;
            });
          }),
          
          // With Spaghetti
          const SizedBox(height: 16),
          _buildToggle('Add Spaghetti', _withGarlic, (value) {
            setState(() {
              _withGarlic = value;
            });
          }),
          
          // With Egg
          const SizedBox(height: 16),
          _buildToggle('Add Boiled Egg', _spicyLevel, (value) {
            setState(() {
              _spicyLevel = value;
            });
          }),
          
          const SizedBox(height: 8),
        ],
      );
    }
    
    // Kenkey customization
    else if (itemNameLower.contains('kenkey')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Customize Your Kenkey',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Pieces Selection
          Text(
            'Number of Kenkey Pieces',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildNumberSelector(_numberOfPieces, (value) {
            setState(() {
              _numberOfPieces = value;
            });
          }),
          
          // Protein Selection
          const SizedBox(height: 16),
          Text(
            'Select Fish Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(['Tilapia', 'Salmon', 'Tuna', 'Mackerel', 'No Fish'], _selectedMeat, (newValue) {
            setState(() {
              _selectedMeat = newValue;
            });
          }),
          
          // With Shito
          const SizedBox(height: 16),
          _buildToggle('Add Shito (Pepper Sauce)', _withGinger, (value) {
            setState(() {
              _withGinger = value;
            });
          }),
          
          const SizedBox(height: 8),
        ],
      );
    }
    
    // TZ or Omotuo customization
    else if (itemNameLower.contains('tuo zaafi') || itemNameLower.contains('tz') || itemNameLower.contains('omotuo')) {
      final String titleText = itemNameLower.contains('omotuo') ? 'Customize Your Omotuo' : 'Customize Your Tuo Zaafi';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Soup Selection
          Text(
            'Select Soup',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            itemNameLower.contains('omotuo') 
                ? ['Groundnut Soup', 'Palm Nut Soup', 'Light Soup'] 
                : ['Ayoyo Soup', 'Okro Soup', 'Mixed Green Soup'],
            _selectedSoup, 
            (newValue) {
              setState(() {
                _selectedSoup = newValue;
              });
            }
          ),
          
          // Meat Selection
          const SizedBox(height: 16),
          Text(
            'Select Meat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(_meatOptions, _selectedMeat, (newValue) {
            setState(() {
              _selectedMeat = newValue;
            });
          }),
          
          const SizedBox(height: 8),
        ],
      );
    }
    
    // Red Red or Kelewele customization
    else if (itemNameLower.contains('red red') || itemNameLower.contains('kelewele')) {
      final String titleText = itemNameLower.contains('red red') ? 'Customize Your Red Red' : 'Customize Your Kelewele';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (itemNameLower.contains('red red')) ...[
            // With Fried Egg
            _buildToggle('Add Fried Egg', _withGinger, (value) {
              setState(() {
                _withGinger = value;
              });
            }),
            
            // With Extra Plantain
            const SizedBox(height: 16),
            _buildToggle('Extra Plantain', _withGarlic, (value) {
              setState(() {
                _withGarlic = value;
              });
            }),
          ] else ...[
            // Spice Level
            _buildToggle('Extra Spicy', _spicyLevel, (value) {
              setState(() {
                _spicyLevel = value;
              });
            }),
            
            // With Groundnut (Peanuts)
            const SizedBox(height: 16),
            _buildToggle('Add Groundnuts', _withGinger, (value) {
              setState(() {
                _withGinger = value;
              });
            }),
          ],
          
          const SizedBox(height: 8),
        ],
      );
    }
    
    // Default - return empty widget for other dishes that don't have specific customizations
    return const SizedBox.shrink();
  }
  
  // Helper widget for number selectors
  Widget _buildNumberSelector(int current, Function(int) onChanged) {
    return Row(
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
                onPressed: () {
                  if (current > 1) {
                    onChanged(current - 1);
                  }
                },
                color: current > 1 ? Colors.black : Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$current',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  onChanged(current + 1);
                },
                color: Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Helper widget for dropdowns
  Widget _buildDropdown(List<String> options, String? selected, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  
  // Helper widget for toggles
  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
  
  double _calculateTotalPrice() {
    if (menuItem == null) return 0.0;
    
    // Start with base price
    double totalPrice = menuItem!.price;
    
    final String itemNameLower = menuItem!.name.toLowerCase();
    
    // Add customization costs
    if (itemNameLower.contains('banku')) {
      // Add cost for additional balls beyond the default 2
      totalPrice += (_numberOfBalls - 2) * _extraBallPrice;
      
      // Add soup price
      if (_selectedSoup != null) {
        totalPrice += _soupPrices[_selectedSoup] ?? 0.0;
      }
      
      // Add okra price if selected
      if (_withOkra) {
        totalPrice += _okraPrice;
      }
      
      // Add meat price
      if (_selectedMeat != null) {
        totalPrice += _meatPrices[_selectedMeat] ?? 0.0;
      }
    }
    else if (itemNameLower.contains('fufu')) {
      // Add soup price
      if (_selectedSoup != null) {
        totalPrice += _soupPrices[_selectedSoup] ?? 0.0;
      }
      
      // Add meat price
      if (_selectedMeat != null) {
        totalPrice += _meatPrices[_selectedMeat] ?? 0.0;
      }
    }
    else if (itemNameLower.contains('jollof')) {
      // Add meat price
      if (_selectedMeat != null) {
        totalPrice += _meatPrices[_selectedMeat] ?? 0.0;
      }
      
      // Add spicy price
      if (_spicyLevel) {
        totalPrice += _spicyLevelPrice;
      }
    }
    else if (itemNameLower.contains('waakye')) {
      // Add meat price
      if (_selectedMeat != null) {
        totalPrice += _meatPrices[_selectedMeat] ?? 0.0;
      }
      
      // Add egg price if spicy level is used for boiled egg
      if (_spicyLevel) {
        totalPrice += _eggPrice;
      }
    }
    else if (itemNameLower.contains('kenkey')) {
      // Add cost for additional pieces beyond the default 3
      totalPrice += (_numberOfPieces - 3) * 0.75;
      
      // Add meat price
      if (_selectedMeat != null) {
        totalPrice += _meatPrices[_selectedMeat] ?? 0.0;
      }
    }
    else if (itemNameLower.contains('tuo zaafi') || itemNameLower.contains('tz') || itemNameLower.contains('omotuo')) {
      // Add soup price
      if (_selectedSoup != null) {
        totalPrice += _soupPrices[_selectedSoup] ?? 0.0;
      }
      
      // Add meat price
      if (_selectedMeat != null) {
        totalPrice += _meatPrices[_selectedMeat] ?? 0.0;
      }
    }
    else if (itemNameLower.contains('red red')) {
      // Add egg price
      if (_withGinger) {  // using withGinger for fried egg
        totalPrice += _eggPrice;
      }
      
      // Add extra plantain price
      if (_withGarlic) {  // using withGarlic for extra plantain
        totalPrice += _extraPlantainPrice;
      }
    }
    else if (itemNameLower.contains('kelewele')) {
      // Add spicy price
      if (_spicyLevel) {
        totalPrice += _spicyLevelPrice;
      }
      
      // Add groundnuts price
      if (_withGinger) {  // using withGinger for groundnuts
        totalPrice += _groundnutsPrice;
      }
    }
    
    // Multiply by quantity for non-customizable items
    if (!isCustomizableDish()) {
      totalPrice *= _quantity;
    }
    
    return totalPrice;
  }
  
  bool isCustomizableDish() {
    if (menuItem == null) return false;
    
    final String itemNameLower = menuItem!.name.toLowerCase();
    return itemNameLower.contains('banku') || 
           itemNameLower.contains('fufu') || 
           itemNameLower.contains('waakye') || 
           itemNameLower.contains('tuo zaafi') || 
           itemNameLower.contains('tz') || 
           itemNameLower.contains('omotuo');
  }
  
  void _addToCart() {
    // Format customizations for display
    String customizationSummary = '';
    
    if (menuItem != null) {
      final String itemNameLower = menuItem!.name.toLowerCase();
      
      if (itemNameLower.contains('banku')) {
        customizationSummary = '\n• $_numberOfBalls Banku Balls'
            '\n• $_selectedSoup'
            '${_withOkra ? '\n• With Okra' : '\n• Without Okra'}'
            '\n• $_selectedMeat';
      }
      else if (itemNameLower.contains('fufu')) {
        customizationSummary = '\n• $_selectedSoup'
            '\n• $_selectedMeat';
      }
      else if (itemNameLower.contains('jollof')) {
        customizationSummary = '\n• $_selectedRiceType'
            '\n• $_selectedMeat'
            '\n• Side: $_selectedSideDish'
            '${_spicyLevel ? '\n• Extra Spicy' : '\n• Regular Spice'}';
      }
      else if (itemNameLower.contains('waakye')) {
        customizationSummary = '\n• $_selectedMeat'
            '${_withGinger ? '\n• With Gari' : '\n• Without Gari'}'
            '${_withGarlic ? '\n• With Spaghetti' : '\n• Without Spaghetti'}'
            '${_spicyLevel ? '\n• With Boiled Egg' : '\n• Without Boiled Egg'}';
      }
      else if (itemNameLower.contains('kenkey')) {
        customizationSummary = '\n• $_numberOfPieces Pieces'
            '\n• $_selectedMeat'
            '${_withGinger ? '\n• With Shito' : '\n• Without Shito'}';
      }
      else if (itemNameLower.contains('tuo zaafi') || itemNameLower.contains('tz') || itemNameLower.contains('omotuo')) {
        customizationSummary = '\n• $_selectedSoup'
            '\n• $_selectedMeat';
      }
      else if (itemNameLower.contains('red red')) {
        customizationSummary = '${_withGinger ? '\n• With Fried Egg' : '\n• Without Fried Egg'}'
            '${_withGarlic ? '\n• Extra Plantain' : '\n• Regular Plantain'}';
      }
      else if (itemNameLower.contains('kelewele')) {
        customizationSummary = '${_spicyLevel ? '\n• Extra Spicy' : '\n• Regular Spice'}'
            '${_withGinger ? '\n• With Groundnuts' : '\n• Without Groundnuts'}';
      }
    }
    
    // Calculate the final price with customizations
    final double finalPrice = _calculateTotalPrice();
    
    // Navigate to order confirmation screen
    context.go('/order-confirmation', extra: {
      'menuItem': menuItem,
      'quantity': isCustomizableDish() ? 1 : _quantity,
      'customizations': customizationSummary,
      'notes': _notesController.text,
      'restaurant': restaurant,
      'finalPrice': finalPrice,
    });
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
                                
                                // Quantity selector - only show for non-customizable items
                                if (!isCustomizableDish()) ...[
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
                                ],
                                
                                // Banku Customization section
                                _buildCustomizationSection(),
                                
                                // Special Instructions
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
                                
                                // Price Summary
                                const SizedBox(height: 24),
                                const Text(
                                  'Price Summary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Base Price:',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '\$${menuItem!.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!isCustomizableDish() && _quantity > 1) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Quantity:',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'x $_quantity',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (_calculateTotalPrice() > menuItem!.price || 
                                         (!isCustomizableDish() && _quantity > 1)) ...[
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
                                              '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: menuItem != null
        ? FloatingActionButton.extended(
            onPressed: _addToCart,
            icon: const Icon(Icons.restaurant),
            label: Text('Order Now (\$${_calculateTotalPrice().toStringAsFixed(2)})'),
            backgroundColor: Theme.of(context).primaryColor,
          )
        : null,
    );
  }
} 