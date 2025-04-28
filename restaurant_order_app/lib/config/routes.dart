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
import '../screens/order_confirmation/order_confirmation_screen.dart';
import '../screens/payment/payment_methods_screen.dart';
import '../screens/receipt/receipt_screen.dart';
import '../screens/order/order_tracking_screen.dart';
import '../screens/order/submit_receipt_code_screen.dart';
import '../screens/order/order_complete_screen.dart';
import '../screens/order/track_order_screen.dart';
import '../screens/promotions/special_offers_screen.dart';
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
        path: '/special-offers',
        builder: (context, state) => const SpecialOffersScreen(),
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
      
      // Order confirmation route
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) {
          final orderDetails = state.extra as Map<String, dynamic>;
          return OrderConfirmationScreen(orderDetails: orderDetails);
        },
      ),
      
      // Payment methods route
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) {
          final orderDetails = state.extra as Map<String, dynamic>;
          return PaymentMethodsScreen(orderDetails: orderDetails);
        },
      ),
      
      // Receipt route
      GoRoute(
        path: '/receipt/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final orderDetails = state.extra as Map<String, dynamic>;
          final receiptCode = orderDetails['receiptCode'] as String? ?? 'RECEIPT123';
          return ReceiptScreen(
            orderDetails: orderDetails,
            orderId: orderId,
            receiptCode: receiptCode,
          );
        },
      ),
      
      // Order tracking route
      GoRoute(
        path: '/order-tracking/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final orderDetails = state.extra as Map<String, dynamic>? ?? {};
          return TrackOrderScreen(
            orderId: orderId,
            orderDetails: orderDetails,
          );
        },
      ),
      
      // Submit receipt code route
      GoRoute(
        path: '/submit-receipt-code/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final orderDetails = state.extra as Map<String, dynamic>;
          return SubmitReceiptCodeScreen(
            orderId: orderId,
            orderDetails: orderDetails,
          );
        },
      ),
      
      // Order complete route
      GoRoute(
        path: '/order-complete/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final orderDetails = state.extra as Map<String, dynamic>;
          return OrderCompleteScreen(
            orderId: orderId,
            orderDetails: orderDetails,
          );
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
            builder: (context, state) {
              // Get any extra data passed to the route (like promotion info)
              final extra = state.extra as Map<String, dynamic>?;
              return CartScreen(extraData: extra);
            },
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