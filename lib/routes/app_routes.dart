import 'package:flutter/material.dart';
import 'package:karvaan/screens/auth/login_screen.dart';
import 'package:karvaan/screens/auth/register_screen.dart';
import 'package:karvaan/navigation/app_navigation.dart';
import 'package:karvaan/screens/auth/forgot_password_screen.dart';
import 'package:karvaan/screens/home/home_screen.dart';
import 'package:karvaan/screens/profile/profile_screen.dart';
import 'package:karvaan/screens/settings/settings_screen.dart';
import 'package:karvaan/screens/splash_screen.dart';
import 'package:karvaan/screens/vehicles/add_vehicle_screen.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String main = '/main';
  static const String addVehicle = '/add-vehicle';
  static const String vehicleDetail = '/vehicle-detail';
  static const String vehiclesList = '/vehicles-list';
  static const String addService = '/add-service';
  static const String serviceDetail = '/service-detail';
  static const String services = '/services';
  static const String addFuel = '/add-fuel';
  static const String fuelHistory = '/fuel-history';
  static const String analytics = '/analytics';
  static const String settingsRoute = '/settings'; // Changed name here
  static const String profile = '/profile';
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
            vehicleName: args['vehicleName'] as String,
            registrationNumber: args['registrationNumber'] as String,
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const AppNavigation(initialIndex: 3));
      case settingsRoute: // Changed name here
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
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
