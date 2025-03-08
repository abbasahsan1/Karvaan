import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:karvaan/utils/caching_helper.dart';

/// Base repository class with caching and batching support
abstract class BaseRepository<T> {
  final String collectionName;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T item) toJson;
  
  BaseRepository({
    required this.collectionName,
    required this.fromJson,
    required this.toJson,
  });
  
  /// Get DB collection
  Future<DbCollection> get collection async {
    return await MongoDBConnection.getCollection(collectionName);
  }
  
  /// Find items with caching support
  Future<List<T>> find(
    Map<String, dynamic> query, {
    bool useCache = true,
    String? cacheKey,
    Duration cacheDuration = const Duration(minutes: 10),
  }) async {
    final key = cacheKey ?? 'find_${collectionName}_${query.hashCode}';
    
    // Try to get from cache first
    if (useCache) {
      final cached = await CachingHelper.getFromCache<List<dynamic>>(key);
      if (cached != null) {
        return cached.map((data) => fromJson(data)).toList();
      }
    }
    
    // Get from database
    final coll = await collection;
    final results = await coll.find(query).toList();
    
    // Cache the results
    if (useCache) {
      await CachingHelper.saveToCache(
        key: key,
        data: results,
        expiration: cacheDuration,
      );
    }
    
    return results.map((data) => fromJson(data)).toList();
  }
  
  /// Insert items in batch for better performance
  Future<List<T>> insertBatch(List<T> items) async {
    if (items.isEmpty) return [];
    
    final coll = await collection;
    final documents = items.map(toJson).toList();
    
    final result = await coll.insertAll(documents);
    
    return items.asMap().map((index, item) {
      if (result[index] != null) {
        final updatedJson = toJson(item);
        updatedJson['_id'] = result[index];
        return MapEntry(index, fromJson(updatedJson));
      }
      return MapEntry(index, item);
    }).values.toList();
  }
}
