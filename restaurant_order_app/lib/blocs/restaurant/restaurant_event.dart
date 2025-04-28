import 'package:equatable/equatable.dart';

part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends RestaurantEvent {
  const LoadRestaurants();
}

class ApplyFilters extends RestaurantEvent {
  final List<String> categories;
  
  const ApplyFilters({
    this.categories = const [],
  });
  
  @override
  List<Object?> get props => [categories];
}

class LoadRestaurantDetails extends RestaurantEvent {
  final String restaurantId;

  const LoadRestaurantDetails(this.restaurantId);

  @override
  List<Object> get props => [restaurantId];
}

class ToggleFavorite extends RestaurantEvent {
  final String restaurantId;
  
  const ToggleFavorite({
    required this.restaurantId,
  });
  
  @override
  List<Object?> get props => [restaurantId];
}

class ResetFilters extends RestaurantEvent {
  const ResetFilters();
}

class SearchRestaurants extends RestaurantEvent {
  final String query;

  const SearchRestaurants(this.query);

  @override
  List<Object> get props => [query];
} 