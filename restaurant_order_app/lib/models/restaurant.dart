import 'package:equatable/equatable.dart';
import 'menu_item.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String cuisineType;
  final double distance;
  final bool isFavorite;
  final String address;
  final String description;
  final List<MenuItem> menu;
  final double deliveryFee;
  final int deliveryTime;
  
  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.cuisineType,
    required this.distance,
    required this.isFavorite,
    required this.address,
    required this.description,
    this.menu = const [],
    this.deliveryFee = 2.99,
    this.deliveryTime = 30,
  });
  
  @override
  List<Object?> get props => [
    id, 
    name, 
    imageUrl, 
    rating, 
    cuisineType, 
    distance, 
    isFavorite, 
    address, 
    description, 
    menu,
    deliveryFee,
    deliveryTime,
  ];
  
  Restaurant copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? rating,
    String? cuisineType,
    double? distance,
    bool? isFavorite,
    String? address,
    String? description,
    List<MenuItem>? menu,
    double? deliveryFee,
    int? deliveryTime,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      cuisineType: cuisineType ?? this.cuisineType,
      distance: distance ?? this.distance,
      isFavorite: isFavorite ?? this.isFavorite,
      address: address ?? this.address,
      description: description ?? this.description,
      menu: menu ?? this.menu,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }
  
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      cuisineType: json['cuisineType'] as String,
      distance: (json['distance'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool,
      address: json['address'] as String,
      description: json['description'] as String,
      menu: json.containsKey('menu') && json['menu'] != null
          ? (json['menu'] as List).map((item) => MenuItem.fromJson(item)).toList()
          : [],
      deliveryFee: json.containsKey('deliveryFee') ? (json['deliveryFee'] as num).toDouble() : 2.99,
      deliveryTime: json.containsKey('deliveryTime') ? (json['deliveryTime'] as num).toInt() : 30,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'cuisineType': cuisineType,
      'distance': distance,
      'isFavorite': isFavorite,
      'address': address,
      'description': description,
      'menu': menu.map((item) => item.toJson()).toList(),
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
    };
  }

  // Get top-rated items from the menu
  List<MenuItem> get topRatedItems {
    final sortedMenu = List<MenuItem>.from(menu);
    sortedMenu.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedMenu.take(3).toList();
  }

  // Get vegetarian items from the menu
  List<MenuItem> get vegetarianItems {
    return menu.where((item) => item.isVegetarian).toList();
  }

  // Get spicy items from the menu
  List<MenuItem> get spicyItems {
    return menu.where((item) => item.isSpicy).toList();
  }

  // Get menu items by category
  List<MenuItem> getItemsByCategory(String category) {
    return menu.where((item) => item.categories.contains(category)).toList();
  }

  // Get unique menu categories
  List<String> get menuCategories {
    final categories = <String>{};
    for (var item in menu) {
      categories.addAll(item.categories);
    }
    final categoryList = categories.toList();
    categoryList.sort();
    return categoryList;
  }
  
  // Check if delivery is free
  bool get isFreeDelivery => deliveryFee == 0;
} 