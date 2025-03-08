import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper class for SSL certificate handling
class SSLHelper {
  /// Initialize SSL certificate handling for the app
  static void initialize() {
    // Skip for web platform since it has different certificate handling
    if (!kIsWeb) {
      HttpOverrides.global = _CertificateHandler();
      print('SSL certificate override initialized for non-web platform');
    }
  }
}

/// Custom HTTP overrides class to handle certificate validation
class _CertificateHandler extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Always accept certificates for MongoDB Atlas connections
        print('Accepting certificate for $host:$port');
        return true;
      };
  }
}
