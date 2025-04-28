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
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Restaurant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.orderDetails['restaurantName'] as String? ?? 'Restaurant',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Current status
              Text(
                _statusMessages[_currentStep],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Status description
              Text(
                _statusDescriptions[_currentStep],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Progress stepper
              _buildOrderStepper(),
              
              const Spacer(),
              
              // Pickup order button (visible only when order is ready)
              if (_isOrderReady)
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Pickup Order',
                    onPressed: () {
                      context.go('/submit-receipt-code/${widget.orderId}', extra: widget.orderDetails);
                    },
                  ),
                ),
                
              // Estimated time (visible when order is not ready)
              if (!_isOrderReady)
                _buildEstimatedTimeCard(),
                
              const SizedBox(height: 16),
              
              // Cancel order button (only visible when order is not ready)
              if (!_isOrderReady)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelConfirmationDialog();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel Order'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOrderStepper() {
    return Column(
      children: List.generate(_statusMessages.length, (index) {
        final bool isActive = index <= _currentStep;
        
        return Row(
          children: [
            // Status circle
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
              child: isActive
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            
            // Horizontal line (except for last item)
            if (index < _statusMessages.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: index < _currentStep
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              
            // Spacer for last item
            if (index == _statusMessages.length - 1)
              const Spacer(),
          ],
        );
      }),
    );
  }
  
  Widget _buildEstimatedTimeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated Time',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${15 - (_currentStep * 5)} minutes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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