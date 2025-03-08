import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/services/service_record_service.dart';
import 'package:karvaan/services/vehicle_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ServiceRecordService _serviceRecordService = ServiceRecordService.instance;
  final VehicleService _vehicleService = VehicleService.instance;
  bool _isLoading = true;
  List<VehicleModel> _vehicles = [];
  Map<String, List<ServiceModel>> _servicesByVehicle = {};
  String? _errorMessage;
  VehicleModel? _selectedVehicle;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all vehicles
      final vehicles = await _vehicleService.getVehiclesForCurrentUser();
      
      // If there are vehicles, load services for the first vehicle
      if (vehicles.isNotEmpty) {
        _selectedVehicle = vehicles.first;
        await _loadServicesForVehicle(_selectedVehicle!.id!.toHexString());
      }
      
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadServicesForVehicle(String vehicleId) async {
    try {
      final services = await _serviceRecordService.getServiceRecordsForVehicle(vehicleId);
      
      if (mounted) {
        setState(() {
          _servicesByVehicle[vehicleId] = services;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: ${e.toString()}')),
        );
      }
    }
  }

  void _selectVehicle(VehicleModel vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
    });
    
    // Load services for this vehicle if not already loaded
    if (!_servicesByVehicle.containsKey(vehicle.id!.toHexString())) {
      _loadServicesForVehicle(vehicle.id!.toHexString());
    }
  }

  Future<void> _addServiceRecord() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle first')),
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.addService,
      arguments: {'vehicleId': _selectedVehicle!.id!.toHexString()},
    );

    if (result == true) {
      _loadServicesForVehicle(_selectedVehicle!.id!.toHexString());
    }
  }

  void _viewServiceDetail(ServiceModel service) {
    Navigator.pushNamed(
      context, 
      AppRoutes.serviceDetail,
      arguments: {'serviceId': service.id!.toHexString()},
    ).then((result) {
      if (result == true && _selectedVehicle != null) {
        _loadServicesForVehicle(_selectedVehicle!.id!.toHexString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addServiceRecord,
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
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.addVehicle),
                            child: const Text('Add a Vehicle'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Vehicle selector
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: DropdownButtonFormField<VehicleModel>(
                            decoration: const InputDecoration(
                              labelText: 'Select Vehicle',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedVehicle,
                            items: _vehicles.map((vehicle) {
                              return DropdownMenuItem(
                                value: vehicle,
                                child: Text(vehicle.name),
                              );
                            }).toList(),
                            onChanged: (vehicle) {
                              if (vehicle != null) {
                                _selectVehicle(vehicle);
                              }
                            },
                          ),
                        ),
                        
                        // Service records list
                        Expanded(
                          child: _selectedVehicle == null
                              ? const Center(child: Text('Select a vehicle'))
                              : !_servicesByVehicle.containsKey(_selectedVehicle!.id!.toHexString())
                                  ? const Center(child: CircularProgressIndicator())
                                  : _servicesByVehicle[_selectedVehicle!.id!.toHexString()]!.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('No service records found'),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                onPressed: _addServiceRecord,
                                                child: const Text('Add a Service Record'),
                                              ),
                                            ],
                                          ),
                                        )
                                      : RefreshIndicator(
                                          onRefresh: () => _loadServicesForVehicle(_selectedVehicle!.id!.toHexString()),
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: _servicesByVehicle[_selectedVehicle!.id!.toHexString()]!.length,
                                            itemBuilder: (context, index) {
                                              final service = _servicesByVehicle[_selectedVehicle!.id!.toHexString()]![index];
                                              return Card(
                                                margin: const EdgeInsets.symmetric(vertical: 4),
                                                child: ListTile(
                                                  title: Text(service.title),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(_dateFormat.format(service.serviceDate)),
                                                      Text('\$${service.cost.toStringAsFixed(2)}'),
                                                    ],
                                                  ),
                                                  trailing: service.serviceType != null
                                                      ? Chip(label: Text(service.serviceType!))
                                                      : null,
                                                  onTap: () => _viewServiceDetail(service),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                        ),
                      ],
                    ),
    );
  }
}
