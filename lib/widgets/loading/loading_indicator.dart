import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final bool isFullScreen;
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;

  const LoadingIndicator({
    Key? key,
    this.size = 50,
    this.isFullScreen = false,
    this.message,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppTheme.primaryColor,
            ),
            strokeWidth: 4,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: isFullScreen ? Colors.white : AppTheme.primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Container(
        color: backgroundColor ?? Colors.black.withOpacity(0.7),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: content,
        ),
      );
    }

    return content;
  }
}

// A wrapper class for overlay loading indicator
class OverlayLoadingIndicator {
  static OverlayEntry? _overlayEntry;

  // Show the loading overlay
  static void show(
    BuildContext context, {
    String? message,
  }) {
    if (_overlayEntry != null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingIndicator(
        isFullScreen: true,
        message: message,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Hide the loading overlay
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
} 