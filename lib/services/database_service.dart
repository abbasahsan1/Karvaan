import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';

/// Service to handle database operations
class DatabaseService {
  // Singleton pattern
  DatabaseService._privateConstructor();
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  static DatabaseService get instance => _instance;

  // Get a collection from the database
  Future<DbCollection> getCollection(String collectionName) async {
    try {
      final db = await MongoDBConnection.database;
      return db.collection(collectionName);
    } catch (e) {
      log('Error getting collection: $e');
      throw Exception('Failed to get collection: $e');
    }
  }

  // Perform a health check on the database connection
  Future<bool> checkDatabaseHealth() async {
    try {
      final db = await MongoDBConnection.database;
      return db.isConnected;
    } catch (e) {
      log('Database health check error: $e');
      return false;
    }
  }
}