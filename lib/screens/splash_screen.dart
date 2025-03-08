import 'package:flutter/material.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/services/database/database_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/utils/connectivity_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isInitializing = true;
  String? _errorMessage;
  bool _retrying = false;
  int _retryCount = 0;
  final int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_retryCount >= _maxRetries) {
      setState(() {
        _errorMessage = "Failed to connect to database after multiple attempts";
        _isInitializing = false;
        _retrying = false;
      });
      return;
    }

    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
        if (_retryCount > 0) _retrying = true;
      });

      // Check internet connectivity first
      final hasInternet = await ConnectivityHelper.hasInternetConnection();
      if (!hasInternet) {
        throw Exception('No internet connection');
      }

      // Initialize database
      final dbInitialized = await _databaseService.initializeDatabase();
      if (!dbInitialized) {
        throw Exception('Database initialization failed');
      }

      // Wait a bit for the splash screen to be visible
      await Future.delayed(const Duration(seconds: 2));

      // CHANGED: Always navigate to login screen instead of checking logged in status
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        _retryCount++;
        
        if (_retryCount < _maxRetries) {
          print("Connection failed, retrying... (${_retryCount}/${_maxRetries})");
          setState(() {
            _retrying = true;
            _errorMessage = "Connection failed, retrying... (${_retryCount}/${_maxRetries})";
          });
          
          // Retry after a delay
          await Future.delayed(Duration(seconds: 2));
          _initialize(); 
        } else {
          setState(() {
            _errorMessage = e.toString();
            _isInitializing = false;
            _retrying = false;
          });
        }
      }
    }
  }

  // Retry connection manually
  void _retryConnection() {
    _retryCount = 0;
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo would go here
              const Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Karvaan',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null && !_retrying)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _retryConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text("Retry Connection"),
                      )
                    ],
                  ),
                ),
              if (_isInitializing || _retrying)
                Column(
                  children: [
                    if (_retrying)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage ?? "Connecting...",
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
