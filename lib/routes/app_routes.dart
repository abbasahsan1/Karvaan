import 'package:flutter/material.dart';
import 'package:karvaan/navigation/app_navigation.dart';
import 'package:karvaan/screens/analytics/analytics_dashboard.dart';
import 'package:karvaan/screens/auth/forgot_password_screen.dart';
import 'package:karvaan/screens/auth/login_screen.dart';
import 'package:karvaan/screens/auth/signup_screen.dart';
import 'package:karvaan/screens/fuel/add_fuel_entry_screen.dart';
import 'package:karvaan/screens/fuel/fuel_history_screen.dart';
import 'package:karvaan/screens/home/home_screen.dart';
import 'package:karvaan/screens/profile/profile_screen.dart';
import 'package:karvaan/screens/services/add_service_record_screen.dart';
import 'package:karvaan/screens/services/service_detail_screen.dart';
import 'package:karvaan/screens/services/services_screen.dart';
import 'package:karvaan/screens/settings/settings_screen.dart';
import 'package:karvaan/screens/splash_screen.dart';
import 'package:karvaan/screens/vehicles/add_vehicle_screen.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';
import 'package:karvaan/screens/vehicles/vehicles_list_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
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
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const AppNavigation());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case addVehicle:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddVehicleScreen(
            existingVehicle: args?['existingVehicle'],
          ),
        );
      case vehicleDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VehicleDetailScreen(
            vehicleName: args['vehicleName'],
            registrationNumber: args['registrationNumber'],
          ),
        );
      case vehiclesList:
        return MaterialPageRoute(builder: (_) => const VehiclesListScreen());
      case addService:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddServiceRecordScreen(
            existingService: args?['existingService'],
            vehicleId: args?['vehicleId'],
          ),
        );
      case serviceDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(
            serviceId: args['serviceId'],
          ),
        );
      case services:
        return MaterialPageRoute(builder: (_) => const ServicesScreen());
      case addFuel:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddFuelEntryScreen(
            existingEntry: args?['existingEntry'],
            vehicleId: args?['vehicleId'],
          ),
        );
      case fuelHistory:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FuelHistoryScreen(
            vehicleId: args?['vehicleId'],
          ),
        );
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsDashboard());
      case AppRoutes.settings: // Fixed: Use the constant AppRoutes.settings instead of the variable settings
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
