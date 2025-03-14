import 'package:flutter/material.dart';
import 'package:karvaan/screens/auth/login_screen.dart';
import 'package:karvaan/screens/auth/register_screen.dart';
import 'package:karvaan/navigation/app_navigation.dart';
import 'package:karvaan/screens/auth/forgot_password_screen.dart';
import 'package:karvaan/screens/auth/change_password_screen.dart';
import 'package:karvaan/screens/home/home_screen.dart';
import 'package:karvaan/screens/profile/profile_screen.dart';
import 'package:karvaan/screens/settings/settings_screen.dart';
import 'package:karvaan/screens/splash_screen.dart';
import 'package:karvaan/screens/vehicles/add_vehicle_screen.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';

class AppRoutes {
  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main app flow
  static const String splash = '/splash';
  static const String main = '/main';
  static const String home = '/home';
  static const String profile = '/profile';
  
  // Vehicle routes
  static const String vehiclesList = '/vehicles';
  static const String addVehicle = '/vehicles/add';
  static const String vehicleDetails = '/vehicles/details';
  static const String vehicleDetail = '/vehicle/detail';
  
  // Fuel routes
  static const String addFuelEntry = '/fuel/add';
  static const String fuelEntries = '/fuel/list';
  
  // Service routes
  static const String services = '/services';
  static const String addService = '/services/add';
  
  // Settings and other routes
  static const String settings = '/settings';
  static const String settingsRoute = '/settings/main';
  static const String about = '/about';
  static const String changePassword = '/change-password';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        // Check if we have a message to pass to the login screen
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => LoginScreen(
              message: args['message'] as String?,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case main:
        // Return the AppNavigation widget for the main route
        return MaterialPageRoute(builder: (_) => const AppNavigation());
      case home:
        return MaterialPageRoute(builder: (_) => const AppNavigation(initialIndex: 0));
      case addVehicle:
        return MaterialPageRoute(
          builder: (_) => const AddVehicleScreen(),
        );
      case vehicleDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VehicleDetailScreen(
            vehicleId: args['vehicleId'] as String,
            vehicleName: args['vehicleName'] as String,
            registrationNumber: args['registrationNumber'] as String,
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const AppNavigation(initialIndex: 3));
      case settingsRoute: // Changed name here
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      default:
        // For routes that aren't implemented yet, just show a placeholder
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(settings.name ?? 'Unknown Screen')),
            body: Center(
              child: Text('Route ${settings.name} not implemented yet'),
            ),
          ),
        );
    }
  }
}
