import 'package:flutter/material.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/screens/services/add_service_record_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleName;
  final String registrationNumber;
  final String? vehicleId;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicleName,
    required this.registrationNumber,
    this.vehicleId,
  }) : super(key: key);

  @override
  _VehicleDetailScreenState createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final VehicleService _vehicleService = VehicleService.instance;
  bool _isLoading = true;
  VehicleModel? _vehicle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId != null) {
      _loadVehicle();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVehicle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicle = await _vehicleService.getVehicleById(widget.vehicleId!);
      
      if (mounted) {
        setState(() {
          _vehicle = vehicle;
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
      _loadVehicle();
    }
  }

  Future<void> _deleteVehicle() async {
    if (_vehicle == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${_vehicle!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _vehicleService.deleteVehicle(_vehicle!.id!.toHexString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted')),
          );
          Navigator.pop(context, true); // Return success to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting vehicle: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _viewFuelHistory() {
    if (_vehicle == null) return;
    
    Navigator.pushNamed(
      context, 
      AppRoutes.fuelHistory,
      arguments: {'vehicleId': _vehicle!.id!.toHexString()},
    );
  }

  void _viewServiceRecords() {
    if (_vehicle == null) return;
    
    Navigator.pushNamed(
      context, 
      AppRoutes.services,
    );
  }

  void _addFuelEntry() {
    if (_vehicle == null) return;
    
    Navigator.pushNamed(
      context, 
      AppRoutes.addFuel,
      arguments: {'vehicleId': _vehicle!.id!.toHexString()},
    );
  }

  void _addServiceRecord() {
    if (_vehicle == null) return;
    
    Navigator.pushNamed(
      context, 
      AppRoutes.addService,
      arguments: {'vehicleId': _vehicle!.id!.toHexString()},
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
          if (!_isLoading && _vehicle != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteVehicle,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Info Card
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehicle Information',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),
                              _buildInfoRow('Name', _vehicle?.name ?? widget.vehicleName),
                              _buildInfoRow('Registration', _vehicle?.registrationNumber ?? widget.registrationNumber),
                              if (_vehicle?.make != null)
                                _buildInfoRow('Make', _vehicle!.make!),
                              if (_vehicle?.model != null)
                                _buildInfoRow('Model', _vehicle!.model!),
                              if (_vehicle?.year != null)
                                _buildInfoRow('Year', _vehicle!.year!.toString()),
                              if (_vehicle?.color != null)
                                _buildInfoRow('Color', _vehicle!.color!),
                              if (_vehicle?.mileage != null)
                                _buildInfoRow('Mileage', '${_vehicle!.mileage} km'),
                            ],
                          ),
                        ),
                      ),
                      
                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Quick Actions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildActionCard(
                            icon: Icons.local_gas_station,
                            title: 'Add Fuel',
                            onTap: _addFuelEntry,
                          ),
                          _buildActionCard(
                            icon: Icons.build,
                            title: 'Add Service',
                            onTap: _addServiceRecord,
                          ),
                          _buildActionCard(
                            icon: Icons.history,
                            title: 'Fuel History',
                            onTap: _viewFuelHistory,
                          ),
                          _buildActionCard(
                            icon: Icons.miscellaneous_services,
                            title: 'Service Records',
                            onTap: _viewServiceRecords,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}