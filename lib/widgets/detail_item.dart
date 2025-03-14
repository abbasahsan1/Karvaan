import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';

class DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailingWidget;

  const DetailItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (trailingWidget != null) trailingWidget!,
        ],
      ),
    );
  }
}
