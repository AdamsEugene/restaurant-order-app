import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class SpecialOffersScreen extends StatefulWidget {
  const SpecialOffersScreen({Key? key}) : super(key: key);

  @override
  State<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends State<SpecialOffersScreen> {
  // Extended list of promotions
  final List<Map<String, dynamic>> _allPromotions = [
    {
      'title': 'Special Offer',
      'subtitle': 'Free delivery on your first order',
      'description': 'Enjoy free delivery on your first order with us. No minimum spend required.',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#FF5252',
      'expiryDate': '2023-12-31',
      'code': 'FIRSTDELIVERY',
    },
    {
      'title': 'New Restaurants',
      'subtitle': 'Discover new flavors near you',
      'description': '10% off your first order from our newly added restaurant partners.',
      'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#448AFF',
      'expiryDate': '2023-12-15',
      'code': 'NEWPLACE10',
    },
    {
      'title': '15% Discount',
      'subtitle': 'Use code: WELCOME15',
      'description': 'Get 15% off your order with a minimum spend of \$20.',
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#4CAF50',
      'expiryDate': '2023-12-10',
      'code': 'WELCOME15',
    },
    {
      'title': 'Weekend Special',
      'subtitle': '20% off on weekend orders',
      'description': 'Enjoy your weekends with 20% off on all orders placed on Saturday and Sunday.',
      'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#9C27B0',
      'expiryDate': '2024-01-31',
      'code': 'WEEKEND20',
    },
    {
      'title': 'Family Feast',
      'subtitle': '25% off on family bundles',
      'description': 'Order family bundles and get 25% off. Perfect for 4-6 people.',
      'image': 'https://images.unsplash.com/photo-1547573854-74d2a71d0826?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#FF9800',
      'expiryDate': '2023-12-25',
      'code': 'FAMILY25',
    },
    {
      'title': 'Lunch Time',
      'subtitle': '10% off on lunch orders',
      'description': 'Get 10% off on all orders placed between 11AM and 2PM.',
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#009688',
      'expiryDate': '2023-12-31',
      'code': 'LUNCH10',
    },
    {
      'title': 'Happy Hour',
      'subtitle': 'Buy 1 Get 1 Free on drinks',
      'description': 'Order any drink and get another one free. Valid from 5PM to 7PM daily.',
      'image': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'color': '#FF4081',
      'expiryDate': '2023-12-20',
      'code': 'HAPPYHOUR',
    },
  ];

  // Helper function to convert hex to color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  
  void _showPromoDetails(BuildContext context, Map<String, dynamic> promo) {
    Color promoColor = _getColorFromHex(promo['color']);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image with gradient overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Image.network(
                      promo['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        promoColor.withOpacity(0.5),
                        promoColor.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.black87),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        promo['subtitle'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2.0,
                              color: Color.fromARGB(130, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Promotion details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      promo['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Promo code
                    const Text(
                      'Promo Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            promo['code'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Copy to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied ${promo['code']} to clipboard'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Expiry date
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          'Valid until ${promo['expiryDate']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    
                    // Claim button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Apply promo to current order and navigate to cart
                          _applyPromoAndGoToCart(context, promo);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Promotion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Apply promotion and navigate to cart
  void _applyPromoAndGoToCart(BuildContext context, Map<String, dynamic> promo) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promotion ${promo['code']} applied!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
    
    // In a real app, you would:
    // 1. Save the promo code to app state (e.g., using Provider, Bloc, etc.)
    // 2. Calculate discount based on promo rules
    
    // Navigate to the cart with the promo code info immediately
    context.go(
      '/cart',
      extra: {
        'promoCode': promo['code'],
        'promoDiscount': _getDiscountValue(promo),
        'promoTitle': promo['title'],
      },
    );
  }
  
  // Calculate discount value based on promo type
  double _getDiscountValue(Map<String, dynamic> promo) {
    // This is a simplified implementation
    // In a real app, you would have more complex logic based on promo type
    
    final title = promo['title'].toString().toLowerCase();
    
    if (title.contains('free delivery')) {
      return 5.0; // Assuming $5 delivery fee
    } else if (title.contains('10%')) {
      return 0.1; // 10% discount
    } else if (title.contains('15%')) {
      return 0.15; // 15% discount
    } else if (title.contains('20%')) {
      return 0.2; // 20% discount
    } else if (title.contains('25%')) {
      return 0.25; // 25% discount
    } else if (title.contains('buy 1 get 1')) {
      return 0.5; // 50% off (effectively buy one get one free)
    } else {
      return 0.1; // Default 10% discount
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/home'),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new, 
              size: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allPromotions.length,
        itemBuilder: (context, index) {
          final promo = _allPromotions[index];
          Color promoColor = _getColorFromHex(promo['color']);
          
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: GestureDetector(
              onTap: () => _showPromoDetails(context, promo),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      promoColor.withOpacity(0.7),
                      promoColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: promoColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 0,
                      top: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: SizedBox(
                          width: 120,
                          child: Image.network(
                            promo['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            promo['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              promo['subtitle'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_offer,
                                      color: promoColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      promo['code'],
                                      style: TextStyle(
                                        color: promoColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 