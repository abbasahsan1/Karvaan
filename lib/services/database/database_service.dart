import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Service to handle database initialization and checks
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  // Factory constructor
  factory DatabaseService() => _instance;
  
  // Private constructor
  DatabaseService._internal();
  
  /// Initialize the database connection and verify it works
  Future<bool> initializeDatabase() async {
    try {
      // Try to get the users collection to verify connection
      final collection = await MongoDBConnection.getCollection(MongoDBConnection.usersCollection);
      
      // Try a simple query to verify it's working
      await collection.findOne();
      
      print('Database initialization successful');
      return true;
    } catch (e) {
      print('Database initialization error: $e');
      return false;
    }
  }
  
  /// Perform a health check on the database connection
  Future<bool> checkDatabaseHealth() async {
    try {
      final db = await MongoDBConnection.database;
      final isConnected = db.isConnected;
      
      if (!isConnected) {
        // Try to reconnect if not connected
        await MongoDBConnection.resetConnection();
        final reconnected = (await MongoDBConnection.database).isConnected;
        return reconnected;
      }
      
      return isConnected;
    } catch (e) {
      print('Database health check error: $e');
      return false;
    }
  }
}
