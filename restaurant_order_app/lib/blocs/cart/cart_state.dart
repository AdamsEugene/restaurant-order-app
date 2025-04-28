part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded({
    required this.cart,
  });

  @override
  List<Object?> get props => [cart];
}

class CartItemAdded extends CartLoaded {
  final CartItem addedItem;

  const CartItemAdded({
    required super.cart,
    required this.addedItem,
  });

  @override
  List<Object?> get props => [cart, addedItem];
}

class CartItemsFromDifferentRestaurant extends CartState {
  final Cart cart;
  final String newRestaurantId;
  final String newRestaurantName;
  final MenuItem menuItem;
  final int quantity;
  final List<CustomizationSelection> customizations;
  final String? notes;

  const CartItemsFromDifferentRestaurant({
    required this.cart,
    required this.newRestaurantId,
    required this.newRestaurantName,
    required this.menuItem,
    required this.quantity,
    required this.customizations,
    this.notes,
  });

  @override
  List<Object?> get props => [
        cart,
        newRestaurantId,
        newRestaurantName,
        menuItem,
        quantity,
        customizations,
        notes,
      ];
}

class CartError extends CartState {
  final String message;

  const CartError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
} 