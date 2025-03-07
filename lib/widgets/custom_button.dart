import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isFullWidth;
  final double height;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.height = 50,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        height: height,
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: onPressed,
          child: buttonChild,
        ),
      );
    } else {
      return SizedBox(
        height: height,
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: buttonChild,
        ),
      );
    }
  }
}
