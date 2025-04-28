import 'dart:async';

class AuthRepository {
  // For now, we'll use a simple mock implementation
  // In a real app, this would handle API requests, local storage, etc.
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Very simple validation for demo
    if (email == 'user@example.com' && password == 'password') {
      return {
        'success': true,
        'token': 'mock_token_12345',
        'user': {
          'id': '1',
          'name': 'Demo User',
          'email': email,
        }
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would create a new user in the backend
    return {
      'success': true,
      'token': 'mock_token_12345',
      'user': {
        'id': '1',
        'name': name,
        'email': email,
      }
    };
  }
  
  Future<bool> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would clear tokens and user data
    return true;
  }
  
  Future<Map<String, dynamic>> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would send a password reset link
    return {
      'success': true,
      'message': 'Password reset link sent to your email',
    };
  }
  
  Future<Map<String, dynamic>> getUserProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would fetch the user profile from backend
    return {
      'success': true,
      'user': {
        'id': '1',
        'name': 'Demo User',
        'email': 'user@example.com',
        'phone': '123-456-7890',
        'address': '123 Main St, New York, NY',
      }
    };
  }
} 