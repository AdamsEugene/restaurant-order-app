import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/buttons/primary_button.dart';

class SubmitReceiptCodeScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderDetails;

  const SubmitReceiptCodeScreen({
    Key? key,
    required this.orderId,
    required this.orderDetails,
  }) : super(key: key);

  @override
  State<SubmitReceiptCodeScreen> createState() => _SubmitReceiptCodeScreenState();
}

class _SubmitReceiptCodeScreenState extends State<SubmitReceiptCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  String? _errorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto focus the code input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _validateCode() {
    // Get the entered code
    final enteredCode = _codeController.text.trim();
    
    // Get the expected code from the order details
    final correctCode = widget.orderDetails['receiptCode'] as String? ?? '1234';
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      if (enteredCode.isEmpty) {
        setState(() {
          _errorText = 'Please enter the receipt code';
          _isLoading = false;
        });
      } else if (enteredCode != correctCode) {
        setState(() {
          _errorText = 'Invalid code. Please try again';
          _isLoading = false;
        });
      } else {
        // Code is correct, navigate to the order complete screen
        context.go('/order-complete/${widget.orderId}', extra: widget.orderDetails);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Receipt Code'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Heading
              Text(
                'Verify Your Order',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Enter the receipt code provided by the restaurant staff to complete your order.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Code input field
              TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                decoration: InputDecoration(
                  labelText: 'Receipt Code',
                  hintText: 'Enter the 4-digit code',
                  errorText: _errorText,
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 4,
                onSubmitted: (_) => _validateCode(),
              ),
              
              const SizedBox(height: 24),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Verify Code',
                        onPressed: _validateCode,
                      ),
              ),
              
              const Spacer(),
              
              // Having trouble text
              Text(
                'Having trouble with your order?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              TextButton(
                onPressed: () {
                  // In a real app, this would open a help screen or chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 