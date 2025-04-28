import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../widgets/buttons/primary_button.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderDetails;

  const TrackOrderScreen({
    Key? key,
    required this.orderId,
    required this.orderDetails,
  }) : super(key: key);

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  int _currentStep = 0;
  bool _isOrderReady = false;
  late Timer _statusTimer;
  
  final List<String> _statusMessages = [
    'Order received',
    'Preparing your order',
    'Almost ready',
    'Ready for pickup',
  ];

  final List<String> _statusDescriptions = [
    'The restaurant has received your order and will begin preparing it shortly.',
    'The restaurant is now preparing your delicious food.',
    'Your food is almost ready! Just a few more minutes.',
    'Your food is ready for pickup! Please proceed to the counter.',
  ];

  @override
  void initState() {
    super.initState();
    
    // Simulate order status updates
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        if (_currentStep < 3) {
          _currentStep++;
        } else {
          _isOrderReady = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _statusTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Order'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/receipt/${widget.orderId}', extra: widget.orderDetails),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Restaurant info
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Order ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${widget.orderId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Restaurant
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Restaurant',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.orderDetails['restaurantName'] as String? ?? 'Restaurant',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Current status with icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getStatusIconColor().withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusIconColor(),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusMessages[_currentStep],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _statusDescriptions[_currentStep],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Progress tracker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: List.generate(_statusMessages.length, (index) {
                  final bool isActive = index <= _currentStep;
                  return Expanded(
                    child: Column(
                      children: [
                        // Circle
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isActive 
                                ? Colors.deepOrange 
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: isActive 
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        
                        // Line (except for last item)
                        if (index < _statusMessages.length - 1)
                          Container(
                            height: 2,
                            color: index < _currentStep 
                                ? Colors.deepOrange 
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 100),
            
            // Estimated time
            if (!_isOrderReady)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Time',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${15 - (_currentStep * 5)} minutes remaining',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Pickup button (when ready)
            if (_isOrderReady)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Pickup Order',
                    onPressed: () {
                      context.go('/submit-receipt-code/${widget.orderId}', extra: widget.orderDetails);
                    },
                  ),
                ),
              ),
            
            // Cancel order button
            if (!_isOrderReady)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelConfirmationDialog();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                      side: const BorderSide(color: Colors.deepOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getStatusIcon() {
    switch (_currentStep) {
      case 0:
        return Icons.receipt_long;
      case 1:
        return Icons.restaurant;
      case 2:
        return Icons.local_dining;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.access_time;
    }
  }
  
  Color _getStatusIconColor() {
    return Colors.deepOrange;
  }
  
  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel your order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
              
              // Show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your order has been cancelled'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'YES, CANCEL',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 