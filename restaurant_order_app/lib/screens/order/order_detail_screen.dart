import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../models/menu_item.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/loading/loading_indicator.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  late Order _order;

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
      });
    });
  }

  Order _createMockOrder() {
    // Create a mock order with some sample data
    final isActive = widget.orderId.startsWith('ORD2');
    final isDelivery = widget.orderId.contains('1');
    
    final orderStatus = isActive 
        ? (isDelivery ? OrderStatus.outForDelivery : OrderStatus.preparing)
        : OrderStatus.delivered;
    
    final createdAt = DateTime.now().subtract(
        isActive ? const Duration(hours: 1) : const Duration(days: 2));
    
    return Order(
      id: widget.orderId,
      restaurantId: 'REST101',
      restaurantName: 'Sample Restaurant',
      items: [
        CartItem(
          id: 'CI001',
          menuItem: MenuItem(
            id: 'MI001',
            name: 'Chicken Burger',
            description: 'Grilled chicken with lettuce, tomato, and mayo.',
            price: 9.99,
            imageUrl: 'https://via.placeholder.com/100',
            category: 'Burgers',
          ),
          quantity: 2,
          customizations: const [
            CustomizationSelection(
              groupId: 'CG001',
              groupName: 'Add cheese',
              optionId: 'CO001',
              optionName: 'Cheddar',
              priceAdjustment: 1.50,
            ),
          ],
        ),
        CartItem(
          id: 'CI002',
          menuItem: MenuItem(
            id: 'MI002',
            name: 'French Fries',
            description: 'Crispy golden fries.',
            price: 3.99,
            imageUrl: 'https://via.placeholder.com/100',
            category: 'Sides',
          ),
          quantity: 1,
        ),
      ],
      subtotal: 25.47,
      tax: 2.10,
      deliveryFee: isDelivery ? 3.99 : null,
      serviceFee: 1.99,
      total: isDelivery ? 33.55 : 29.56,
      createdAt: createdAt,
      estimatedDeliveryTime: isActive && isDelivery 
          ? createdAt.add(const Duration(minutes: 30)) 
          : null,
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
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    final pickupCode = _order.id.substring(_order.id.length - 6).toUpperCase();
    final isCompleted = _order.status == OrderStatus.delivered || 
                         _order.status == OrderStatus.cancelled;
    final isDelivery = _order.deliveryAddress != null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order status card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #$pickupCode',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyToClipboard(pickupCode),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Text(
                                'Copy',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.copy,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOrderStatusBar(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ordered on',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, y • h:mm a').format(_order.createdAt),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (!isCompleted && _order.estimatedDeliveryTime != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Estimated delivery by',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('h:mm a').format(_order.estimatedDeliveryTime!),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Restaurant information
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restaurant',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _order.restaurantName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isCompleted)
                              TextButton(
                                onPressed: () {
                                  context.go('/restaurants/${_order.restaurantId}');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Order Again'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Delivery/Pickup information
          if (isDelivery)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _order.deliveryAddress!.fullAddress,
                            style: const TextStyle(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_order.deliveryInstructions != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Instructions: ${_order.deliveryInstructions}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please show your order code when you arrive at the restaurant.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Order items
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _order.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = _order.items[index];
                      return _buildOrderItemCard(item);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Payment details
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment Method'),
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPaymentMethodName(_order.paymentMethod),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPriceSummary(),
                ],
              ),
            ),
          ),
          
          // Actions
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _order.status == OrderStatus.outForDelivery || 
                    _order.status == OrderStatus.readyForPickup
                  ? PrimaryButton(
                      text: 'Track Order',
                      onPressed: () {
                        context.go('/orders/${_order.id}/tracking');
                      },
                    )
                  : PrimaryButton(
                      text: 'Contact Restaurant',
                      onPressed: () {
                        // Handle contact restaurant
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contacting restaurant...'),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildOrderStatusBar() {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.preparing,
      _order.deliveryAddress != null 
          ? OrderStatus.outForDelivery 
          : OrderStatus.readyForPickup,
      OrderStatus.delivered,
    ];
    
    // Find the current step index
    int currentStep = statuses.indexOf(_order.status);
    if (currentStep == -1) {
      // Handle cancelled or other statuses
      currentStep = 0;
    }
    
    return Row(
      children: List.generate(statuses.length, (index) {
        final isActive = index <= currentStep;
        final isLast = index == statuses.length - 1;
        
        return Expanded(
          child: Row(
            children: [
              // Status circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
                child: Icon(
                  isActive ? Icons.check : null,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              
              // Connecting line
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive && index < currentStep 
                        ? AppTheme.primaryColor 
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildOrderItemCard(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${item.quantity}x',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.menuItem.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.customizations.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...item.customizations.map((customization) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          '${customization.groupName}: ${customization.optionName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (customization.priceAdjustment > 0)
                          Text(
                            ' (+\$${customization.priceAdjustment.toStringAsFixed(2)})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              if (item.specialInstructions != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Note: ${item.specialInstructions}',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Price
        Text(
          '\$${item.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriceSummary() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            Text('\$${_order.subtotal.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tax',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            Text('\$${_order.tax.toStringAsFixed(2)}'),
          ],
        ),
        if (_order.deliveryFee != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              Text('\$${_order.deliveryFee!.toStringAsFixed(2)}'),
            ],
          ),
        ],
        if (_order.serviceFee != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Fee',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              Text('\$${_order.serviceFee!.toStringAsFixed(2)}'),
            ],
          ),
        ],
        if (_order.tip != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tip',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              Text('\$${_order.tip!.toStringAsFixed(2)}'),
            ],
          ),
        ],
        if (_order.promoDiscount != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(
                      color: Colors.green.shade600,
                    ),
                  ),
                  if (_order.promoCode != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${_order.promoCode})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '-\$${_order.promoDiscount!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
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
              '\$${_order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _getPaymentMethodName(PaymentMethod paymentMethod) {
    if (paymentMethod.type == 'credit_card' && 
        paymentMethod.cardBrand != null && 
        paymentMethod.last4 != null) {
      return '${_capitalizeFirstLetter(paymentMethod.cardBrand!)} ••••${paymentMethod.last4}';
    }
    return _capitalizeFirstLetter(paymentMethod.type);
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
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