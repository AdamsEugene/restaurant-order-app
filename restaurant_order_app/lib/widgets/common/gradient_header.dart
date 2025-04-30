import 'package:flutter/material.dart';
import '../../config/theme.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onLeftIconPressed;
  final VoidCallback? onRightIconPressed;
  final Widget? bottomChild;
  final double height;
  final double borderRadius;

  const GradientHeader({
    Key? key,
    required this.title,
    this.leftIcon,
    this.rightIcon,
    this.onLeftIconPressed,
    this.onRightIconPressed,
    this.bottomChild,
    this.height = 180,
    this.borderRadius = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Gradient Background
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.primaryGradient,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius),
            ),
          ),
        ),
        
        // Bottom child (if provided)
        if (bottomChild != null)
          Positioned(
            top: height - 60,
            child: bottomChild!,
          ),
        
        // Title and Icons
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left icon
                if (leftIcon != null)
                  IconButton(
                    onPressed: onLeftIconPressed,
                    icon: Icon(leftIcon, color: Colors.white),
                  )
                else
                  const SizedBox(width: 48),
                
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Right icon
                if (rightIcon != null)
                  IconButton(
                    onPressed: onRightIconPressed,
                    icon: Icon(rightIcon, color: Colors.white),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 