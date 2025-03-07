import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.cancelText = 'CANCEL',
    this.confirmText = 'CONFIRM',
    required this.onConfirm,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: Text(cancelText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(
            confirmText,
            style: TextStyle(
              color: isDestructive ? AppTheme.accentRedColor : null,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }

  // Helper method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'CANCEL',
    String confirmText = 'CONFIRM',
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
      ),
    );
  }
}
