import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_order_app/config/theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final AutovalidateMode autovalidateMode;

  const CustomTextField({
    Key? key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.onChanged,
    this.inputFormatters,
    this.hintText,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }
  
  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _hasError
                ? AppTheme.errorColor
                : (_isFocused ? AppTheme.primaryColor : AppTheme.secondaryTextColor),
          ),
        ),
        const SizedBox(height: 8),
        
        // Text field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: TextStyle(
              fontSize: 16,
              color: widget.enabled
                  ? AppTheme.primaryTextColor
                  : AppTheme.secondaryTextColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              prefixText: widget.prefixText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
              
              // Reset error state when the user types
              if (_hasError && widget.validator != null) {
                final error = widget.validator!(value);
                if (error == null) {
                  setState(() {
                    _hasError = false;
                  });
                }
              }
            },
            validator: (value) {
              if (widget.validator != null) {
                final error = widget.validator!(value);
                // Don't call setState during build, use post-frame callback instead
                if (_hasError != (error != null)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _hasError = error != null;
                      });
                    }
                  });
                }
                return error;
              }
              return null;
            },
            autovalidateMode: widget.autovalidateMode,
            inputFormatters: widget.inputFormatters,
          ),
        ),
      ],
    );
  }
  
  Color _getBorderColor() {
    if (_hasError) {
      return AppTheme.errorColor;
    }
    
    if (_isFocused) {
      return AppTheme.primaryColor;
    }
    
    return Colors.grey[300]!;
  }
} 