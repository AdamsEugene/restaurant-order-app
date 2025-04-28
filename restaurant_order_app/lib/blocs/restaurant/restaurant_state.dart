import 'package:equatable/equatable.dart';
import '../../models/restaurant.dart';

part of 'restaurant_bloc.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();
  
  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  final List<String> appliedFilters;
  
  const RestaurantLoaded({
    required this.restaurants,
    this.appliedFilters = const [],
  });
  
  @override
  List<Object?> get props => [restaurants, appliedFilters];
}

class RestaurantDetailLoaded extends RestaurantState {
  final Restaurant restaurant;
  
  const RestaurantDetailLoaded(this.restaurant);
  
  @override
  List<Object> get props => [restaurant];
}

class RestaurantError extends RestaurantState {
  final String message;
  
  const RestaurantError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
} 