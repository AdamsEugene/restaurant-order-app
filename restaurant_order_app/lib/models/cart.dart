import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'cart_item.dart';
import 'menu_item.dart';

class Cart extends Equatable {
  final List<CartItem> items;
  final double? deliveryFee;
  final double? serviceFee;
  final double taxRate;
  final String? promoCode;
  final double? promoDiscount;
  
  const Cart({
    this.items = const [],
    this.deliveryFee,
    this.serviceFee,
    this.taxRate = 0.0825, // Default tax rate of 8.25%
    this.promoCode,
    this.promoDiscount,
  });

  @override
  List<Object?> get props => [
    items,
    deliveryFee,
    serviceFee,
    taxRate,
    promoCode,
    promoDiscount,
  ];
  
  // Calculate the subtotal price (sum of all items)
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }
  
  // Calculate the tax amount
  double get tax {
    return subtotal * taxRate;
  }
  
  // Calculate the total price
  double get total {
    double total = subtotal + tax;
    
    if (deliveryFee != null) {
      total += deliveryFee!;
    }
    
    if (serviceFee != null) {
      total += serviceFee!;
    }
    
    if (promoDiscount != null) {
      total -= promoDiscount!;
      if (total < 0) total = 0; // Ensure total is not negative
    }
    
    return total;
  }
  
  // Get the total number of items
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  // Check if the cart is empty
  bool get isEmpty => items.isEmpty;
  
  // Check if the cart is not empty
  bool get isNotEmpty => items.isNotEmpty;
  
  // Create a copy of the cart with updated fields
  Cart copyWith({
    List<CartItem>? items,
    double? deliveryFee,
    double? serviceFee,
    double? taxRate,
    String? promoCode,
    double? promoDiscount,
  }) {
    return Cart(
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      taxRate: taxRate ?? this.taxRate,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
    );
  }
  
  // Add an item to the cart
  Cart addItem(MenuItem menuItem, {
    int quantity = 1, 
    List<CustomizationSelection>? customizations,
    String? specialInstructions,
  }) {
    // Check if this item already exists in the cart with the same customizations
    final existingItemIndex = _findItemIndex(menuItem, customizations);
    
    if (existingItemIndex != -1) {
      // Item exists, update quantity
      final updatedItems = List<CartItem>.from(items);
      final existingItem = updatedItems[existingItemIndex];
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      
      return copyWith(items: updatedItems);
    } else {
      // Item does not exist, add new item
      final newItem = CartItem(
        id: const Uuid().v4(),
        menuItem: menuItem,
        quantity: quantity,
        customizations: customizations ?? const [],
        specialInstructions: specialInstructions,
      );
      
      return copyWith(items: [...items, newItem]);
    }
  }
  
  // Remove an item from the cart
  Cart removeItem(String itemId) {
    return copyWith(
      items: items.where((item) => item.id != itemId).toList(),
    );
  }
  
  // Update item quantity
  Cart updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      return removeItem(itemId);
    }
    
    final updatedItems = List<CartItem>.from(items);
    final itemIndex = updatedItems.indexWhere((item) => item.id == itemId);
    
    if (itemIndex != -1) {
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(quantity: quantity);
    }
    
    return copyWith(items: updatedItems);
  }
  
  // Apply a promo code
  Cart applyPromoCode(String code, double discount) {
    return copyWith(
      promoCode: code,
      promoDiscount: discount,
    );
  }
  
  // Remove a promo code
  Cart removePromoCode() {
    return copyWith(
      promoCode: null,
      promoDiscount: null,
    );
  }
  
  // Clear the cart
  Cart clear() {
    return const Cart();
  }
  
  // Find an item in the cart with the same menuItem and customizations
  int _findItemIndex(MenuItem menuItem, List<CustomizationSelection>? customizations) {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      if (item.menuItem.id == menuItem.id) {
        // Check if customizations match
        if (_compareCustomizations(item.customizations, customizations ?? [])) {
          return i;
        }
      }
    }
    
    return -1;
  }
  
  // Compare customizations to see if they are the same
  bool _compareCustomizations(
    List<CustomizationSelection> a, 
    List<CustomizationSelection> b,
  ) {
    if (a.length != b.length) return false;
    
    for (final customA in a) {
      bool found = false;
      
      for (final customB in b) {
        if (customA.groupId == customB.groupId && 
            customA.optionId == customB.optionId) {
          found = true;
          break;
        }
      }
      
      if (!found) return false;
    }
    
    return true;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'taxRate': taxRate,
      'promoCode': promoCode,
      'promoDiscount': promoDiscount,
    };
  }
  
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      deliveryFee: json['deliveryFee']?.toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      taxRate: json['taxRate']?.toDouble() ?? 0.0825,
      promoCode: json['promoCode'],
      promoDiscount: json['promoDiscount']?.toDouble(),
    );
  }
} 