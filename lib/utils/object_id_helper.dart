import 'package:mongo_dart/mongo_dart.dart';

/// Helper class to handle ObjectId conversions safely
class ObjectIdHelper {
  /// Convert String to ObjectId safely
  static ObjectId fromString(String id) {
    try {
      return ObjectId.parse(id);
    } catch (e) {
      throw FormatException('Invalid ObjectId format: $id');
    }
  }

  /// Convert ObjectId to String safely
  static String toString(ObjectId id) {
    return id.toHexString();
  }

  /// Check if a string is a valid ObjectId
  static bool isValid(String id) {
    try {
      ObjectId.parse(id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Create a new ObjectId
  static ObjectId generate() {
    return ObjectId();
  }
}
