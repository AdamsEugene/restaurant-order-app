import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import 'dart:math' as math;

class PaymentMethodsScreen extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const PaymentMethodsScreen({
    Key? key,
    required this.orderDetails,
  }) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedPaymentMethod = 'momo_mtn';
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCVVController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _momoNumberController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCVVController.dispose();
    _cardHolderController.dispose();
    _momoNumberController.dispose();
    super.dispose();
  }

  Widget _buildMobileMoneyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _momoNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Mobile Money Number',
            hintText: 'Enter your mobile money number',
            prefixIcon: const Icon(Icons.phone_android),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'You will receive a prompt on your phone to confirm payment.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.warning_amber_outlined, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'For demonstration purposes, no actual payment will be processed.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: 'XXXX XXXX XXXX XXXX',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cardExpiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _cardCVVController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 3,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        TextField(
          controller: _cardHolderController,
          decoration: InputDecoration(
            labelText: 'Card Holder Name',
            hintText: 'Enter name as it appears on card',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.warning_amber_outlined, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'For demonstration purposes, no actual payment will be processed.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCashPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payments_outlined, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will pay with cash when your order is delivered.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined, color: Colors.amber, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please ensure you have the exact amount ready for a smooth delivery experience.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String id, String name, String imagePath) {
    final isSelected = _selectedPaymentMethod == id;
    final Color primaryColor = AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.2) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                id.contains('momo_mtn') ? Icons.account_balance_wallet 
                : id.contains('momo_vodafone') ? Icons.phone_android
                : id.contains('momo_airteltigo') ? Icons.mobile_friendly
                : id.contains('card') ? Icons.credit_card 
                : id.contains('qr') ? Icons.qr_code
                : Icons.money,
                color: isSelected ? primaryColor : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    if (_selectedPaymentMethod.startsWith('momo')) {
      return _buildMobileMoneyForm();
    } else if (_selectedPaymentMethod.startsWith('card')) {
      return _buildCardPaymentForm();
    } else if (_selectedPaymentMethod.startsWith('qr')) {
      return _buildQRCodePaymentForm();
    } else {
      return _buildCashPaymentForm();
    }
  }

  Widget _buildQRCodePaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // QR Code Provider Selection
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption(
                'qr_mtn',
                'MTN QR Code',
                'assets/images/mtn_qr.png',
              ),
            ),
            Expanded(
              child: _buildPaymentOption(
                'qr_vodafone',
                'Vodafone QR',
                'assets/images/vodafone_qr.png',
              ),
            ),
            Expanded(
              child: _buildPaymentOption(
                'qr_airteltigo',
                'AirtelTigo QR',
                'assets/images/airteltigo_qr.png',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              // QR Code display
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildQRCodeWidget(),
              ),
              
              const SizedBox(height: 16),
              const Text(
                'Scan this QR code with your mobile payment app',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Using ${_getQRProviderName()} app',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  // This would normally open the device camera to scan the QR code
                  // For demo purposes, we'll just show a dialog
                  _simulateQRScanSuccess();
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code Instead'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        const Text(
          'Note: For demonstration purposes, no actual QR code scanning will be processed.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  String _getQRProviderName() {
    if (_selectedPaymentMethod == 'qr_mtn') {
      return 'MTN MoMo';
    } else if (_selectedPaymentMethod == 'qr_vodafone') {
      return 'Vodafone Cash';
    } else if (_selectedPaymentMethod == 'qr_airteltigo') {
      return 'AirtelTigo Money';
    } else {
      return 'Mobile Money';
    }
  }
  
  Widget _buildQRCodeWidget() {
    // This is a simple QR code-like widget created with CustomPaint
    // In a real app, you would use a QR code generation package
    return CustomPaint(
      painter: QRCodePainter(
        provider: _selectedPaymentMethod.replaceAll('qr_', ''),
      ),
    );
  }
  
  void _simulateQRScanSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: const Text('Pretending to scan a QR code for payment. In a real app, this would use your device camera.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    // In a real app, this would process the payment or redirect to a payment gateway
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Processing payment..."),
              ],
            ),
          ),
        );
      },
    );
    
    // Simulate processing delay
    Future.delayed(const Duration(seconds: 2), () {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Generate random order ID and receipt code
      final orderId = _generateOrderId();
      final receiptCode = _generateReceiptCode();
      
      // Add receipt code to order details
      final orderDetailsWithReceipt = Map<String, dynamic>.from(widget.orderDetails);
      orderDetailsWithReceipt['receiptCode'] = receiptCode;
      
      // Navigate to receipt screen
      context.go('/receipt/$orderId', extra: orderDetailsWithReceipt);
    });
  }
  
  String _generateOrderId() {
    // Generate a random order ID
    final random = math.Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${random.nextInt(999) + 1000}-${timestamp % 10000}';
  }
  
  String _generateReceiptCode() {
    // Generate a random receipt code (6 characters, all uppercase)
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed similar looking characters
    final random = math.Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code to Pay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // QR Code Provider Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQRProviderOption('mtn', 'MTN'),
                _buildQRProviderOption('vodafone', 'Vodafone'),
                _buildQRProviderOption('airteltigo', 'AirtelTigo'),
              ],
            ),
            
            const SizedBox(height: 24),
            // QR Code display
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildQRCodeWidget(),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Scan this QR code with your mobile payment app',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Using ${_getQRProviderName()} app',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateQRScanSuccess();
            },
            child: const Text('Completed Payment'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQRProviderOption(String value, String label) {
    final bool isSelected = _selectedPaymentMethod == 'qr_$value';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = 'qr_$value';
        });
        Navigator.pop(context);
        _showQRCodeDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = widget.orderDetails['totalAmount'] as double? ?? 0.0;
    
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
          onPressed: () => context.go('/order-confirmation', extra: widget.orderDetails),
        ),
        title: const Text(
          'Payment Methods',
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
              child: const Icon(Icons.qr_code_scanner, color: Colors.black),
            ),
            onPressed: () => _showQRCodeDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment amount summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Payment',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Secure Payment',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              // Payment Methods Selection
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOption(
                      'momo_mtn',
                      'MTN Mobile Money',
                      'assets/images/mtn_momo.png',
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentOption(
                      'momo_vodafone',
                      'Vodafone Cash',
                      'assets/images/vodafone_cash.png',
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentOption(
                      'momo_airteltigo',
                      'AirtelTigo Money',
                      'assets/images/airteltigo_money.png',
                    ),
                  ),
                ],
              ),
              
              // Card and Cash options
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOption(
                      'card_visa',
                      'Credit Card',
                      'assets/images/card.png',
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentOption(
                      'qr_code',
                      'QR Code',
                      'assets/images/qr.png',
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentOption(
                      'cash',
                      'Cash on Delivery',
                      'assets/images/cash.png',
                    ),
                  ),
                ],
              ),
              
              // Payment Form based on selected method
              _buildPaymentForm(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Complete Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
} 

// Custom QR code painter that simulates a QR code
class QRCodePainter extends CustomPainter {
  final String provider;
  
  QRCodePainter({required this.provider});
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(provider.hashCode); // Using provider as a seed
    
    // Draw white background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Draw QR code-like pattern
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Add corner squares (typical in QR codes)
    _drawCornerSquare(canvas, 0, 0, size.width / 4, paint);
    _drawCornerSquare(canvas, size.width - size.width / 4, 0, size.width / 4, paint);
    _drawCornerSquare(canvas, 0, size.height - size.height / 4, size.width / 4, paint);
    
    // Draw provider logo in the center
    final centerSize = size.width / 4;
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: centerSize,
      height: centerSize,
    );
    
    final logoPaint = Paint()
      ..color = _getProviderColor()
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, Radius.circular(centerSize / 4)),
      logoPaint,
    );
    
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
  
  Color _getProviderColor() {
    switch (provider) {
      case 'mtn':
        return Colors.yellow[700]!;
      case 'vodafone':
        return Colors.red;
      case 'airteltigo':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 