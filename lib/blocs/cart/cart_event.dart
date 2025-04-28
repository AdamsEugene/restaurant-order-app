part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final MenuItem menuItem;

  const AddToCart({
    required this.menuItem,
  });

  @override
  List<Object?> get props => [menuItem];
}

class RemoveFromCart extends CartEvent {
  final String menuItemId;

  const RemoveFromCart({
    required this.menuItemId,
  });

  @override
  List<Object?> get props => [menuItemId];
}

class UpdateQuantity extends CartEvent {
  final String menuItemId;
  final int quantity;

  const UpdateQuantity({
    required this.menuItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [menuItemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
} 