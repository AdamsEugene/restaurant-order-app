import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_order_app/config/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? leading;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.elevation = 0,
    this.centerTitle = true,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      leading: _buildLeading(context),
      actions: actions,
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!showBackButton) return leading;
    
    if (leading != null) return leading;
    
    // Check if we can pop from the current route
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    
    if (canPop || context.canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBackPressed ?? () {
          if (context.canPop()) {
            context.pop();
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            // If we can't pop, navigate to home as a fallback
            context.go('/home');
          }
        },
      );
    } else {
      // If we can't pop, show a back button that goes to home
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBackPressed ?? () {
          context.go('/home');
        },
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null 
      ? kToolbarHeight + bottom!.preferredSize.height 
      : kToolbarHeight);
} 