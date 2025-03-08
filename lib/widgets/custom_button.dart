import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData? icon;
  final bool isFullWidth; // Add the missing parameter

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.icon,
    this.isFullWidth = true, // Set default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = isOutlined ? Colors.transparent : theme.colorScheme.primary;
    final defaultTextColor = isOutlined ? theme.colorScheme.primary : Colors.white;
    final effectiveBackgroundColor = backgroundColor ?? defaultBackgroundColor;
    final effectiveTextColor = textColor ?? defaultTextColor;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isOutlined
                ? BorderSide(color: theme.colorScheme.primary)
                : BorderSide.none,
          ),
          elevation: isOutlined ? 0 : 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                      Text(text),
                    ],
                  )
                : Text(text),
      ),
    );
  }
}
