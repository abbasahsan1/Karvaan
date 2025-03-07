import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/screens/fuel/add_fuel_entry_screen.dart';

class FuelHistoryScreen extends StatefulWidget {
  final String? vehicleId; // Optional - if viewing for a specific vehicle

  const FuelHistoryScreen({
    Key? key,
    this.vehicleId,
  }) : super(key: key);

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> {
  // Mock fuel entries data - in a real app this would come from a database
  final List<Map<String, dynamic>> _fuelEntries = [
    {
      'id': '1',
      'vehicle': 'Toyota Corolla',
      'date': 'June 1, 2023',
      'fuelType': 'Petrol',
      'odometer': '14,800 km',
      'fuelAmount': '35 L',
      'fuelCost': 'Rs. 200/L',
      'totalCost': 'Rs. 7,000',
      'isFillUp': true,
      'notes': 'Regular fill-up at Shell',
      'efficiency': '13.5 km/L',
    },
    {
      'id': '2',
      'vehicle': 'Toyota Corolla',
      'date': 'May 15, 2023',
      'fuelType': 'Petrol',
      'odometer': '14,500 km',
      'fuelAmount': '30 L',
      'fuelCost': 'Rs. 200/L',
      'totalCost': 'Rs. 6,000',
      'isFillUp': true,
      'notes': '',
      'efficiency': '13.8 km/L',
    },
    {
      'id': '3',
      'vehicle': 'Honda City',
      'date': 'May 20, 2023',
      'fuelType': 'Petrol',
      'odometer': '8,200 km',
      'fuelAmount': '25 L',
      'fuelCost': 'Rs. 200/L',
      'totalCost': 'Rs. 5,000',
      'isFillUp': true,
      'notes': '',
      'efficiency': '15.2 km/L',
    },
    {
      'id': '4',
      'vehicle': 'Toyota Corolla',
      'date': 'May 1, 2023',
      'fuelType': 'Petrol',
      'odometer': '14,200 km',
      'fuelAmount': '32 L',
      'fuelCost': 'Rs. 200/L',
      'totalCost': 'Rs. 6,400',
      'isFillUp': true,
      'notes': 'Premium fuel',
      'efficiency': '14.0 km/L',
    },
  ];

  String? _selectedVehicle;
  final List<String> _vehicles = ['All Vehicles', 'Toyota Corolla', 'Honda City', 'Suzuki Alto'];

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.vehicleId != null ? 'Toyota Corolla' : 'All Vehicles'; // Mock mapping
  }

  List<Map<String, dynamic>> get _filteredEntries {
    if (_selectedVehicle == null || _selectedVehicle == 'All Vehicles') {
      return _fuelEntries;
    }
    return _fuelEntries.where((entry) => entry['vehicle'] == _selectedVehicle).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              // TODO: Navigate to fuel analytics screen
            },
            tooltip: 'Fuel Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: _filteredEntries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      return _buildFuelEntryCard(_filteredEntries[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _navigateToAddFuelEntry();
        },
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Filter by:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(),
              ),
              value: _selectedVehicle,
              items: _vehicles.map((String vehicle) {
                return DropdownMenuItem<String>(
                  value: vehicle,
                  child: Text(vehicle),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVehicle = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedVehicle == 'All Vehicles'
                  ? 'No fuel entries yet'
                  : 'No fuel entries for $_selectedVehicle',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first fuel entry to start tracking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelEntryCard(Map<String, dynamic> entry) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _navigateToEditFuelEntry(entry);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_gas_station,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry['vehicle'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    entry['date'],
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem('Amount', entry['fuelAmount']),
                  _buildDetailItem('Cost', entry['totalCost']),
                  _buildDetailItem('Odometer', entry['odometer']),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_offer,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry['fuelType'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.speed,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Efficiency: ${entry['efficiency']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (entry['notes'] != null && entry['notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  entry['notes'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _navigateToAddFuelEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFuelEntryScreen(
          vehicleId: widget.vehicleId,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _fuelEntries.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          ...result,
          'efficiency': '14.2 km/L', // Mock value - in a real app, this would be calculated
        });
      });
    }
  }

  void _navigateToEditFuelEntry(Map<String, dynamic> entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFuelEntryScreen(
          existingEntry: entry,
          vehicleId: widget.vehicleId,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        final index = _fuelEntries.indexWhere((e) => e['id'] == entry['id']);
        if (index != -1) {
          _fuelEntries[index] = {
            'id': entry['id'],
            ...result,
            'efficiency': entry['efficiency'], // Preserve existing efficiency
          };
        }
      });
    }
  }
}
