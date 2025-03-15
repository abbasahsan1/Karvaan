import 'package:flutter/material.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/services/fuel_entry_service.dart';
import 'package:karvaan/services/service_record_service.dart';
import 'package:karvaan/services/engine_stats_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/widgets/detail_item.dart';
import 'package:karvaan/widgets/engine_stat_card.dart';
import 'package:intl/intl.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleName;
  final String registrationNumber;
  final String vehicleId;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicleName,
    required this.registrationNumber,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final VehicleService _vehicleService = VehicleService.instance;
  final FuelEntryService _fuelService = FuelEntryService.instance;
  final ServiceRecordService _serviceService = ServiceRecordService.instance;
  final EngineStatsService _engineStatsService = EngineStatsService.instance;

  bool _isLoading = true;
  bool _isGeneratingStats = false;
  VehicleModel? _vehicle;
  String? _errorMessage;
  int _fuelEntryCount = 0;
  int _serviceCount = 0;
  double _totalFuelCost = 0;
  bool _isDeleting = false;
  EngineStatsModel? _liveStats;

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
  }

  Future<void> _loadVehicleDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicle = await _vehicleService.getVehicleById(widget.vehicleId);
      
      // Get fuel entries
      final fuelEntries = await _fuelService.getFuelEntriesForVehicle(widget.vehicleId);
      
      // Get services
      final services = await _serviceService.getServiceRecordsForVehicle(widget.vehicleId);
      
      // Get latest engine stats from database
      final latestStats = await _engineStatsService.getLatestEngineStatsForVehicle(widget.vehicleId);
      
      // Calculate fuel statistics
      double totalCost = 0;
      for (var entry in fuelEntries) {
        totalCost += entry.cost;
      }

      if (mounted) {
        setState(() {
          _vehicle = vehicle;
          _fuelEntryCount = fuelEntries.length;
          _serviceCount = services.length;
          _totalFuelCost = totalCost;
          _liveStats = latestStats; // Set the latest stats from database
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading vehicle details: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editVehicle() async {
    if (_vehicle == null) return;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addVehicle,
      arguments: {'existingVehicle': _vehicle},
    );

    if (result == true) {
      _loadVehicleDetails();
    }
  }

  Future<void> _deleteVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${_vehicle?.name}? This will also delete all fuel records and service history for this vehicle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await _vehicleService.deleteVehicle(widget.vehicleId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted')),
          );
          Navigator.pop(context, true); // Return true to trigger refresh on previous screen
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _updateMileage() async {
    if (_vehicle == null) return;

    final TextEditingController mileageController = TextEditingController();
    mileageController.text = _vehicle!.mileage?.toString() ?? '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Mileage'),
        content: TextField(
          controller: mileageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Current Mileage (km)',
            hintText: 'Enter current odometer reading',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final mileage = int.parse(mileageController.text.trim());
                if (mileage < 0) {
                  throw Exception('Mileage cannot be negative');
                }
                
                await _vehicleService.updateMileage(
                  widget.vehicleId,
                  mileage,
                );
                
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadVehicleDetails();
    }
  }

  Future<void> _generateEngineStats() async {
    setState(() {
      _isGeneratingStats = true;
    });

    try {
      // Generate random stats and save to database
      await _engineStatsService.generateRandomEngineStats(widget.vehicleId);
      
      // Fetch the latest stats from database to ensure consistency
      final stats = await _engineStatsService.getLatestEngineStatsForVehicle(widget.vehicleId);
      
      if (mounted) {
        setState(() {
          _liveStats = stats;
          _isGeneratingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingStats = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating engine stats: ${e.toString()}')),
        );
      }
    }
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
          ],
        ),
      ),
    );
  }

  Widget _buildEngineStatsDisplay() {
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle?.name ?? widget.vehicleName),
        actions: [
          if (!_isLoading && _vehicle != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editVehicle,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildVehicleDetails(),
    );
  }

  Widget _buildVehicleDetails() {
    if (_vehicle == null) {
      return const Center(child: Text('Vehicle not found'));
    }

    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle icon/image
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Vehicle basic information
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailItem(
                    icon: Icons.drive_file_rename_outline,
                    label: 'Name',
                    value: _vehicle!.name,
                  ),
                  DetailItem(
                    icon: Icons.app_registration,
                    label: 'Registration',
                    value: _vehicle!.registrationNumber,
                  ),
                  if (_vehicle!.make != null)
                    DetailItem(
                      icon: Icons.business,
                      label: 'Make',
                      value: _vehicle!.make!,
                    ),
                  if (_vehicle!.model != null)
                    DetailItem(
                      icon: Icons.model_training,
                      label: 'Model',
                      value: _vehicle!.model!,
                    ),
                  if (_vehicle!.year != null)
                    DetailItem(
                      icon: Icons.date_range,
                      label: 'Year',
                      value: _vehicle!.year.toString(),
                    ),
                  if (_vehicle!.color != null)
                    DetailItem(
                      icon: Icons.color_lens,
                      label: 'Color',
                      value: _vehicle!.color!,
                    ),
                  DetailItem(
                    icon: Icons.speed,
                    label: 'Current Mileage',
                    value: _vehicle!.mileage != null ? '${_vehicle!.mileage} km' : 'Not set',
                    trailingWidget: IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: _updateMileage,
                      tooltip: 'Update mileage',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Statistics Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailItem(
                    icon: Icons.local_gas_station,
                    label: 'Fuel Records',
                    value: '$_fuelEntryCount entries',
                  ),
                  DetailItem(
                    icon: Icons.attach_money,
                    label: 'Total Fuel Cost',
                    value: currencyFormat.format(_totalFuelCost),
                  ),
                  DetailItem(
                    icon: Icons.build,
                    label: 'Service Records',
                    value: '$_serviceCount records',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Engine Stats Section
          Column(
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
                      onPressed: _generateEngineStats,
                      isLoading: _isGeneratingStats,
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
          ),
          const SizedBox(height: 24),
          
          // Delete button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Delete Vehicle',
              onPressed: _deleteVehicle,
              isLoading: _isDeleting,
              icon: Icons.delete,
              backgroundColor: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}