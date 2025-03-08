import 'dart:async';
import 'package:karvaan/services/database/mongodb_connection.dart';

/// Service to monitor database connection status
class DatabaseMonitor {
  static final DatabaseMonitor _instance = DatabaseMonitor._internal();
  factory DatabaseMonitor() => _instance;
  DatabaseMonitor._internal();

  bool _isMonitoring = false;
  Timer? _pingTimer;
  
  final StreamController<bool> _connectionStatusController = 
      StreamController<bool>.broadcast();

  /// Stream of connection status (true = connected, false = disconnected)
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// Start monitoring the database connection
  void startMonitoring({Duration pingInterval = const Duration(minutes: 5)}) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _pingTimer = Timer.periodic(pingInterval, (_) => _pingDatabase());
    
    // Initial ping
    _pingDatabase();
  }

  /// Stop monitoring
  void stopMonitoring() {
    _pingTimer?.cancel();
    _isMonitoring = false;
  }

  /// Ping the database to check connection
  Future<void> _pingDatabase() async {
    try {
      final db = await MongoDBConnection.database;
      final isConnected = db.isConnected;
      _connectionStatusController.add(isConnected);
      
      if (!isConnected) {
        // Try to reconnect if not connected
        await MongoDBConnection.resetConnection();
      }
    } catch (e) {
      print('Database ping error: $e');
      _connectionStatusController.add(false);
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _connectionStatusController.close();
  }
}
