import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../widgets/buttons/primary_button.dart';
import 'package:lottie/lottie.dart';

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

class _TrackOrderScreenState extends State<TrackOrderScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isOrderReady = false;
  late Timer _statusTimer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
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
  
  final List<String> _animationAssets = [
    'assets/animations/order_received.json',
    'assets/animations/cooking.json',
    'assets/animations/almost_ready.json',
    'assets/animations/ready.json',
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    
    // Simulate order status updates
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        if (_currentStep < 3) {
          _animationController.reset();
          _currentStep++;
          _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Your Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
          onPressed: () => context.go('/receipt/${widget.orderId}', extra: widget.orderDetails),
        ),
        actions: [
          IconButton(
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
              child: const Icon(Icons.refresh, color: Colors.black),
            ),
            onPressed: () {
              // Reset animation and simulate refresh
              _animationController.reset();
              _animationController.forward();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Restaurant Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Order ID
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ID',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.receipt_outlined, size: 16, color: AppTheme.primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      '#${widget.orderId}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
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
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.restaurant, size: 16, color: AppTheme.primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.orderDetails['restaurantName'] as String? ?? 'Restaurant',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Order placed at: ${_getFormattedTime()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Current status with animation
              FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getStatusIconColor().withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getStatusIcon(),
                                  color: _getStatusIconColor(),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _statusMessages[_currentStep],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _statusDescriptions[_currentStep],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Attempt to load Lottie animation, with fallback to placeholder
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(
                                  _getStatusIcon(),
                                  size: 64,
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                          
                          if (!_isOrderReady) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: AppTheme.primaryColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${15 - (_currentStep * 5)} minutes remaining',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Progress tracker
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: List.generate(_statusMessages.length, (index) {
                          final bool isActive = index <= _currentStep;
                          final bool isCurrent = index == _currentStep;
                          return Expanded(
                            child: Column(
                              children: [
                                // Circle
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: isCurrent ? 36 : 30,
                                  height: isCurrent ? 36 : 30,
                                  decoration: BoxDecoration(
                                    color: isActive 
                                        ? AppTheme.primaryColor 
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                    boxShadow: isCurrent ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ] : null,
                                  ),
                                  child: Center(
                                    child: isActive 
                                        ? Icon(
                                            _getStepIcon(index),
                                            color: Colors.white,
                                            size: isCurrent ? 20 : 16,
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Status label
                                Text(
                                  _getShortStatus(index),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    color: isCurrent ? AppTheme.primaryColor : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Line (except for last item)
                                if (index < _statusMessages.length - 1)
                                  Container(
                                    width: (screenWidth - 40) / 4,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: index < _currentStep 
                                          ? AppTheme.primaryColor 
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Pickup button (when ready)
              if (_isOrderReady)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/submit-receipt-code/${widget.orderId}', extra: widget.orderDetails);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text(
                      'Pickup Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
            
              // Help and cancel buttons
              const SizedBox(height: 20),
              Row(
                children: [
                  if (!_isOrderReady)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCancelConfirmationDialog();
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text(
                          'Cancel Order',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (!_isOrderReady) const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Show help or support contact
                        _showHelpDialog();
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text(
                        'Need Help',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade800,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
  
  IconData _getStepIcon(int step) {
    switch (step) {
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
  
  String _getShortStatus(int step) {
    switch (step) {
      case 0:
        return 'Received';
      case 1:
        return 'Preparing';
      case 2:
        return 'Almost Ready';
      case 3:
        return 'Ready';
      default:
        return '';
    }
  }
  
  Color _getStatusIconColor() {
    return AppTheme.primaryColor;
  }
  
  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('Your order has been cancelled'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text(
              'YES, CANCEL',
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
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.phone,
              title: 'Call Restaurant',
              subtitle: 'Speak directly with the restaurant',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.message,
              title: 'Live Chat',
              subtitle: 'Chat with customer support',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.help_outline,
              title: 'FAQs',
              subtitle: 'Frequently asked questions',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CLOSE'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title feature would be implemented here'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
} 