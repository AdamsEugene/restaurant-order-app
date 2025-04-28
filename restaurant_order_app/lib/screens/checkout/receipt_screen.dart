import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';

class ReceiptScreen extends StatefulWidget {
  final String orderId;

  const ReceiptScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    // Generate a pickup code
    final pickupCode = widget.orderId.substring(widget.orderId.length - 6).toUpperCase();
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Success icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppTheme.successColor,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Success message
                      const Text(
                        'Order Placed Successfully!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Your order has been placed and is being processed.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Order details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Order ID
                            _buildReceiptRow(
                              'Order ID',
                              widget.orderId,
                              showCopy: true,
                              onCopy: () => _copyToClipboard(widget.orderId),
                            ),
                            const Divider(height: 24),
                            
                            // Restaurant name
                            _buildReceiptRow(
                              'Restaurant',
                              'Sample Restaurant',
                            ),
                            const SizedBox(height: 12),
                            
                            // Order time
                            _buildReceiptRow(
                              'Order Time',
                              _formatDateTime(DateTime.now()),
                            ),
                            const SizedBox(height: 12),
                            
                            // Pickup code
                            _buildReceiptRow(
                              'Pickup Code',
                              pickupCode,
                              isBold: true,
                              valueColor: AppTheme.primaryColor,
                              showCopy: true,
                              onCopy: () => _copyToClipboard(pickupCode),
                            ),
                            const Divider(height: 24),
                            
                            // Payment method
                            _buildReceiptRow(
                              'Payment Method',
                              'Credit Card',
                            ),
                            const SizedBox(height: 12),
                            
                            // Total
                            _buildReceiptRow(
                              'Total Amount',
                              '\$24.99',
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Present your pickup code when collecting your order.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Estimated delivery time: 30-45 minutes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Buttons
              Column(
                children: [
                  PrimaryButton(
                    text: 'Track Order',
                    onPressed: () {
                      context.go('/orders/${widget.orderId}/tracking');
                    },
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'Back to Home',
                    onPressed: () {
                      context.go('/home');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    bool showCopy = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? AppTheme.primaryTextColor,
              ),
            ),
            if (showCopy && onCopy != null) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTimeOfDay(dateTime)}';
  }
  
  String _formatTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
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