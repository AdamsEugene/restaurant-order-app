import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        // Mobile Money Provider Selection
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
        
        const SizedBox(height: 24),
        TextField(
          controller: _momoNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Mobile Money Number',
            hintText: 'Enter your mobile money number',
            prefixIcon: const Icon(Icons.phone_android),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        const Text(
          'You will receive a prompt on your phone to confirm payment.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        
        const SizedBox(height: 8),
        const Text(
          'Note: For demonstration purposes, no actual payment will be processed.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCardPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Card Type Selection
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption(
                'card_visa',
                'Visa',
                'assets/images/visa.png',
              ),
            ),
            Expanded(
              child: _buildPaymentOption(
                'card_mastercard',
                'Mastercard',
                'assets/images/mastercard.png',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: 'XXXX XXXX XXXX XXXX',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        const Text(
          'Note: For demonstration purposes, no actual payment will be processed.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.money, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'You will pay with cash when your order is delivered.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please ensure you have the exact amount ready for a smooth delivery experience.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String title, String imagePath) {
    bool isSelected = _selectedPaymentMethod.startsWith(value.split('_')[0]);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          children: [
            // Using a placeholder Icon since we won't load actual image assets in this example
            Icon(
              value.contains('momo') ? Icons.account_balance_wallet 
              : value.contains('card') ? Icons.credit_card 
              : Icons.money,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black,
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
    } else {
      return _buildCashPaymentForm();
    }
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
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Payment Successful"),
            content: const Text("Your order has been placed successfully!"),
            actions: [
              TextButton(
                onPressed: () {
                  // Close dialog and navigate to order tracking
                  Navigator.of(context).pop();
                  context.go('/home');
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      color: Colors.green,
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              // Payment Methods Tabs
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOption(
                      'momo_all',
                      'Mobile Money',
                      'assets/images/momo.png',
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentOption(
                      'card_all',
                      'Debit/Credit Card',
                      'assets/images/card.png',
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
} 