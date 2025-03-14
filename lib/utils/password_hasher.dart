import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static const int _saltLength = 16;
  static const int _iterations = 1000;

  // Generate salt for password hashing
  static Uint8List _generateSalt() {
    final random = List<int>.generate(_saltLength, (i) => DateTime.now().microsecondsSinceEpoch % 256);
    return Uint8List.fromList(random);
  }

  // Hash password using PBKDF2 with SHA-256
  static Future<String> hashPassword(String password) async {
    try {
      final salt = _generateSalt();
      
      // Use PBKDF2 with SHA-256
      final key = _pbkdf2(password, salt, _iterations);
      
      // Encode as base64 for storage
      final saltBase64 = base64.encode(salt);
      final hashBase64 = base64.encode(key);
      
      // Create a combined hash string that includes parameters and salt
      return 'pbkdf2:$_iterations:$saltBase64:$hashBase64';
    } catch (e) {
      throw Exception('Failed to hash password: $e');
    }
  }

  // Implementation of PBKDF2 using crypto package
  static List<int> _pbkdf2(String password, List<int> salt, int iterations) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final output = List<int>.filled(32, 0); // 32 bytes output (SHA-256)
    
    // PBKDF2 implementation with one block
    var block = List<int>.from(salt);
    block.addAll([0, 0, 0, 1]); // Append block number (1)
    
    // Initialize prev as a List<int> to fix the type error
    var prev = <int>[];
    var current = hmac.convert(block).bytes;
    
    for (var i = 0; i < iterations; i++) {
      // Explicitly cast or create a new List<int> to ensure type safety
      prev = List<int>.from(current);
      current = hmac.convert(prev).bytes;
      
      for (var j = 0; j < output.length; j++) {
        output[j] ^= current[j]; // XOR operation
      }
    }
    
    return output;
  }

  // Verify password against stored hash
  static Future<bool> verifyPassword(String password, String storedHash) async {
    try {
      // Parse the stored hash format
      final parts = storedHash.split(':');
      if (parts.length != 4 || parts[0] != 'pbkdf2') {
        return false; // Invalid format
      }

      final iterations = int.parse(parts[1]);
      final salt = base64.decode(parts[2]);
      final expectedHash = base64.decode(parts[3]);

      // Hash the input password with the same salt and parameters
      final key = _pbkdf2(password, salt, iterations);

      // Compare the hashes using constant-time comparison
      if (key.length != expectedHash.length) {
        return false;
      }

      // Constant-time comparison to prevent timing attacks
      int difference = 0;
      for (var i = 0; i < key.length; i++) {
        difference |= key[i] ^ expectedHash[i];
      }
      return difference == 0;
    } catch (e) {
      return false;
    }
  }
  
  // For migration from plain text to hashed passwords
  static bool isPasswordHashed(String passwordValue) {
    return passwordValue.startsWith('pbkdf2:');
  }
}
