import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karvaan/models/fuel_entry_model.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/services/fuel_entry_service.dart';
import 'package:karvaan/services/vehicle_service.dart';

class FuelHistoryScreen extends StatefulWidget {
  final String? vehicleId;
  
  const FuelHistoryScreen({
    Key? key,
    this.vehicleId,
  }) : super(key: key);

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> {
  final FuelEntryService _fuelEntryService = FuelEntryService.instance;
  final VehicleService _vehicleService = VehicleService.instance;
  bool _isLoading = true;
  List<FuelEntryModel> _fuelEntries = [];
  VehicleModel? _vehicle;
  String? _errorMessage;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  
  // Stats
  double _totalCost = 0;
  double _totalQuantity = 0;
  double _avgCostPerLiter = 0;

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
      // Load vehicle if vehicleId is provided
      if (widget.vehicleId != null) {
        final vehicle = await _vehicleService.getVehicleById(widget.vehicleId!);
        if (vehicle != null) {
          setState(() {
            _vehicle = vehicle;
          });
          await _loadFuelEntries(widget.vehicleId!);
        } else {
          setState(() {
            _errorMessage = 'Vehicle not found';
            _isLoading = false;
          });
        }
      } else {
        // Load first vehicle if none specified
        final vehicles = await _vehicleService.getVehiclesForCurrentUser();
        if (vehicles.isNotEmpty) {
          setState(() {
            _vehicle = vehicles.first;
          });
          await _loadFuelEntries(_vehicle!.id!.toHexString());
        } else {
          setState(() {
            _errorMessage = 'No vehicles found';
            _isLoading = false;
          });
        }
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

  Future<void> _loadFuelEntries(String vehicleId) async {
    try {
      final entries = await _fuelEntryService.getFuelEntriesForVehicle(vehicleId);
      
      // Calculate stats
      double totalCost = 0;
      double totalQuantity = 0;
      
      for (var entry in entries) {
        totalCost += entry.cost;
        totalQuantity += entry.quantity;
      }
      
      double avgCostPerLiter = totalQuantity > 0 ? totalCost / totalQuantity : 0;
      
      if (mounted) {
        setState(() {
          _fuelEntries = entries;
          _totalCost = totalCost;
          _totalQuantity = totalQuantity;
          _avgCostPerLiter = avgCostPerLiter;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading fuel entries: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addFuelEntry() async {
    if (_vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No vehicle selected')),
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.addFuel,
      arguments: {'vehicleId': _vehicle!.id!.toHexString()},
    );

    if (result == true && _vehicle != null) {
      _loadFuelEntries(_vehicle!.id!.toHexString());
    }
  }

  void _viewFuelEntryDetail(FuelEntryModel entry) async {
    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.addFuel,
      arguments: {'existingEntry': entry},
    );

    if (result == true && _vehicle != null) {
      _loadFuelEntries(_vehicle!.id!.toHexString());
    }
  }

  Future<void> _deleteFuelEntry(FuelEntryModel entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this fuel entry?'),
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
        await _fuelEntryService.deleteFuelEntry(entry.id!.toHexString());
        if (_vehicle != null) {
          _loadFuelEntries(_vehicle!.id!.toHexString());
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fuel entry deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle != null ? 'Fuel History: ${_vehicle!.name}' : 'Fuel History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFuelEntry,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    // Stats Summary Card
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Summary',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Divider(),
                            _buildStatRow('Total Spent', '\$${_totalCost.toStringAsFixed(2)}'),
                            _buildStatRow('Total Fuel', '${_totalQuantity.toStringAsFixed(2)} L'),
                            _buildStatRow('Avg. Price', '\$${_avgCostPerLiter.toStringAsFixed(2)} / L'),
                          ],
                        ),
                      ),
                    ),
                    
                    // Fuel Entries List
                    Expanded(
                      child: _fuelEntries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('No fuel entries found'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _addFuelEntry,
                                    child: const Text('Add Fuel Entry'),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _vehicle != null 
                                  ? _loadFuelEntries(_vehicle!.id!.toHexString())
                                  : Future.value(),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _fuelEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = _fuelEntries[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(_dateFormat.format(entry.date)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${entry.quantity.toStringAsFixed(2)} L at \$${(entry.cost / entry.quantity).toStringAsFixed(2)}/L'),
                                          Text('Total: \$${entry.cost.toStringAsFixed(2)}'),
                                          if (entry.mileage != null)
                                            Text('Odometer: ${entry.mileage} km'),
                                        ],
                                      ),
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
                                            _viewFuelEntryDetail(entry);
                                          } else if (value == 'delete') {
                                            _deleteFuelEntry(entry);
                                          }
                                        },
                                      ),
                                      onTap: () => _viewFuelEntryDetail(entry),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
