import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../config/theme.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const OrderConfirmationScreen({
    Key? key,
    required this.orderDetails,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late bool isDelivery = true;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late String deliveryTime = '30-45 minutes';
  final double deliveryFee = 2.0;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: '123 Main Street, Apt 4B, Accra, Ghana');
    phoneController = TextEditingController(text: '+233 54 123 4567');
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _openMap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.map, size: 100, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    // This would normally use location services
                    // For demo, we'll just update with a new address
                    setState(() {
                      addressController.text = '456 Park Avenue, East Legon, Accra, Ghana';
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // This would normally save selected coordinates
              setState(() {
                addressController.text = '456 Park Avenue, East Legon, Accra, Ghana';
              });
              Navigator.pop(context);
            },
            child: const Text('Confirm Location'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MenuItem? menuItem = widget.orderDetails['menuItem'] as MenuItem?;
    final int quantity = widget.orderDetails['quantity'] as int;
    final String customizations = widget.orderDetails['customizations'] as String;
    final String notes = widget.orderDetails['notes'] as String;
    final Restaurant? restaurant = widget.orderDetails['restaurant'] as Restaurant?;
    
    // Use finalPrice from menu item details if available, otherwise calculate from base price
    final double itemPrice = widget.orderDetails['finalPrice'] as double? ?? 
                            (menuItem != null ? menuItem.price * quantity : 0.0);
    
    final double tax = itemPrice * 0.05;
    final double totalAmount = itemPrice + (isDelivery ? deliveryFee : 0) + tax;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () {
            if (menuItem != null) {
              context.go('/menu/${menuItem.id}');
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Order Confirmation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: menuItem == null
          ? const Center(child: Text('Error: Item not found'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    menuItem.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.restaurant,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Item details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        menuItem.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (restaurant != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'From ${restaurant.name}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        'Quantity: $quantity',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (quantity > 1) ...[
                                        Text(
                                          'Price: \$${(itemPrice / quantity).toStringAsFixed(2)} each',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total: \$${itemPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          'Price: \$${itemPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Customizations
                    if (customizations.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Customizations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customizations,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    // Special instructions
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Special Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notes,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    // Delivery details
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Delivery/Pickup Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDelivery = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDelivery ? AppTheme.primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Delivery',
                                    style: TextStyle(
                                      color: isDelivery ? Colors.white : Colors.black,
                                      fontWeight: isDelivery ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDelivery = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: !isDelivery ? AppTheme.primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Pickup',
                                    style: TextStyle(
                                      color: !isDelivery ? Colors.white : Colors.black,
                                      fontWeight: !isDelivery ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDelivery) ...[
                              // Address with edit button
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: addressController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter delivery address',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.map_outlined, color: Colors.deepOrange),
                                    onPressed: _openMap,
                                    tooltip: 'Select on map',
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Phone
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: phoneController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter phone number',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Delivery time
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Estimated delivery: $deliveryTime',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Pickup details
                              Row(
                                children: [
                                  Icon(Icons.storefront, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      restaurant?.name ?? 'Restaurant',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      '42 Independence Avenue, Accra, Ghana',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ready for pickup in: $deliveryTime',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: phoneController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter phone number for notifications',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Payment summary
                    const SizedBox(height: 24),
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal'),
                                Text('\$${itemPrice.toStringAsFixed(2)}'),
                              ],
                            ),
                            if (isDelivery) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Delivery Fee'),
                                  Text('\$${deliveryFee.toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tax'),
                                Text('\$${tax.toStringAsFixed(2)}'),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '\$${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Navigate to payment methods with order details
                    context.go('/payment-methods', extra: {
                      ...widget.orderDetails,
                      'total': totalAmount,
                      'tax': tax,
                      'deliveryFee': isDelivery ? deliveryFee : 0.0,
                      'isDelivery': isDelivery,
                      'address': isDelivery ? addressController.text : 'Pickup',
                      'phone': phoneController.text,
                      'deliveryTime': deliveryTime,
                    });
                  },
                  child: const Text(
                    'Proceed to Payment',
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
    );
  }
} 