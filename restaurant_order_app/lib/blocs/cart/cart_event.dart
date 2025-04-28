part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class AddItemToCart extends CartEvent {
  final MenuItem menuItem;
  final int quantity;
  final List<CustomizationSelection> customizations;
  final String? notes;
  final String restaurantId;
  final String restaurantName;

  const AddItemToCart({
    required this.menuItem,
    this.quantity = 1,
    this.customizations = const [],
    this.notes,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  List<Object?> get props => [
        menuItem,
        quantity,
        customizations,
        notes,
        restaurantId,
        restaurantName,
      ];
}

class RemoveItemFromCart extends CartEvent {
  final String itemId;

  const RemoveItemFromCart({
    required this.itemId,
  });

  @override
  List<Object?> get props => [itemId];
}

class UpdateItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateItemQuantity({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemId, quantity];
}

class ApplyPromoCode extends CartEvent {
  final String promoCode;

  const ApplyPromoCode({
    required this.promoCode,
  });

  @override
  List<Object?> get props => [promoCode];
}

class RemovePromoCode extends CartEvent {
  const RemovePromoCode();
}

class ClearCart extends CartEvent {
  const ClearCart();
} 