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
    final bool disabled = isLoading || onPressed == null;
    final EdgeInsetsGeometry effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20);
    final Color gradientStart = backgroundColor ?? AppTheme.primaryColor;
    final Color gradientEnd = backgroundColor != null
        ? backgroundColor!.withOpacity(0.9)
        : AppTheme.accentColorDark;
    final Color effectiveTextColor =
        textColor ?? (isOutlined ? theme.colorScheme.primary : Colors.white);

    Widget child = isLoading
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
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Text(text, overflow: TextOverflow.ellipsis);

    if (!isOutlined) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: disabled
                ? [Colors.white24, Colors.white24]
                : [gradientStart, gradientEnd],
          ),
          boxShadow: [
            if (!disabled)
              BoxShadow(
                color: gradientStart.withOpacity(0.28),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
          ],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: effectivePadding,
          child: DefaultTextStyle(
            style: theme.textTheme.labelLarge!.copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.w600,
            ),
            child: IconTheme(
              data: IconThemeData(color: effectiveTextColor, size: 18),
              child: Center(child: child),
            ),
          ),
        ),
      );
    } else {
      child = Container(
        padding: effectivePadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.6)),
          color: Colors.white.withOpacity(0.04),
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.labelLarge!.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w600,
          ),
          child: IconTheme(
            data: IconThemeData(color: effectiveTextColor, size: 18),
            child: Center(child: child),
          ),
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onPressed,
            splashColor: AppTheme.accentColor.withOpacity(0.2),
            child: child,
          ),
        ),
      ),
    );
  }
}
