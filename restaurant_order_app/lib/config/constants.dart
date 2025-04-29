class AppConstants {
  // API URLs
  static const String apiBaseUrl = 'https://api.restaurantorderapp.com';
  
  // Image asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  
  // Default values
  static const int defaultSearchLimit = 20;
  static const int debounceTimeInMilliseconds = 300;
  
  // Screen transition durations
  static const int pageTransitionDuration = 300; // milliseconds
  
  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String recentSearchesKey = 'recent_searches';
  static const String favoritesKey = 'favorites';
} 