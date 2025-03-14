import 'package:flutter/material.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/providers/user_provider.dart';
import 'package:karvaan/services/engine_stats_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/widgets/engine_stat_card.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';
import 'package:karvaan/screens/vehicles/add_vehicle_screen.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EngineStatsService _engineStatsService = EngineStatsService.instance;
  EngineStatsModel? _liveStats;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    // Access user provider to get current user data
    final userProvider = Provider.of<UserProvider>(context);
    
    return Column(
      children: [
        // Home screen content here
        // No AppBar in this widget since the parent (AppNavigation) provides it
        Expanded(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting with dynamic user name
                  Text(
                    'Hi ${userProvider.displayName}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  Text(
                    'Welcome to Karvaan',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildEngineStatsSection(),
                  const SizedBox(height: 24),
                  _buildMyVehiclesSection(context),
                  const SizedBox(height: 24),
                  _buildUpcomingMaintenanceSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Hello, John',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Welcome back to your vehicle dashboard',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEngineStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Engine Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomButton(
                text: 'Measure Live Stats',
                onPressed: _generateRandomEngineStats,
                isLoading: _isLoading,
                icon: Icons.speed,
                isFullWidth: false,
                height: 36,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_liveStats != null) _buildEngineStatsDisplay() else _buildNoStatsMessage(),
      ],
    );
  }
  
  Widget _buildNoStatsMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No engine stats available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Press the "Measure Live Stats" button to generate demo engine statistics.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Measure Live Stats',
              onPressed: _generateRandomEngineStats,
              isLoading: _isLoading,
              icon: Icons.speed,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEngineStatsDisplay() {
    if (_liveStats == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        EngineStatGroup(
          title: 'Engine Performance',
          icon: Icons.speed,
          children: [
            EngineStatCard(
              title: 'Engine RPM',
              value: _liveStats!.engineRpm.toStringAsFixed(0),
              icon: Icons.speed,
              unit: 'RPM',
              color: AppTheme.primaryColor,
            ),
            EngineStatCard(
              title: 'Vehicle Speed',
              value: _liveStats!.vehicleSpeed.toStringAsFixed(1),
              icon: Icons.directions_car,
              unit: 'km/h',
              color: Colors.blue,
            ),
            EngineStatCard(
              title: 'Calculated Load',
              value: _liveStats!.calculatedLoadValue.toStringAsFixed(1),
              icon: Icons.trending_up,
              unit: '%',
              color: Colors.orange,
            ),
            EngineStatCard(
              title: 'Throttle Position',
              value: _liveStats!.absoluteThrottlePosition.toStringAsFixed(1),
              icon: Icons.speed,
              unit: '%',
              color: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EngineStatGroup(
          title: 'Temperature & Air',
          icon: Icons.thermostat,
          children: [
            EngineStatCard(
              title: 'Coolant Temp',
              value: _liveStats!.coolantTemperature.toStringAsFixed(1),
              icon: Icons.thermostat,
              unit: '°C',
              color: Colors.red,
            ),
            EngineStatCard(
              title: 'Intake Air Temp',
              value: _liveStats!.intakeAirTemperature.toStringAsFixed(1),
              icon: Icons.air,
              unit: '°C',
              color: Colors.lightBlue,
            ),
            EngineStatCard(
              title: 'Air Flow Rate',
              value: _liveStats!.airFlowRate.toStringAsFixed(1),
              icon: Icons.air,
              unit: 'g/s',
              color: Colors.teal,
            ),
            EngineStatCard(
              title: 'Manifold Pressure',
              value: _liveStats!.intakeManifoldPressure.toStringAsFixed(1),
              icon: Icons.compress,
              unit: 'kPa',
              color: Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EngineStatGroup(
          title: 'Fuel System',
          icon: Icons.local_gas_station,
          children: [
            EngineStatCard(
              title: 'Fuel System',
              value: _liveStats!.fuelSystemStatus,
              icon: Icons.settings,
              color: Colors.green,
            ),
            EngineStatCard(
              title: 'Fuel Pressure',
              value: _liveStats!.fuelPressure.toStringAsFixed(0),
              icon: Icons.local_gas_station,
              unit: 'kPa',
              color: Colors.amber,
            ),
            EngineStatCard(
              title: 'Short Term Trim',
              value: _liveStats!.shortTermFuelTrim.toStringAsFixed(1),
              icon: Icons.tune,
              unit: '%',
              color: Colors.cyan,
            ),
            EngineStatCard(
              title: 'Long Term Trim',
              value: _liveStats!.longTermFuelTrim.toStringAsFixed(1),
              icon: Icons.tune,
              unit: '%',
              color: Colors.deepPurple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EngineStatGroup(
          title: 'Other Parameters',
          icon: Icons.miscellaneous_services,
          children: [
            EngineStatCard(
              title: 'Timing Advance',
              value: _liveStats!.timingAdvance.toStringAsFixed(1),
              icon: Icons.timer,
              unit: '°',
              color: Colors.brown,
            ),
            // We'll just show one oxygen sensor for simplicity
            if (_liveStats!.oxygenSensorVoltages.isNotEmpty)
              EngineStatCard(
                title: 'O2 Sensor Voltage',
                value: _liveStats!.oxygenSensorVoltages.values.first.toStringAsFixed(2),
                icon: Icons.sensors,
                unit: 'V',
                color: Colors.blueGrey,
              ),
          ],
        ),
      ],
    );
  }
  
  Future<void> _generateRandomEngineStats() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // For demo purposes, we'll just generate random stats without a specific vehicle
      // In a real implementation, this would connect to an OBD-II device via Bluetooth
      final userId = Provider.of<UserProvider>(context, listen: false).currentUser!.id!;
      
      // Create a random ObjectId for demo purposes
      final randomVehicleId = ObjectId();
      
      // Generate random engine stats
      final randomStats = await _engineStatsService.generateRandomEngineStats(randomVehicleId.toHexString());
      
      // Update the UI
      setState(() {
        _liveStats = randomStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating stats: ${e.toString()}')),
      );
    }
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Vehicles',
                '3',
                Icons.directions_car,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Upcoming Services',
                '2',
                Icons.build,
                AppTheme.accentBlueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Engine Health',
                'Good',
                Icons.health_and_safety,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Distance',
                '1,240 km',
                Icons.speed,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyVehiclesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Vehicles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all vehicles
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildVehicleCard(
          context,
          'Toyota Corolla',
          'ABC-123',
          'assets/images/car_placeholder.png',
          '15,000 km',
          'Last service: 2 weeks ago',
        ),
        const SizedBox(height: 12),
        _buildVehicleCard(
          context,
          'Honda City',
          'XYZ-789',
          'assets/images/car_placeholder.png',
          '8,500 km',
          'Last service: 1 month ago',
        ),
      ],
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    String name,
    String regNumber,
    String imageUrl,
    String odometer,
    String lastService,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailScreen(
                vehicleName: name,
                registrationNumber: regNumber,
                vehicleId: ObjectId().toHexString(), // Providing required vehicleId parameter
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      regNumber,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.speed,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          odometer,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.build,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lastService,
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Upcoming Maintenance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMaintenanceCard(
          'Oil Change',
          'Toyota Corolla',
          'Due in 2 days',
          Icons.oil_barrel,
          Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildMaintenanceCard(
          'Tire Rotation',
          'Honda City',
          'Due in 1 week',
          Icons.tire_repair,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard(
    String title,
    String vehicle,
    String dueDate,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dueDate,
                    style: TextStyle(
                      color: dueDate.contains('2 days')
                          ? AppTheme.accentRedColor
                          : AppTheme.textSecondaryColor,
                      fontWeight: dueDate.contains('2 days')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            CustomButton(
              text: 'Schedule',
              onPressed: () {
                // TODO: Navigate to maintenance scheduling
              },
              isFullWidth: false,
              height: 36,
            ),
          ],
        ),
      ),
    );
  }
}