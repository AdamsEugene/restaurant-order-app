import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/menu_item.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final existingItemIndex = currentState.items.indexWhere(
        (item) => item.menuItem.id == event.menuItem.id,
      );

      if (existingItemIndex >= 0) {
        // Item already exists, increment quantity
        final updatedItems = [...currentState.items];
        updatedItems[existingItemIndex] = CartItem(
          menuItem: currentState.items[existingItemIndex].menuItem,
          quantity: currentState.items[existingItemIndex].quantity + 1,
        );

        emit(CartLoaded(items: updatedItems));
      } else {
        // Add new item
        emit(CartLoaded(
          items: [...currentState.items, CartItem(menuItem: event.menuItem, quantity: 1)],
        ));
      }
    } else {
      // Cart is empty, add first item
      emit(CartLoaded(
        items: [CartItem(menuItem: event.menuItem, quantity: 1)],
      ));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final updatedItems = currentState.items
          .where((item) => item.menuItem.id != event.menuItemId)
          .toList();

      if (updatedItems.isEmpty) {
        emit(CartInitial());
      } else {
        emit(CartLoaded(items: updatedItems));
      }
    }
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final existingItemIndex = currentState.items.indexWhere(
        (item) => item.menuItem.id == event.menuItemId,
      );

      if (existingItemIndex >= 0) {
        final updatedItems = [...currentState.items];
        
        if (event.quantity <= 0) {
          // Remove item if quantity <= 0
          updatedItems.removeAt(existingItemIndex);
        } else {
          // Update quantity
          updatedItems[existingItemIndex] = CartItem(
            menuItem: currentState.items[existingItemIndex].menuItem,
            quantity: event.quantity,
          );
        }

        if (updatedItems.isEmpty) {
          emit(CartInitial());
        } else {
          emit(CartLoaded(items: updatedItems));
        }
      }
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartInitial());
  }
} 