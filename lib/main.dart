import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/routes/app_routes.dart';

void main() {
  runApp(const KarvaanApp());
}

class KarvaanApp extends StatelessWidget {
  const KarvaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karvaan',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
