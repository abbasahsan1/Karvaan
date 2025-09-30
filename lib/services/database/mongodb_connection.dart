import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/utils/connectivity_helper.dart';

class MongoDBConnection {
  static final MongoDBConnection _instance = MongoDBConnection._internal();
  static Db? _db;

  // Collection names
  static const String usersCollection = 'users';
  static const String vehiclesCollection = 'vehicles';
  static const String fuelEntriesCollection = 'fuel_entries';
  static const String servicesCollection = 'service_records';
  static const String engineStatsCollection = 'engine_stats';
  static const String serviceLocationsCollection = 'service_locations';

  // Direct MongoDB connection string
  static const String _mongoUri = 'mongodb://abbasahsan1:2103040@karvaanapp-shard-00-00.da1dd.mongodb.net:27017,karvaanapp-shard-00-01.da1dd.mongodb.net:27017,karvaanapp-shard-00-02.da1dd.mongodb.net:27017/karvaan?ssl=true&replicaSet=atlas-2xolaj-shard-0&authSource=admin&retryWrites=true&w=majority';
  
  // Connection state
  static bool _isConnecting = false;
  static final Completer<void> _connectionCompleter = Completer<void>();

  // Private constructor
  MongoDBConnection._internal();

  // Factory constructor
  factory MongoDBConnection() {
    return _instance;
  }

  // Access to the database instance with retry logic
  static Future<Db> get database async {
    // If already connected, return the database
    if (_db != null && _db!.isConnected) {
      return _db!;
    }
    
    // If connection is in progress, wait for it to complete
    if (_isConnecting) {
      await _connectionCompleter.future;
      if (_db != null && _db!.isConnected) {
        return _db!;
      }
    }
    
    // Start a new connection
    _isConnecting = true;
    
    try {
      // Check internet connectivity first
      final hasConnection = await ConnectivityHelper.hasInternetConnection();
      if (!hasConnection) {
        throw Exception('No internet connection');
      }
      
      _db = await ConnectivityHelper.withRetry(
        _initializeDb,
        maxRetries: 3,
        initialDelay: const Duration(seconds: 1),
      );
      
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.complete();
      }
      
      return _db!;
    } catch (e) {
      _isConnecting = false;
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.completeError(e);
      }
      print('MongoDB connection failed after retries: $e');
      rethrow;
    }
  }

  static Future<Db> _initializeDb() async {
    try {
      print('Connecting to MongoDB database...');
      
      // Create the connection
      final db = Db(_mongoUri);
      
      // Open with options based on platform
      await db.open();
      
      print('Connected to MongoDB Atlas successfully!');
      return db;
    } catch (e) {
      print('MongoDB connection error: $e');
      throw Exception('Failed to connect to MongoDB: $e');
    }
  }
  
  // Get collection by name
  static Future<DbCollection> getCollection(String collectionName) async {
    final db = await database;
    return db.collection(collectionName);
  }
  
  // Reset connection (useful for testing or after errors)
  static Future<void> resetConnection() async {
    await close();
    _isConnecting = false;
  }
  
  // Close the connection
  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      _db = null;
    }
  }
}
