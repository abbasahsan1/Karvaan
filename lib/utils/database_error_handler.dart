import 'dart:io';
import 'package:flutter/material.dart';

/// Class to handle database errors gracefully
class DatabaseErrorHandler {
  /// Parse errors and return user-friendly messages
  static String getUserFriendlyErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Network error: Unable to reach database server. Please check your internet connection.';
    }
    else if (error.toString().contains('authentication failed')) {
      return 'Authentication failed. Please check your database credentials.';
    }
    else if (error.toString().contains('connection timeout')) {
      return 'Connection timed out. The server might be temporarily unavailable.';
    }
    else {
      return 'Database error: ${error.toString().split(':').last.trim()}';
    }
  }

  /// Show error dialog to user
  static void showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Error'),
        content: Text(getUserFriendlyErrorMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
