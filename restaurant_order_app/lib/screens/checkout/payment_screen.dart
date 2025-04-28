import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../config/theme.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/forms/custom_text_field.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
  
  void _processPayment() {
    // In a real app, you would validate inputs and process payment
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      // Generate a random order ID for demonstration
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Navigate to receipt screen
      context.go('/receipt/$orderId');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            return _buildPaymentForm(context, state.cart.total);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
  
  Widget _buildPaymentForm(BuildContext context, double total) {
    final totalWithTaxAndDelivery = total + 2.99 + (total * 0.08);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment methods
          const Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Credit card option
          _buildPaymentOption(
            index: 0,
            title: 'Credit/Debit Card',
            subtitle: 'Pay with Visa, Mastercard, etc.',
            icon: Icons.credit_card,
          ),
          
          // PayPal option
          _buildPaymentOption(
            index: 1,
            title: 'PayPal',
            subtitle: 'Pay with your PayPal account',
            icon: Icons.payments_outlined,
          ),
          
          // Cash option
          _buildPaymentOption(
            index: 2,
            title: 'Cash on Delivery',
            subtitle: 'Pay when your order arrives',
            icon: Icons.money,
          ),
          
          const SizedBox(height: 24),
          
          // Form for selected payment method
          if (_selectedPaymentMethod == 0) ...[
            const Text(
              'Card Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Card number
            CustomTextField(
              label: 'Card Number',
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.credit_card),
              hintText: '1234 5678 9012 3456',
            ),
            const SizedBox(height: 16),
            
            // Card holder
            CustomTextField(
              label: 'Card Holder',
              controller: _cardHolderController,
              prefixIcon: const Icon(Icons.person_outline),
              hintText: 'John Doe',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            // Expiry date and CVV
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Expiry Date',
                    controller: _expiryDateController,
                    keyboardType: TextInputType.datetime,
                    prefixIcon: const Icon(Icons.calendar_today),
                    hintText: 'MM/YY',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'CVV',
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.security),
                    hintText: '123',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Billing address
            const Text(
              'Billing Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Address
            CustomTextField(
              label: 'Street Address',
              controller: _addressController,
              prefixIcon: const Icon(Icons.home_outlined),
              hintText: '123 Main St',
            ),
            const SizedBox(height: 16),
            
            // City and zip
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'City',
                    controller: _cityController,
                    prefixIcon: const Icon(Icons.location_city),
                    hintText: 'New York',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Zip Code',
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                    hintText: '10001',
                  ),
                ),
              ],
            ),
          ] else if (_selectedPaymentMethod == 1) ...[
            // PayPal placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 64,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You will be redirected to PayPal to complete your payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ] else if (_selectedPaymentMethod == 2) ...[
            // Cash on delivery info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.money,
                    size: 64,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You will pay the exact amount when your order is delivered',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
          
          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Order summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Subtotal', '\$${total.toStringAsFixed(2)}'),
                _buildSummaryRow('Delivery Fee', '\$2.99'),
                _buildSummaryRow('Tax', '\$${(total * 0.08).toStringAsFixed(2)}'),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Total',
                  '\$${totalWithTaxAndDelivery.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment button
          PrimaryButton(
            text: 'Pay \$${totalWithTaxAndDelivery.toStringAsFixed(2)}',
            onPressed: _processPayment,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          
          // Cancel button
          SecondaryButton(
            text: 'Cancel',
            onPressed: () {
              context.go('/cart');
            },
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildPaymentOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: index,
              groupValue: _selectedPaymentMethod,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value as int;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.primaryTextColor : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.primaryColor : AppTheme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
} 