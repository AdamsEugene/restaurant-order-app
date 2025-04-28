import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isPopular;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final List<String> allergens;
  final double? calories;
  final List<String> availableAddons;
  final String restaurantId;
  final String restaurantName;
  final double? discountPrice;
  final List<String> additives;
  final bool isAvailable;
  
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isPopular = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.allergens = const [],
    this.calories,
    this.availableAddons = const [],
    this.restaurantId = '',
    this.restaurantName = '',
    this.discountPrice,
    this.additives = const [],
    this.isAvailable = true,
  });
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    category,
    isPopular,
    isVegetarian,
    isVegan,
    isGlutenFree,
    allergens,
    calories,
    availableAddons,
    restaurantId,
    restaurantName,
    discountPrice,
    additives,
    isAvailable,
  ];
  
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isPopular,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    List<String>? allergens,
    double? calories,
    List<String>? availableAddons,
    String? restaurantId,
    String? restaurantName,
    double? discountPrice,
    List<String>? additives,
    bool? isAvailable,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isPopular: isPopular ?? this.isPopular,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      allergens: allergens ?? this.allergens,
      calories: calories ?? this.calories,
      availableAddons: availableAddons ?? this.availableAddons,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      discountPrice: discountPrice ?? this.discountPrice,
      additives: additives ?? this.additives,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isPopular': isPopular,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'allergens': allergens,
      'calories': calories,
      'availableAddons': availableAddons,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'discountPrice': discountPrice,
      'additives': additives,
      'isAvailable': isAvailable,
    };
  }
  
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isPopular: json['isPopular'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      allergens: List<String>.from(json['allergens']),
      calories: json['calories']?.toDouble(),
      availableAddons: List<String>.from(json['availableAddons']),
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      discountPrice: json['discountPrice']?.toDouble(),
      additives: json.containsKey('additives') && json['additives'] != null
          ? List<String>.from(json['additives'])
          : [],
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}

class CustomizationGroup extends Equatable {
  final String id;
  final String name;
  final bool isRequired;
  final int minSelections;
  final int maxSelections;
  final List<CustomizationOption> options;

  const CustomizationGroup({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.minSelections,
    required this.maxSelections,
    required this.options,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        isRequired,
        minSelections,
        maxSelections,
        options,
      ];

  static CustomizationGroup fromJson(Map<String, dynamic> json) {
    return CustomizationGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      isRequired: json['is_required'] as bool,
      minSelections: json['min_selections'] as int,
      maxSelections: json['max_selections'] as int,
      options: (json['options'] as List<dynamic>)
          .map((e) => CustomizationOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_required': isRequired,
      'min_selections': minSelections,
      'max_selections': maxSelections,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}

class CustomizationOption extends Equatable {
  final String id;
  final String name;
  final double priceAdjustment;

  const CustomizationOption({
    required this.id,
    required this.name,
    required this.priceAdjustment,
  });

  @override
  List<Object?> get props => [id, name, priceAdjustment];

  static CustomizationOption fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      id: json['id'] as String,
      name: json['name'] as String,
      priceAdjustment: (json['price_adjustment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_adjustment': priceAdjustment,
    };
  }
} 