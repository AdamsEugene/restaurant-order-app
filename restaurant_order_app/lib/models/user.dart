import 'package:equatable/equatable.dart';

import 'order.dart';

enum UserRole {
  customer,
  restaurantOwner,
  admin,
}

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final List<DeliveryAddress> savedAddresses;
  final List<PaymentMethod> savedPaymentMethods;
  final List<String> favoriteRestaurantIds;
  final UserRole role;
  final DateTime? createdAt;
  
  const User({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.profileImageUrl,
    this.savedAddresses = const [],
    this.savedPaymentMethods = const [],
    this.favoriteRestaurantIds = const [],
    this.role = UserRole.customer,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phoneNumber,
    profileImageUrl,
    savedAddresses,
    savedPaymentMethods,
    favoriteRestaurantIds,
    role,
    createdAt,
  ];
  
  // Check if a restaurant is in favorites
  bool isFavorite(String restaurantId) {
    return favoriteRestaurantIds.contains(restaurantId);
  }
  
  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    List<DeliveryAddress>? savedAddresses,
    List<PaymentMethod>? savedPaymentMethods,
    List<String>? favoriteRestaurantIds,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      savedPaymentMethods: savedPaymentMethods ?? this.savedPaymentMethods,
      favoriteRestaurantIds: favoriteRestaurantIds ?? this.favoriteRestaurantIds,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Add a delivery address
  User addAddress(DeliveryAddress address) {
    final updatedAddresses = List<DeliveryAddress>.from(savedAddresses);
    updatedAddresses.add(address);
    return copyWith(savedAddresses: updatedAddresses);
  }
  
  // Remove a delivery address
  User removeAddress(DeliveryAddress address) {
    final updatedAddresses = List<DeliveryAddress>.from(savedAddresses)
      ..removeWhere((a) => a == address);
    return copyWith(savedAddresses: updatedAddresses);
  }
  
  // Add a payment method
  User addPaymentMethod(PaymentMethod paymentMethod) {
    final updatedPaymentMethods = List<PaymentMethod>.from(savedPaymentMethods);
    updatedPaymentMethods.add(paymentMethod);
    return copyWith(savedPaymentMethods: updatedPaymentMethods);
  }
  
  // Remove a payment method
  User removePaymentMethod(String paymentMethodId) {
    final updatedPaymentMethods = List<PaymentMethod>.from(savedPaymentMethods)
      ..removeWhere((p) => p.id == paymentMethodId);
    return copyWith(savedPaymentMethods: updatedPaymentMethods);
  }
  
  // Toggle favorite restaurant
  User toggleFavoriteRestaurant(String restaurantId) {
    final updatedFavorites = List<String>.from(favoriteRestaurantIds);
    
    if (updatedFavorites.contains(restaurantId)) {
      updatedFavorites.remove(restaurantId);
    } else {
      updatedFavorites.add(restaurantId);
    }
    
    return copyWith(favoriteRestaurantIds: updatedFavorites);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'savedAddresses': savedAddresses.map((a) => a.toJson()).toList(),
      'savedPaymentMethods': savedPaymentMethods.map((p) => p.toJson()).toList(),
      'favoriteRestaurantIds': favoriteRestaurantIds,
      'role': role.toString(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      savedAddresses: json['savedAddresses'] != null
          ? (json['savedAddresses'] as List<dynamic>)
              .map((a) => DeliveryAddress.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      savedPaymentMethods: json['savedPaymentMethods'] != null
          ? (json['savedPaymentMethods'] as List<dynamic>)
              .map((p) => PaymentMethod.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
      favoriteRestaurantIds: json['favoriteRestaurantIds'] != null
          ? List<String>.from(json['favoriteRestaurantIds'])
          : [],
      role: json['role'] != null ? _parseUserRole(json['role']) : UserRole.customer,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
  
  static UserRole _parseUserRole(String role) {
    switch (role) {
      case 'UserRole.restaurantOwner':
        return UserRole.restaurantOwner;
      case 'UserRole.admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

class Address extends Equatable {
  final String id;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        label,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        latitude,
        longitude,
        isDefault,
      ];

  Address copyWith({
    String? id,
    String? label,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get formattedAddress {
    final buffer = StringBuffer();
    buffer.write(addressLine1);
    
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      buffer.write(', $addressLine2');
    }
    
    buffer.write(', $city, $state $postalCode');
    buffer.write(', $country');
    
    return buffer.toString();
  }

  static Address fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      label: json['label'] as String,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }
}

class PaymentMethod extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? lastFourDigits;
  final String? expiryDate;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.lastFourDigits,
    this.expiryDate,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        lastFourDigits,
        expiryDate,
        isDefault,
      ];

  PaymentMethod copyWith({
    String? id,
    String? name,
    String? type,
    String? lastFourDigits,
    String? expiryDate,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static PaymentMethod fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      lastFourDigits: json['last_four_digits'] as String?,
      expiryDate: json['expiry_date'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'last_four_digits': lastFourDigits,
      'expiry_date': expiryDate,
      'is_default': isDefault,
    };
  }
} 