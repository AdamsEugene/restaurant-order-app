import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/password_reset_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/restaurant_details/restaurant_details_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/menu_item_detail/menu_item_detail_screen.dart';
import '../widgets/layout/main_layout.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Non-authenticated routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/restaurants/:id',
        builder: (context, state) {
          final restaurantId = state.pathParameters['id']!;
          return RestaurantDetailsScreen(restaurantId: restaurantId);
        },
      ),
      
      // Menu item detail route
      GoRoute(
        path: '/menu/:id',
        builder: (context, state) {
          final menuItemId = state.pathParameters['id']!;
          // We'll create a simple menu item detail screen
          return MenuItemDetailScreen(itemId: menuItemId);
        },
      ),
      
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Figure out which tab is active based on the current location
          int currentIndex;
          final location = state.fullPath ?? '';
          
          if (location.startsWith('/home')) {
            currentIndex = 0;
          } else if (location.startsWith('/search')) {
            currentIndex = 1;
          } else if (location.startsWith('/cart')) {
            currentIndex = 2;
          } else if (location.startsWith('/profile')) {
            currentIndex = 3;
          } else {
            currentIndex = 0; // Default to home
          }
          
          return MainLayout(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          // Home Tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          // Search Tab
          GoRoute(
            path: '/search',
            builder: (context, state) => const Center(
              child: Text('Search - Coming Soon'),
            ),
          ),
          // Cart Tab
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          // Profile Tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
} 