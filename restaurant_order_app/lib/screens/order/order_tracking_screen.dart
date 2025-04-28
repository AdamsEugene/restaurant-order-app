import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/loading/loading_indicator.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isLoading = true;
  late Order _order;
  int _statusIndex = 0;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    // In a real app, we would load the order from a bloc
    // context.read<OrderBloc>().add(LoadOrderDetails(widget.orderId));
    _loadMockOrder();
  }

  void _loadMockOrder() {
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _order = _createMockOrder();
        _isLoading = false;
        
        // Determine status index
        if (_order.status == OrderStatus.preparing) {
          _statusIndex = 1;
        } else if (_order.status == OrderStatus.readyForPickup) {
          _statusIndex = 2;
        } else if (_order.status == OrderStatus.outForDelivery) {
          _statusIndex = 2;
          _showMap = true;
        } else if (_order.status == OrderStatus.delivered) {
          _statusIndex = 3;
        }
      });
    });
  }

  Order _createMockOrder() {
    // Create a mock order with some sample data
    final isDelivery = widget.orderId.contains('1');
    
    final orderStatus = isDelivery 
        ? OrderStatus.outForDelivery 
        : OrderStatus.readyForPickup;
    
    final createdAt = DateTime.now().subtract(const Duration(minutes: 30));
    
    return Order(
      id: widget.orderId,
      restaurantId: 'REST101',
      restaurantName: 'Sample Restaurant',
      items: [],
      subtotal: 25.47,
      tax: 2.10,
      deliveryFee: isDelivery ? 3.99 : null,
      serviceFee: 1.99,
      total: isDelivery ? 33.55 : 29.56,
      createdAt: createdAt,
      estimatedDeliveryTime: createdAt.add(const Duration(minutes: 30)),
      status: orderStatus,
      deliveryAddress: isDelivery 
          ? const DeliveryAddress(
              addressLine1: '123 Main St',
              city: 'New York',
              state: 'NY',
              zipCode: '10001',
            ) 
          : null,
      paymentMethod: const PaymentMethod(
        id: 'PM001',
        type: 'credit_card',
        cardBrand: 'visa',
        last4: '4242',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _buildTrackingContent(),
    );
  }

  Widget _buildTrackingContent() {
    final pickupCode = _order.id.substring(_order.id.length - 6).toUpperCase();
    final isDelivery = _order.deliveryAddress != null;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: AppTheme.primaryColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDelivery)
                        const Text(
                          'Estimated Delivery',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      else
                        const Text(
                          'Ready by',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _order.estimatedDeliveryTime != null
                            ? DateFormat('h:mm a').format(_order.estimatedDeliveryTime!)
                            : 'Soon',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Timeline and details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Order ID card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Code',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        pickupCode,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _copyToClipboard(pickupCode),
                                        icon: const Icon(Icons.copy, size: 18),
                                        visualDensity: VisualDensity.compact,
                                        splashRadius: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order Time',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('h:mm a').format(_order.createdAt),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!isDelivery)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.primaryColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Show this code to the staff when you pick up your order.',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Status timeline
                _buildStatusTimeline(),
                
                // Map placeholder for delivery
                if (_showMap)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Map View',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Would display live delivery tracking',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Restaurant info
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            size: 30,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _order.restaurantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order #$pickupCode',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Contact restaurant
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Calling restaurant...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Help button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: PrimaryButton(
                    text: 'Need Help?',
                    onPressed: () {
                      // Show help options
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contacting support...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusTimeline() {
    final statuses = [
      'Order Placed',
      'Preparing',
      _order.deliveryAddress != null ? 'Out for Delivery' : 'Ready for Pickup',
      'Delivered',
    ];
    
    final statusIcons = [
      Icons.receipt_long,
      Icons.restaurant,
      _order.deliveryAddress != null ? Icons.delivery_dining : Icons.takeout_dining,
      Icons.check_circle,
    ];
    
    return Column(
      children: List.generate(statuses.length, (index) {
        final isActive = index <= _statusIndex;
        final isCompleted = index < _statusIndex;
        final isLast = index == statuses.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status circle and line
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive 
                        ? (isCompleted ? Colors.green : AppTheme.primaryColor)
                        : Colors.grey.shade300,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : statusIcons[index],
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted 
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            
            // Status text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statuses[index],
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive 
                            ? (isCompleted ? Colors.green : AppTheme.primaryColor)
                            : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    if (isActive && !isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _getStatusTimeDescription(index),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
  
  String _getStatusTitle() {
    switch (_order.status) {
      case OrderStatus.pending:
        return 'Order Received';
      case OrderStatus.preparing:
        return 'Preparing Your Order';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Order Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }
  
  String _getStatusDescription() {
    switch (_order.status) {
      case OrderStatus.pending:
        return 'Your order is being processed by the restaurant.';
      case OrderStatus.preparing:
        return 'The restaurant is preparing your food.';
      case OrderStatus.readyForPickup:
        return 'Your order is ready! Please pick up your food.';
      case OrderStatus.outForDelivery:
        return 'A driver is on the way with your order.';
      case OrderStatus.delivered:
        return 'Your order has been delivered. Enjoy!';
      case OrderStatus.cancelled:
        return 'This order has been cancelled.';
    }
  }
  
  String _getStatusTimeDescription(int index) {
    final now = DateTime.now();
    
    switch (index) {
      case 0: // Order Placed
        final placedTime = DateFormat('h:mm a').format(_order.createdAt);
        return 'Placed at $placedTime';
      case 1: // Preparing
        if (_order.status == OrderStatus.preparing) {
          // Simulate food prep time between 10-20 minutes
          final prepTimeMinutes = 10 + (_order.id.hashCode % 10);
          return 'Estimated prep time: $prepTimeMinutes minutes';
        }
        return '';
      case 2: // Ready/Delivery
        if (_order.status == OrderStatus.readyForPickup) {
          return 'Your order is ready for pickup!';
        } else if (_order.status == OrderStatus.outForDelivery) {
          if (_order.estimatedDeliveryTime != null) {
            final estimatedTime = DateFormat('h:mm a').format(_order.estimatedDeliveryTime!);
            return 'Estimated arrival by $estimatedTime';
          }
          return 'Driver is on the way';
        }
        return '';
      case 3: // Delivered
        if (_order.status == OrderStatus.delivered) {
          // For completed orders, show delivery time
          final deliveryTime = DateFormat('h:mm a').format(now.subtract(const Duration(minutes: 5)));
          return 'Delivered at $deliveryTime';
        }
        return '';
      default:
        return '';
    }
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 