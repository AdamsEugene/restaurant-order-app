class AppConfig {
  // Use a mock API URL for development
  static const String apiBaseUrl = 'http://mockapi.io/api/v1';
  
  // Add other configuration values as needed
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds
} 