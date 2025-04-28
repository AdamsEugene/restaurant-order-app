import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
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

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _isCodeCopied = false;

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _isCodeCopied = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt code copied to clipboard'),
        duration: Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    final MenuItem? menuItem = widget.orderDetails['menuItem'] as MenuItem?;
    final int quantity = widget.orderDetails['quantity'] as int;
    final String customizations = widget.orderDetails['customizations'] as String;
    final String notes = widget.orderDetails['notes'] as String;
    final Restaurant? restaurant = widget.orderDetails['restaurant'] as Restaurant?;
    final double totalAmount = widget.orderDetails['totalAmount'] as double? ?? 0.0;
    
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
            onPressed: () {
              // In a real app, this would share the receipt
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share receipt feature would be implemented here'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success check icon
              Container(
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
              
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date:',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(orderDate),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time:',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(orderTime),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Estimate:',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(deliveryEstimate),
                        ],
                      ),
                      
                      const Divider(height: 32),
                      
                      // Order items
                      if (menuItem != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('\$${(totalAmount - 2.0 - (totalAmount * 0.05)).toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Delivery Fee'),
                          Text('\$2.00'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax (5%)'),
                          Text('\$${(totalAmount * 0.05).toStringAsFixed(2)}'),
                        ],
                      ),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
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
                      const Text(
                        'Show this code at pickup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // QR Code
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(8),
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
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                _isCodeCopied ? Icons.check : Icons.copy,
                                color: _isCodeCopied ? Colors.green : Colors.grey[600],
                              ),
                              onPressed: () => _copyToClipboard(widget.receiptCode),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Text(
                        'Your receipt code will be verified upon pickup',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
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
                  label: const Text('Track Order'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Back to Menu Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Back to Menu'),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptQRCodePainter extends CustomPainter {
  final String code;
  
  ReceiptQRCodePainter({required this.code});
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(code.hashCode); // Using code as a seed
    
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
      ..color = Colors.green
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