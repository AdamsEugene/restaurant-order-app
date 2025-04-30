import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import 'dart:math' as math;

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const CartScreen({Key? key, this.extraData}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  // Sample cart items
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Jollof Rice with Chicken',
      'quantity': 1,
      'price': 12.99,
      'imageUrl': 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
    },
    {
      'name': 'Waakye with Fish',
      'quantity': 2,
      'price': 14.50,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
    },
  ];

  String? _promoCode;
  double? _promoDiscount;
  String? _promoTitle;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _promoController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    
    // Extract promo information if available
    if (widget.extraData != null) {
      _promoCode = widget.extraData!['promoCode'] as String?;
      _promoDiscount = widget.extraData!['promoDiscount'] as double?;
      _promoTitle = widget.extraData!['promoTitle'] as String?;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  // Calculate subtotal
  double get _subtotal => _cartItems.fold(
      0, (total, item) => total + (item['price'] as double) * (item['quantity'] as int));
  
  // Calculate delivery fee
  double get _deliveryFee => (_promoTitle?.toLowerCase().contains('free delivery') ?? false) ? 0.0 : 5.0;
  
  // Calculate discount amount
  double get _discountAmount {
    if (_promoDiscount == null) return 0.0;
    
    // Handle percentage discounts vs. fixed discounts
    if (_promoDiscount! < 1) {
      // Percentage discount (e.g., 0.15 = 15%)
      return _subtotal * _promoDiscount!;
    } else {
      // Fixed amount discount (e.g., 5.0 = $5 off)
      return _promoDiscount!;
    }
  }
  
  // Calculate total
  double get _total => _subtotal + _deliveryFee - _discountAmount;
  
  // Remove item with animation
  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
              onPressed: () => _showClearCartDialog(),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(),
      bottomNavigationBar: _cartItems.isEmpty 
          ? null 
          : _buildCheckoutBar(),
    );
  }
  
  Widget _buildEmptyCart() {
    return FadeTransition(
      opacity: _animation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Looks like you haven\'t added any items to your cart yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Browse Menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart count summary
              _buildCartSummary(),
              
              const SizedBox(height: 16),
              
              // Cart items
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems[index];
                  
                  return _buildCartItem(item, index);
                },
              ),
              
              const SizedBox(height: 24),
              
              // Active promotion section
              if (_promoCode != null)
                _buildActivePromotion(),
              
              const SizedBox(height: 20),
              
              // Order summary
              _buildOrderSummary(),
              
              const SizedBox(height: 20),
              
              // Add promo code section
              if (_promoCode == null)
                _buildPromoCodeSection(),
                
              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCartSummary() {
    final int totalItems = _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '$totalItems ${totalItems == 1 ? 'item' : 'items'} in cart',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add More',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item image with shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['imageUrl'] as String,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${(item['price'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Quantity control
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (item['quantity'] > 1) {
                                      item['quantity'] = item['quantity'] - 1;
                                    } else {
                                      _removeItem(index);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(Icons.remove, size: 16),
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            alignment: Alignment.center,
                            child: Text(
                              '${item['quantity']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    item['quantity'] = item['quantity'] + 1;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(Icons.add, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivePromotion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Promotion Applied',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _promoCode = null;
                      _promoDiscount = null;
                      _promoTitle = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _promoCode!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _promoTitle ?? 'Discount applied to your order',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_discountAmount > 0) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'You saved \$${_discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Subtotal
          _buildSummaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          
          const SizedBox(height: 12),
          
          // Delivery fee
          _buildSummaryRow(
            'Delivery Fee',
            _deliveryFee > 0 
                ? '\$${_deliveryFee.toStringAsFixed(2)}'
                : 'FREE',
            valueColor: _deliveryFee > 0 ? null : Colors.green,
            valueBold: _deliveryFee == 0,
          ),
          
          // Discount
          if (_discountAmount > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Discount',
              '-\$${_discountAmount.toStringAsFixed(2)}',
              valueColor: Colors.green,
              valueBold: true,
            ),
          ],
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: const Icon(
                    Icons.local_offer,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Apply Promo Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: const Icon(Icons.discount_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // Apply promo code
                  context.go('/special-offers');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/special-offers'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'View Available Promotions',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            final orderDetails = {
              'items': _cartItems,
              'subtotal': _subtotal,
              'deliveryFee': _deliveryFee,
              'discountAmount': _discountAmount,
              'totalAmount': _total,
              'promoCode': _promoCode,
              'promoTitle': _promoTitle,
            };
            
            // Navigate to order confirmation
            context.go('/order-confirmation', extra: orderDetails);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _cartItems.clear();
              });
            },
            child: const Text(
              'CLEAR CART',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 