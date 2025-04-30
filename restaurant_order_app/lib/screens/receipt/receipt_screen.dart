import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';

class ReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final String orderId;
  final String receiptCode;

  const ReceiptScreen({
    Key? key,
    required this.orderDetails,
    required this.orderId,
    required this.receiptCode,
  }) : super(key: key);

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> with SingleTickerProviderStateMixin {
  bool _isCodeCopied = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _isCodeCopied = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Receipt code copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    // Reset the copy state after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCodeCopied = false;
        });
      }
    });
  }

  void _shareReceipt() {
    // In a real app, this would share the receipt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Share receipt feature would be implemented here'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final double totalAmount = widget.orderDetails['totalAmount'] as double? ?? 0.0;
    final String paymentMethod = widget.orderDetails['paymentMethod'] as String? ?? 'Card';
    
    // Format current date
    final now = DateTime.now();
    final orderDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final orderTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Calculate delivery estimate (30-45 min from now)
    final deliveryEstimate = '${orderTime} - ${(now.hour + (now.minute + 45 >= 60 ? 1 : 0)).toString().padLeft(2, '0')}:${((now.minute + 45) % 60).toString().padLeft(2, '0')}';
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            child: const Icon(Icons.home, color: Colors.black),
          ),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Receipt',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
              child: const Icon(Icons.share, color: Colors.black),
            ),
            onPressed: _shareReceipt,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success check icon
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #${widget.orderId}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Receipt Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant info
                        if (restaurant != null) ...[
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  restaurant.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  restaurant.address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 32),
                        ],
                        
                        // Order info
                        _buildInfoRow('Date:', orderDate),
                        const SizedBox(height: 8),
                        _buildInfoRow('Time:', orderTime),
                        const SizedBox(height: 8),
                        _buildInfoRow('Delivery Estimate:', deliveryEstimate),
                        const SizedBox(height: 8),
                        _buildInfoRow('Payment Method:', _formatPaymentMethod(paymentMethod)),
                        
                        const Divider(height: 32),
                        
                        // Order items
                        if (menuItem != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    menuItem.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.restaurant,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${quantity}x ${menuItem.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (customizations.isNotEmpty)
                                      Text(
                                        'Customizations: $customizations',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    if (notes.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Notes: $notes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '\$${(menuItem.price * quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const Divider(height: 32),
                        
                        // Order total
                        _buildInfoRow('Subtotal', '\$${(totalAmount - 2.0 - (totalAmount * 0.05)).toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Delivery Fee', '\$2.00'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Tax (5%)', '\$${(totalAmount * 0.05).toStringAsFixed(2)}'),
                        const Divider(height: 16),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // QR Code and Receipt Code
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              'Show this code at pickup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // QR Code
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: ReceiptQRCodePainter(code: widget.receiptCode),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Receipt Code
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.receiptCode,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: _isCodeCopied ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isCodeCopied ? Icons.check : Icons.copy,
                                    color: _isCodeCopied ? Colors.green : Colors.grey[600],
                                  ),
                                  onPressed: () => _copyToClipboard(widget.receiptCode),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Your receipt code will be verified upon pickup',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
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
                
                const SizedBox(height: 24),
                
                // Track Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to order tracking screen
                      context.go('/order-tracking/${widget.orderId}', extra: widget.orderDetails);
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text(
                      'Track Order',
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
                
                const SizedBox(height: 16),
                
                // Back to Menu Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      'Back to Menu',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  String _formatPaymentMethod(String method) {
    if (method.startsWith('momo_')) {
      final provider = method.split('_').last;
      return 'Mobile Money (${provider.toUpperCase()})';
    } else if (method.startsWith('card_')) {
      return 'Credit Card';
    } else if (method.startsWith('qr_')) {
      final provider = method.split('_').last;
      return 'QR Code (${provider.toUpperCase()})';
    } else if (method == 'cash') {
      return 'Cash on Delivery';
    }
    return method;
  }
}

class ReceiptQRCodePainter extends CustomPainter {
  final String code;
  
  ReceiptQRCodePainter({required this.code});
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(code.hashCode); // Using code as a seed
    
    // Draw white background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Draw QR code-like pattern
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Draw the three corner square markers typical in QR codes
    _drawCornerSquare(canvas, 0, 0, size.width / 4, paint);
    _drawCornerSquare(canvas, size.width - size.width / 4, 0, size.width / 4, paint);
    _drawCornerSquare(canvas, 0, size.height - size.height / 4, size.width / 4, paint);
    
    // Draw some random squares to simulate QR code pattern
    final cellSize = size.width / 20;
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        // Skip corners and center
        if (_isCorner(i, j) || _isCenter(i, j)) {
          continue;
        }
        
        // Randomly fill some cells
        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
    
    // Draw app icon or logo in the center
    final centerSize = size.width / 4.5;
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: centerSize,
      height: centerSize,
    );
    
    final logoPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, Radius.circular(centerSize / 4)),
      logoPaint,
    );
    
    // Draw "R" letter in the center
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'R',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }
  
  bool _isCorner(int i, int j) {
    return (i < 4 && j < 4) || 
           (i > 15 && j < 4) || 
           (i < 4 && j > 15);
  }
  
  bool _isCenter(int i, int j) {
    return i >= 7 && i <= 12 && j >= 7 && j <= 12;
  }
  
  void _drawCornerSquare(Canvas canvas, double x, double y, double size, Paint paint) {
    // Outer square
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), paint);
    
    // Inner white square
    final innerSize = size * 0.7;
    final offset = (size - innerSize) / 2;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x + offset, y + offset, innerSize, innerSize),
      whitePaint,
    );
    
    // Center black square
    final centerSize = size * 0.4;
    final centerOffset = (size - centerSize) / 2;
    canvas.drawRect(
      Rect.fromLTWH(x + centerOffset, y + centerOffset, centerSize, centerSize),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 