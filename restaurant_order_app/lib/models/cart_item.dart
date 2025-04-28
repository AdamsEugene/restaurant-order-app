import 'package:equatable/equatable.dart';
import 'menu_item.dart';

class CartItem extends Equatable {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final List<CustomizationSelection> customizations;
  final String? specialInstructions;
  
  const CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.customizations = const [],
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
    id,
    menuItem,
    quantity,
    customizations,
    specialInstructions,
  ];
  
  // Calculate the total price for this cart item including customizations
  double get totalPrice {
    double customizationPrice = 0.0;
    for (var customization in customizations) {
      customizationPrice += customization.priceAdjustment;
    }
    return (menuItem.price + customizationPrice) * quantity;
  }
  
  // Create a copy of the cart item with updated fields
  CartItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    List<CustomizationSelection>? customizations,
    String? specialInstructions,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
  
  // Increment the quantity of this cart item
  CartItem incrementQuantity() {
    return copyWith(quantity: quantity + 1);
  }
  
  // Decrement the quantity of this cart item
  CartItem decrementQuantity() {
    return copyWith(quantity: quantity - 1);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'customizations': customizations.map((c) => c.toJson()).toList(),
      'specialInstructions': specialInstructions,
    };
  }
  
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'],
      customizations: (json['customizations'] as List<dynamic>)
          .map((c) => CustomizationSelection.fromJson(c as Map<String, dynamic>))
          .toList(),
      specialInstructions: json['specialInstructions'],
    );
  }
}

class CustomizationSelection extends Equatable {
  final String groupId;
  final String groupName;
  final String optionId;
  final String optionName;
  final double priceAdjustment;
  
  const CustomizationSelection({
    required this.groupId,
    required this.groupName,
    required this.optionId,
    required this.optionName,
    required this.priceAdjustment,
  });
  
  @override
  List<Object?> get props => [
    groupId,
    groupName,
    optionId,
    optionName,
    priceAdjustment,
  ];
  
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'optionId': optionId,
      'optionName': optionName,
      'priceAdjustment': priceAdjustment,
    };
  }
  
  factory CustomizationSelection.fromJson(Map<String, dynamic> json) {
    return CustomizationSelection(
      groupId: json['groupId'],
      groupName: json['groupName'],
      optionId: json['optionId'],
      optionName: json['optionName'],
      priceAdjustment: json['priceAdjustment'].toDouble(),
    );
  }
  
  factory CustomizationSelection.fromGroupAndOption(
    CustomizationGroup group,
    CustomizationOption option,
  ) {
    return CustomizationSelection(
      groupId: group.id,
      groupName: group.name,
      optionId: option.id,
      optionName: option.name,
      priceAdjustment: option.priceAdjustment,
    );
  }
}

class CartItemCustomization extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final String optionId;
  final String optionName;
  final double priceAdjustment;

  const CartItemCustomization({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.optionId,
    required this.optionName,
    required this.priceAdjustment,
  });

  @override
  List<Object> get props => [
        id,
        groupId,
        groupName,
        optionId,
        optionName,
        priceAdjustment,
      ];

  static CartItemCustomization fromJson(Map<String, dynamic> json) {
    return CartItemCustomization(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
      optionId: json['option_id'] as String,
      optionName: json['option_name'] as String,
      priceAdjustment: (json['price_adjustment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'group_name': groupName,
      'option_id': optionId,
      'option_name': optionName,
      'price_adjustment': priceAdjustment,
    };
  }
}

class Cart extends Equatable {
  final List<CartItem> items;
  final String? appliedPromoCode;
  final double? discountAmount;

  const Cart({
    this.items = const [],
    this.appliedPromoCode,
    this.discountAmount,
  });

  double get subtotal {
    double total = 0;
    for (var item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  double get discount {
    return discountAmount ?? 0;
  }

  double get total {
    return subtotal - discount;
  }

  int get totalQuantity {
    int quantity = 0;
    for (var item in items) {
      quantity += item.quantity;
    }
    return quantity;
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  String? get restaurantId {
    if (items.isEmpty) return null;
    return items.first.menuItem.restaurantId;
  }

  String? get restaurantName {
    if (items.isEmpty) return null;
    return items.first.menuItem.restaurantName;
  }

  @override
  List<Object?> get props => [items, appliedPromoCode, discountAmount];

  Cart copyWith({
    List<CartItem>? items,
    String? appliedPromoCode,
    double? discountAmount,
  }) {
    return Cart(
      items: items ?? this.items,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  static Cart fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      appliedPromoCode: json['applied_promo_code'] as String?,
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'applied_promo_code': appliedPromoCode,
      'discount_amount': discountAmount,
    };
  }
} 