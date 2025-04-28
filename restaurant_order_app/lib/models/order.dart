import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'cart_item.dart';

enum OrderStatus {
  pending,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled
}

class Order extends Equatable {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double? deliveryFee;
  final double? serviceFee;
  final double? tip;
  final double total;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final OrderStatus status;
  final String? promoCode;
  final double? promoDiscount;
  final DeliveryAddress? deliveryAddress;
  final String? deliveryInstructions;
  final PaymentMethod paymentMethod;
  
  const Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.tax,
    this.deliveryFee,
    this.serviceFee,
    this.tip,
    required this.total,
    required this.createdAt,
    this.estimatedDeliveryTime,
    required this.status,
    this.promoCode,
    this.promoDiscount,
    this.deliveryAddress,
    this.deliveryInstructions,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    restaurantName,
    items,
    subtotal,
    tax,
    deliveryFee,
    serviceFee,
    tip,
    total,
    createdAt,
    estimatedDeliveryTime,
    status,
    promoCode,
    promoDiscount,
    deliveryAddress,
    deliveryInstructions,
    paymentMethod,
  ];
  
  // Create a copy of the order with updated fields
  Order copyWith({
    String? id,
    String? restaurantId,
    String? restaurantName,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? serviceFee,
    double? tip,
    double? total,
    DateTime? createdAt,
    DateTime? estimatedDeliveryTime,
    OrderStatus? status,
    String? promoCode,
    double? promoDiscount,
    DeliveryAddress? deliveryAddress,
    String? deliveryInstructions,
    PaymentMethod? paymentMethod,
  }) {
    return Order(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      tip: tip ?? this.tip,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      status: status ?? this.status,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
  
  // Get the total number of items
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  // Helper factory to create an order from a cart
  factory Order.fromCart({
    required String restaurantId,
    required String restaurantName,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    double? deliveryFee,
    double? serviceFee,
    double? tip,
    required double total,
    String? promoCode,
    double? promoDiscount,
    DeliveryAddress? deliveryAddress,
    String? deliveryInstructions,
    required PaymentMethod paymentMethod,
  }) {
    return Order(
      id: const Uuid().v4(),
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      tip: tip,
      total: total,
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      promoCode: promoCode,
      promoDiscount: promoDiscount,
      deliveryAddress: deliveryAddress,
      deliveryInstructions: deliveryInstructions,
      paymentMethod: paymentMethod,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'tip': tip,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'status': status.toString().split('.').last,
      'promoCode': promoCode,
      'promoDiscount': promoDiscount,
      'deliveryAddress': deliveryAddress?.toJson(),
      'deliveryInstructions': deliveryInstructions,
      'paymentMethod': paymentMethod.toJson(),
    };
  }
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      deliveryFee: json['deliveryFee']?.toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      tip: json['tip']?.toDouble(),
      total: json['total'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'])
          : null,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      promoCode: json['promoCode'],
      promoDiscount: json['promoDiscount']?.toDouble(),
      deliveryAddress: json['deliveryAddress'] != null
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      deliveryInstructions: json['deliveryInstructions'],
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod']),
    );
  }
}

class DeliveryAddress extends Equatable {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String? instructions;
  final double? latitude;
  final double? longitude;
  
  const DeliveryAddress({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.instructions,
    this.latitude,
    this.longitude,
  });
  
  @override
  List<Object?> get props => [
    addressLine1,
    addressLine2,
    city,
    state,
    zipCode,
    instructions,
    latitude,
    longitude,
  ];
  
  DeliveryAddress copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? instructions,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryAddress(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      instructions: instructions ?? this.instructions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'instructions': instructions,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  
  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      instructions: json['instructions'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
  
  String get fullAddress {
    final buffer = StringBuffer(addressLine1);
    
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      buffer.write(', ${addressLine2!}');
    }
    
    buffer.write(', $city, $state $zipCode');
    
    return buffer.toString();
  }
}

class PaymentMethod extends Equatable {
  final String id;
  final String type; // 'credit_card', 'paypal', 'apple_pay', etc.
  final String? cardBrand; // 'visa', 'mastercard', etc.
  final String? last4;
  final String? expMonth;
  final String? expYear;
  
  const PaymentMethod({
    required this.id,
    required this.type,
    this.cardBrand,
    this.last4,
    this.expMonth,
    this.expYear,
  });
  
  @override
  List<Object?> get props => [
    id,
    type,
    cardBrand,
    last4,
    expMonth,
    expYear,
  ];
  
  PaymentMethod copyWith({
    String? id,
    String? type,
    String? cardBrand,
    String? last4,
    String? expMonth,
    String? expYear,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      cardBrand: cardBrand ?? this.cardBrand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'cardBrand': cardBrand,
      'last4': last4,
      'expMonth': expMonth,
      'expYear': expYear,
    };
  }
  
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      cardBrand: json['cardBrand'],
      last4: json['last4'],
      expMonth: json['expMonth'],
      expYear: json['expYear'],
    );
  }
  
  String get displayName {
    if (type == 'credit_card' && cardBrand != null && last4 != null) {
      return '${cardBrand!.toUpperCase()} •••• $last4';
    } else if (type == 'paypal') {
      return 'PayPal';
    } else if (type == 'apple_pay') {
      return 'Apple Pay';
    } else if (type == 'google_pay') {
      return 'Google Pay';
    } else {
      return type;
    }
  }
} 