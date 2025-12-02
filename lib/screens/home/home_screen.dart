import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/models/metric_definition.dart';
import 'package:karvaan/providers/user_provider.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/widgets/metric_list_item.dart';
import 'package:karvaan/screens/metrics/metric_detail_screen.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';
import 'package:karvaan/screens/vehicles/add_vehicle_screen.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import 'package:karvaan/services/engine_stats_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:karvaan/widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _isLoadingVehicles = true;
  List<VehicleModel> _userVehicles = [];
  VehicleModel? _selectedVehicle;
  EngineStatsModel? _liveStats;
  final _engineStatsService = EngineStatsService.instance;
  final _vehicleService = VehicleService.instance;
  
  // Define all metrics to be shown in the list
  final List<MetricDefinition> _metrics = [
    MetricDefinition(
      id: 'rpm',
      name: 'Engine RPM',
      icon: Icons.speed,
      unit: 'RPM',
      color: AppTheme.primaryColor,
      getValue: (stats) => stats.engineRpm,
      formatValue: (val) => val.toStringAsFixed(0),
    ),
    MetricDefinition(
      id: 'speed',
      name: 'Vehicle Speed',
      icon: Icons.directions_car,
      unit: 'km/h',
      color: Colors.blue,
      getValue: (stats) => stats.vehicleSpeed,
    ),
    MetricDefinition(
      id: 'load',
      name: 'Calculated Load',
      icon: Icons.trending_up,
      unit: '%',
      color: Colors.orange,
      getValue: (stats) => stats.calculatedLoadValue,
    ),
    MetricDefinition(
      id: 'coolant',
      name: 'Coolant Temp',
      icon: Icons.thermostat,
      unit: '°C',
      color: Colors.red,
      getValue: (stats) => stats.coolantTemperature,
    ),
    MetricDefinition(
      id: 'intake_air',
      name: 'Intake Air Temp',
      icon: Icons.air,
      unit: '°C',
      color: Colors.green,
      getValue: (stats) => stats.intakeAirTemperature,
    ),
    MetricDefinition(
      id: 'maf',
      name: 'Air Flow Rate',
      icon: Icons.air,
      unit: 'g/s',
      color: Colors.purple,
      getValue: (stats) => stats.airFlowRate,
    ),
    MetricDefinition(
      id: 'fuel_trim_short',
      name: 'Short Term Fuel Trim',
      icon: Icons.tune,
      unit: '%',
      color: Colors.teal,
      getValue: (stats) => stats.shortTermFuelTrim,
    ),
    MetricDefinition(
      id: 'fuel_trim_long',
      name: 'Long Term Fuel Trim',
      icon: Icons.tune,
      unit: '%',
      color: Colors.indigo,
      getValue: (stats) => stats.longTermFuelTrim,
    ),
    MetricDefinition(
      id: 'fuel_pressure',
      name: 'Fuel Pressure',
      icon: Icons.speed,
      unit: 'kPa',
      color: Colors.deepOrange,
      getValue: (stats) => stats.fuelPressure,
      formatValue: (val) => val.toStringAsFixed(0),
    ),
    MetricDefinition(
      id: 'throttle',
      name: 'Throttle Position',
      icon: Icons.straighten,
      unit: '%',
      color: Colors.deepPurple,
      getValue: (stats) => stats.absoluteThrottlePosition,
    ),
    MetricDefinition(
      id: 'timing',
      name: 'Timing Advance',
      icon: Icons.timer,
      unit: '°',
      color: Colors.brown,
      getValue: (stats) => stats.timingAdvance,
    ),
    MetricDefinition(
      id: 'map',
      name: 'Intake Manifold Pressure',
      icon: Icons.compress,
      unit: 'kPa',
      color: Colors.blueGrey,
      getValue: (stats) => stats.intakeManifoldPressure,
      formatValue: (val) => val.toStringAsFixed(0),
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
  }
  
  Future<void> _loadUserVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
    });
    
    try {
      final vehicles = await _vehicleService.getVehiclesForCurrentUser();
      
      if (mounted) {
        setState(() {
          _userVehicles = vehicles;
          _isLoadingVehicles = false;
          
          // Select the first vehicle by default if available
          if (vehicles.isNotEmpty) {
            _selectedVehicle = vehicles.first;
            _loadVehicleStats(_selectedVehicle!.id!.toHexString());
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVehicles = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: ${e.toString()}'))
        );
      }
    }
  }
  
  Future<void> _loadVehicleStats(String vehicleId) async {
    setState(() {
      _isLoading = true;
      _liveStats = null;
    });
    
    try {
      final stats = await _engineStatsService.getLatestEngineStatsForVehicle(vehicleId);
      
      if (mounted) {
        setState(() {
          _liveStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
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
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 62,
                          width: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.35),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 0.6,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                userProvider.displayName,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Track live health, refuels and services across all your rides.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Vehicle selector dropdown
                  _buildVehicleSelector(),
                  const SizedBox(height: 16),
                  _isLoadingVehicles
                    ? Center(child: LoadingAnimationWidget.bouncingBall(
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      ))
                    : _userVehicles.isEmpty
                      ? _buildNoVehiclesMessage()
                      : Column(
                          children: [
                            _selectedVehicle != null ? _buildVehicleStats() : const SizedBox.shrink(),
                            const SizedBox(height: 24),
                            _buildUpcomingMaintenanceSection()
                          ],
                        )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsList() {
    if (_liveStats == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            'Live Metrics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _metrics.length,
          itemBuilder: (context, index) {
            final metric = _metrics[index];
            return MetricListItem(
              definition: metric,
              value: metric.getValue(_liveStats!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MetricDetailScreen(
                      definition: metric,
                      vehicleId: _selectedVehicle!.id!.toHexString(),
                    ),
                  ),
                );
              },
            );
          },
        ),
        // Oxygen Sensors (Dynamic)
        if (_liveStats!.oxygenSensorVoltages.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'Oxygen Sensors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
          ),
          ..._liveStats!.oxygenSensorVoltages.entries.map((entry) {
            final sensorId = entry.key;
            final voltage = entry.value;
            
            // Create dynamic definition for this sensor
            final definition = MetricDefinition(
              id: 'o2_$sensorId',
              name: '$sensorId Voltage',
              icon: Icons.electric_bolt,
              unit: 'V',
              color: Colors.cyan,
              getValue: (stats) => stats.oxygenSensorVoltages[sensorId] ?? 0.0,
              formatValue: (val) => val.toStringAsFixed(2),
            );
            
            return MetricListItem(
              definition: definition,
              value: voltage,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MetricDetailScreen(
                      definition: definition,
                      vehicleId: _selectedVehicle!.id!.toHexString(),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ],
    );
  }
  
  Widget _buildVehicleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Your fleet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          borderRadius: 22,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VehicleModel>(
              isExpanded: true,
              dropdownColor: Colors.black.withValues(alpha: 0.9),
              value: _selectedVehicle,
              hint: Text(
                'Select a vehicle',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
              onChanged: (VehicleModel? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedVehicle = newValue;
                    _loadVehicleStats(newValue.id!.toHexString());
                  });
                }
              },
              items: _userVehicles.map<DropdownMenuItem<VehicleModel>>((VehicleModel vehicle) {
                return DropdownMenuItem<VehicleModel>(
                  value: vehicle,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: const Icon(Icons.directions_car_rounded, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${vehicle.name} (${vehicle.registrationNumber})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoVehiclesMessage() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No vehicles yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first vehicle to unlock live telemetry, services, and fuel tracking.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Vehicle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
              ).then((_) => _loadUserVehicles());
            },
            icon: Icons.add,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildVehicleStats() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Theme.of(context).colorScheme.primary,
            size: 56,
          ),
        ),
      );
    }
    
    if (_liveStats == null) {
      return GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
        child: Column(
          children: [
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.insights_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No engine telemetry yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Head to vehicle details and start a live session to stream engine performance.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'View Vehicle Details',
              onPressed: () {
                if (_selectedVehicle != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleDetailScreen(
                        vehicleName: _selectedVehicle!.name,
                        registrationNumber: _selectedVehicle!.registrationNumber,
                        vehicleId: _selectedVehicle!.id!.toHexString(),
                      ),
                    ),
                  ).then((_) => _loadVehicleStats(_selectedVehicle!.id!.toHexString()));
                }
              },
              icon: Icons.timeline_rounded,
              isFullWidth: false,
            ),
          ],
        ),
      );
    }
    
    return _buildMetricsList();
  }

  Widget _buildUpcomingMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Upcoming maintenance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No reminders yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log a service from the vehicle dashboard to start receiving predictive maintenance nudges.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}