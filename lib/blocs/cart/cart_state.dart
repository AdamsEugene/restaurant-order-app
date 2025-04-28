part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  
  const CartLoaded({
    required this.items,
  });
  
  double get totalPrice => items.fold(
    0,
    (total, item) => total + (item.menuItem.price * item.quantity),
  );
  
  int get totalItems => items.fold(
    0,
    (total, item) => total + item.quantity,
  );
  
  @override
  List<Object?> get props => [items];
}

class CartError extends CartState {
  final String message;
  
  const CartError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
}

class CartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;
  
  const CartItem({
    required this.menuItem,
    required this.quantity,
  });
  
  double get totalPrice => menuItem.price * quantity;
  
  @override
  List<Object?> get props => [menuItem, quantity];
} 