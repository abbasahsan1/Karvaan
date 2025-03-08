import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Helper class to check network connectivity
class ConnectivityHelper {
  /// Check if the device has an internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      if (kIsWeb) {
        // For web, we can't use InternetAddress.lookup
        // Just assume connectivity and let the request fail if there's no connection
        return true;
      }
      
      // Try to connect to a reliable host
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
          
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      // No internet connection
      return false;
    } on TimeoutException catch (_) {
      // Connection timed out
      return false;
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }

  /// Return the appropriate error message based on connectivity
  static String getConnectionErrorMessage() {
    return 'Could not connect to the server. Please check your internet connection and try again.';
  }

  /// Retry a function with exponential backoff
  static Future<T> withRetry<T>(
    Future<T> Function() function, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (true) {
      try {
        return await function();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait with exponential backoff before retrying
        await Future.delayed(delay);
        delay *= 2; // Double the delay for each retry
      }
    }
  }
}
