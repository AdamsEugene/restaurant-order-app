import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final String restaurantName;
  final String restaurantId;
  final String restaurantLocation;
  final List<String> categories;
  final bool isVegetarian;
  final bool isSpicy;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.restaurantName,
    required this.restaurantId,
    required this.restaurantLocation,
    this.categories = const [],
    this.isVegetarian = false,
    this.isSpicy = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    rating,
    restaurantName,
    restaurantId,
    restaurantLocation,
    categories,
    isVegetarian,
    isSpicy,
  ];
  
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    double? rating,
    String? restaurantName,
    String? restaurantId,
    String? restaurantLocation,
    List<String>? categories,
    bool? isVegetarian,
    bool? isSpicy,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      categories: categories ?? this.categories,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isSpicy: isSpicy ?? this.isSpicy,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'restaurantName': restaurantName,
      'restaurantId': restaurantId,
      'restaurantLocation': restaurantLocation,
      'categories': categories,
      'isVegetarian': isVegetarian,
      'isSpicy': isSpicy,
    };
  }
  
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      restaurantName: json['restaurantName'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantLocation: json['restaurantLocation'] as String,
      categories: List<String>.from(json['categories'] ?? []),
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isSpicy: json['isSpicy'] as bool? ?? false,
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