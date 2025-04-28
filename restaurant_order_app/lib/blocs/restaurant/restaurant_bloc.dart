import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/restaurant.dart';
import '../../repositories/restaurant/restaurant_repository.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantBloc({required RestaurantRepository restaurantRepository})
      : _restaurantRepository = restaurantRepository,
        super(RestaurantInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<ApplyFilters>(_onApplyFilters);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    try {
      final restaurants = await _restaurantRepository.fetchRestaurants();
      emit(RestaurantLoaded(restaurants: restaurants));
    } catch (e) {
      emit(RestaurantError(message: e.toString()));
    }
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      if (state is RestaurantLoaded) {
        final currentState = state as RestaurantLoaded;
        
        // If we had a more complex filter, we'd apply it here
        // For now, we'll just reload the restaurants
        final restaurants = await _restaurantRepository.fetchRestaurants();
        
        emit(RestaurantLoaded(
          restaurants: restaurants,
          appliedFilters: event.categories,
        ));
      }
    } catch (e) {
      // Don't emit error state here, just keep previous state
      print('Error applying filters: ${e.toString()}');
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      if (state is RestaurantLoaded) {
        final currentState = state as RestaurantLoaded;
        final updatedRestaurants = await Future.wait(
          currentState.restaurants.map((restaurant) async {
            if (restaurant.id == event.restaurantId) {
              return await _restaurantRepository.toggleFavorite(restaurant);
            }
            return restaurant;
          }),
        );
        
        emit(RestaurantLoaded(
          restaurants: updatedRestaurants,
          appliedFilters: currentState.appliedFilters,
        ));
      }
    } catch (e) {
      // Don't emit error state here, just print to console
      print('Error toggling favorite: ${e.toString()}');
    }
  }
} 