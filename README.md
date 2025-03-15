# Karvaan - Vehicle Management App

Karvaan is a comprehensive vehicle management app designed to help vehicle owners track and manage various aspects of their vehicles, including maintenance, fuel consumption, expenses, and more.

## Features

### Core Features
- **Vehicle Management**: Add and manage multiple vehicles with detailed information
- **Service Tracking**: Log and track maintenance services
- **Fuel Tracking**: Monitor fuel consumption and expenses
- **Expense Analytics**: Get insights into your vehicle expenses
- **Performance Metrics**: Track vehicle performance over time
- **Document Management**: Store important vehicle documents

### Latest Additions (v1.5.x)
- **Live Engine Statistics**: Real-time monitoring of engine performance metrics
  - Engine RPM, Vehicle Speed, and Load Value
  - Coolant and Intake Air Temperature
  - Fuel System Status and Pressure
  - Throttle Position and Timing
  - Oxygen Sensor Data
- **Enhanced UI/UX**:
  - Grid-based metrics display in home and vehicle screens
  - Improved loading animations
  - Supporting text for better user guidance
  - Streamlined navigation

### Security & Performance
- **Secure Authentication**: Password hashing for enhanced security
- **Profile Management**: Updated profile editing capabilities
- **Optimized Performance**: Improved data loading and display

## Screenshots

(Screenshots will be added here)

## Tech Stack

- Flutter
- Dart
- SQLite (Local storage)
- Firebase (Backend - planned for future)

## Project Structure

```
karvaan/
├── lib/
│   ├── main.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── routes/
│   │   └── app_routes.dart
│   ├── navigation/
│   │   └── app_navigation.dart
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── confirm_dialog.dart
│   │   └── stats_card.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── vehicles/
│   │   │   ├── vehicles_list_screen.dart
│   │   │   ├── vehicle_detail_screen.dart
│   │   │   └── add_vehicle_screen.dart
│   │   ├── services/
│   │   │   ├── services_screen.dart
│   │   │   ├── service_detail_screen.dart
│   │   │   └── add_service_record_screen.dart
│   │   ├── fuel/
│   │   │   ├── fuel_history_screen.dart
│   │   │   └── add_fuel_entry_screen.dart
│   │   ├── analytics/
│   │   │   └── analytics_dashboard.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
└── assets/
    ├── images/
    └── fonts/
```

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- Android Emulator / iOS Simulator or physical device

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/karvaan.git
```

2. Navigate to the project directory:
```bash
cd karvaan
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Material Design](https://material.io/design)