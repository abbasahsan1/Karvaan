import 'package:flutter/material.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/services/vehicle_service.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({Key? key}) : super(key: key);

  @override
  _VehiclesListScreenState createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen> {
  final VehicleService _vehicleService = VehicleService.instance;
  bool _isLoading = true;
  List<VehicleModel> _vehicles = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicles = await _vehicleService.getVehiclesForCurrentUser();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading vehicles: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addVehicle() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addVehicle);
    if (result == true) {
      _loadVehicles();
    }
  }

  Future<void> _editVehicle(VehicleModel vehicle) async {
    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.addVehicle,
      arguments: {'existingVehicle': vehicle},
    );
    if (result == true) {
      _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(VehicleModel vehicle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${vehicle.name}?'),
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
        await _vehicleService.deleteVehicle(vehicle.id!.toHexString());
        _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${vehicle.name} deleted')),
          );
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

  void _viewVehicleDetails(VehicleModel vehicle) {
    Navigator.pushNamed(
      context, 
      AppRoutes.vehicleDetail,
      arguments: {
        'vehicleName': vehicle.name,
        'registrationNumber': vehicle.registrationNumber,
        'vehicleId': vehicle.id!.toHexString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addVehicle,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No vehicles found'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addVehicle,
                            child: const Text('Add a Vehicle'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadVehicles,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = _vehicles[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(vehicle.name),
                              subtitle: Text(vehicle.registrationNumber),
                              trailing: PopupMenuButton(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editVehicle(vehicle);
                                  } else if (value == 'delete') {
                                    _deleteVehicle(vehicle);
                                  }
                                },
                              ),
                              onTap: () => _viewVehicleDetails(vehicle),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
