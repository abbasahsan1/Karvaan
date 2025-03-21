import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/providers/user_provider.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/widgets/engine_stat_card.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';
import 'package:karvaan/screens/vehicles/add_vehicle_screen.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import 'package:karvaan/services/engine_stats_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
                  
                  const SizedBox(height: 16),
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
              color: Colors.green,
            ),
            EngineStatCard(
              title: 'Air Flow Rate',
              value: _liveStats!.airFlowRate.toStringAsFixed(1),
              icon: Icons.air,
              unit: 'g/s',
              color: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EngineStatGroup(
          title: 'Fuel System',
          icon: Icons.local_gas_station,
          children: [
            EngineStatCard(
              title: 'Fuel System Status',
              value: _liveStats!.fuelSystemStatus,
              icon: Icons.info_outline,
              color: Colors.amber,
            ),
            EngineStatCard(
              title: 'Short Term Fuel Trim',
              value: _liveStats!.shortTermFuelTrim.toStringAsFixed(1),
              icon: Icons.trending_up,
              unit: '%',
              color: Colors.teal,
            ),
            EngineStatCard(
              title: 'Long Term Fuel Trim',
              value: _liveStats!.longTermFuelTrim.toStringAsFixed(1),
              icon: Icons.trending_up,
              unit: '%',
              color: Colors.indigo,
            ),
            EngineStatCard(
              title: 'Fuel Pressure',
              value: _liveStats!.fuelPressure.toStringAsFixed(0),
              icon: Icons.speed,
              unit: 'kPa',
              color: Colors.deepOrange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EngineStatGroup(
          title: 'Throttle & Timing',
          icon: Icons.tune,
          children: [
            EngineStatCard(
              title: 'Throttle Position',
              value: _liveStats!.absoluteThrottlePosition.toStringAsFixed(1),
              icon: Icons.straighten,
              unit: '%',
              color: Colors.deepPurple,
            ),
            EngineStatCard(
              title: 'Timing Advance',
              value: _liveStats!.timingAdvance.toStringAsFixed(1),
              icon: Icons.timer,
              unit: '°',
              color: Colors.brown,
            ),
            EngineStatCard(
              title: 'Intake Manifold Pressure',
              value: _liveStats!.intakeManifoldPressure.toStringAsFixed(0),
              icon: Icons.compress,
              unit: 'kPa',
              color: Colors.blueGrey,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EngineStatGroup(
          title: 'Oxygen Sensors',
          icon: Icons.sensors,
          children: _buildOxygenSensorCards(),
        ),
      ],
    );
  }
  
  Widget _buildVehicleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Choose from your vehicles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<VehicleModel>(
                isExpanded: true,
                hint: const Text('Select a vehicle'),
                value: _selectedVehicle,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: const TextStyle(color: AppTheme.primaryColor, fontSize: 16),
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
                        const Icon(Icons.directions_car, size: 20, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
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
        ),
      ],
    );
  }
  
  Widget _buildNoVehiclesMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No vehicles found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a vehicle to see its stats and maintenance information.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Vehicle',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
                ).then((_) => _loadUserVehicles());
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVehicleStats() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_liveStats == null) {
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
                'Visit the vehicle details page to measure live stats.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 16),
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
                icon: Icons.visibility,
              ),
            ],
          ),
        ),
      );
    }
    
    return _buildEngineStatsDisplay();
  }





  List<Widget> _buildOxygenSensorCards() {
    final List<Widget> cards = [];
    
    // Add cards for each oxygen sensor voltage
    _liveStats!.oxygenSensorVoltages.forEach((sensorId, voltage) {
      cards.add(
        EngineStatCard(
          title: '$sensorId Voltage',
          value: voltage.toStringAsFixed(2),
          icon: Icons.electric_bolt,
          unit: 'V',
          color: Colors.cyan,
        ),
      );
      
      // Add corresponding fuel trim if available
      if (_liveStats!.oxygenSensorFuelTrims.containsKey(sensorId)) {
        cards.add(
          EngineStatCard(
            title: '$sensorId Trim',
            value: _liveStats!.oxygenSensorFuelTrims[sensorId]!.toStringAsFixed(1),
            icon: Icons.tune,
            unit: '%',
            color: Colors.lightGreen,
          ),
        );
      }
    });
    
    return cards;
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
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.build_outlined,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No upcoming maintenance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Visit the vehicle details page to add service records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Using the updated EngineStatGroup from engine_stat_card.dart instead
// This class is now deprecated and will be removed in future updates