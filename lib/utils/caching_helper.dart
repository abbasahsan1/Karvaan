import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for caching data
class CachingHelper {
  /// Save data to cache with expiration
  static Future<bool> saveToCache<T>({
    required String key,
    required T data,
    Duration expiration = const Duration(hours: 1),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTime = DateTime.now().add(expiration).millisecondsSinceEpoch;
      
      final cacheData = {
        'data': data,
        'expiry': expiryTime,
      };
      
      final String jsonData = jsonEncode(cacheData);
      return await prefs.setString('cache_$key', jsonData);
    } catch (e) {
      print('Error saving to cache: $e');
      return false;
    }
  }

  /// Get data from cache if not expired
  static Future<T?> getFromCache<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('cache_$key');
      
      if (jsonData == null) return null;
      
      final cacheData = jsonDecode(jsonData);
      final expiry = cacheData['expiry'] as int;
      
      // Check if expired
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await prefs.remove('cache_$key');
        return null;
      }
      
      return cacheData['data'] as T;
    } catch (e) {
      print('Error getting from cache: $e');
      return null;
    }
  }
  
  /// Clear all cached data
  static Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await prefs.remove(key);
        }
      }
      
      return true;
    } catch (e) {
      print('Error clearing cache: $e');
      return false;
    }
  }
}
