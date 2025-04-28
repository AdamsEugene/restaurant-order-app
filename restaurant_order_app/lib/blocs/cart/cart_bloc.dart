import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../../models/cart_item.dart';
import '../../models/menu_item.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartInitial()) {
    on<CartStarted>(_onCartStarted);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ApplyPromoCode>(_onApplyPromoCode);
    on<RemovePromoCode>(_onRemovePromoCode);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onCartStarted(
    CartStarted event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      // Load cart from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');
      
      if (cartJson != null) {
        final cartData = jsonDecode(cartJson) as Map<String, dynamic>;
        final cart = Cart.fromJson(cartData);
        emit(CartLoaded(cart: cart));
      } else {
        emit(const CartLoaded(cart: Cart()));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> _onAddItemToCart(
    AddItemToCart event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      try {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;
        
        // Check if we're adding an item from a different restaurant
        if (currentCart.isNotEmpty && 
            currentCart.restaurantId != null && 
            currentCart.restaurantId != event.restaurantId) {
          emit(CartItemsFromDifferentRestaurant(
            cart: currentCart,
            newRestaurantId: event.restaurantId,
            newRestaurantName: event.restaurantName,
            menuItem: event.menuItem,
            quantity: event.quantity,
            customizations: event.customizations,
            notes: event.notes,
          ));
          return;
        }
        
        // Generate unique ID for cart item
        final uuid = const Uuid();
        final itemId = uuid.v4();
        
        // Create cart item with restaurantId and restaurantName from the event
        final modifiedMenuItem = event.menuItem.copyWith(
          restaurantId: event.restaurantId,
          restaurantName: event.restaurantName,
        );
        
        final cartItem = CartItem(
          id: itemId,
          menuItem: modifiedMenuItem,
          quantity: event.quantity,
          customizations: event.customizations,
          specialInstructions: event.notes,
        );
        
        // Check if item already exists in cart (with same customizations and notes)
        final existingItemIndex = currentCart.items.indexWhere((item) => 
          item.menuItem.id == cartItem.menuItem.id && 
          _areCustomizationsEqual(item.customizations, cartItem.customizations) &&
          item.specialInstructions == cartItem.specialInstructions
        );
        
        if (existingItemIndex >= 0) {
          // Update quantity of existing item
          final existingItem = currentCart.items[existingItemIndex];
          final updatedItems = List<CartItem>.from(currentCart.items);
          updatedItems[existingItemIndex] = existingItem.copyWith(
            quantity: existingItem.quantity + cartItem.quantity,
          );
          
          final updatedCart = currentCart.copyWith(items: updatedItems);
          await _saveCart(updatedCart);
          emit(CartLoaded(cart: updatedCart));
        } else {
          // Add new item to cart
          final updatedItems = List<CartItem>.from(currentCart.items)..add(cartItem);
          final updatedCart = currentCart.copyWith(items: updatedItems);
          await _saveCart(updatedCart);
          emit(CartItemAdded(cart: updatedCart, addedItem: cartItem));
        }
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCart event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      try {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;
        
        final updatedItems = List<CartItem>.from(currentCart.items)
          ..removeWhere((item) => item.id == event.itemId);
        
        final updatedCart = currentCart.copyWith(items: updatedItems);
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      try {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;
        
        final itemIndex = currentCart.items.indexWhere((item) => item.id == event.itemId);
        
        if (itemIndex >= 0) {
          final updatedItems = List<CartItem>.from(currentCart.items);
          
          if (event.quantity > 0) {
            // Update quantity
            updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
              quantity: event.quantity,
            );
          } else {
            // Remove item if quantity is 0
            updatedItems.removeAt(itemIndex);
          }
          
          final updatedCart = currentCart.copyWith(items: updatedItems);
          await _saveCart(updatedCart);
          emit(CartLoaded(cart: updatedCart));
        }
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onApplyPromoCode(
    ApplyPromoCode event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      try {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;
        
        // In a real app, you would validate the promo code with an API call
        // Here we're just simulating a 10% discount for any promo code
        if (event.promoCode.isNotEmpty) {
          final discount = currentCart.subtotal * 0.1; // 10% discount
          final updatedCart = currentCart.copyWith(
            appliedPromoCode: event.promoCode,
            discountAmount: discount,
          );
          await _saveCart(updatedCart);
          emit(CartLoaded(cart: updatedCart));
        }
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onRemovePromoCode(
    RemovePromoCode event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      try {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;
        
        final updatedCart = currentCart.copyWith(
          appliedPromoCode: null,
          discountAmount: null,
        );
        
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      try {
        final currentState = state as CartLoaded;
        final emptyCart = currentState.cart.copyWith(
          items: [],
          appliedPromoCode: null,
          discountAmount: null,
        );
        
        await _saveCart(emptyCart);
        emit(CartLoaded(cart: emptyCart));
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  // Helper method to save cart to shared preferences
  Future<void> _saveCart(Cart cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cart.toJson());
    await prefs.setString('cart', cartJson);
  }

  // Helper method to compare customizations
  bool _areCustomizationsEqual(
    List<CustomizationSelection> list1,
    List<CustomizationSelection> list2,
  ) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      final customization1 = list1[i];
      final customization2 = list2.firstWhere(
        (c) => c.optionId == customization1.optionId,
        orElse: () => CustomizationSelection(
          groupId: '',
          groupName: '',
          optionId: '',
          optionName: '',
          priceAdjustment: 0,
        ),
      );
      
      if (customization2.optionId.isEmpty) return false;
    }
    
    return true;
  }
} 