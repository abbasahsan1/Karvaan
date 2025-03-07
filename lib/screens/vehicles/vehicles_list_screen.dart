import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';
import 'package:karvaan/screens/vehicles/add_vehicle_screen.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen> {
  // Mock vehicle data - in a real app this would come from a database
  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': '1',
      'name': 'Toyota Corolla',
      'make': 'Toyota',
      'model': 'Corolla',
      'year': '2020',
      'registration': 'ABC-123',
      'color': 'White',
      'fuelType': 'Petrol',
      'engineSize': '1800 cc',
      'odometer': '15,000 km',
      'image': null,
      'lastService': 'April 10, 2023',
      'upcomingService': 'Oil Change (due in 2 days)',
      'needsAttention': true,
    },
    {
      'id': '2',
      'name': 'Honda City',
      'make': 'Honda',
      'model': 'City',
      'year': '2019',
      'registration': 'XYZ-789',
      'color': 'Silver',
      'fuelType': 'Petrol',
      'engineSize': '1500 cc',
      'odometer': '8,500 km',
      'image': null,
      'lastService': 'March 22, 2023',
      'upcomingService': 'Tire Rotation (due in 1 week)',
      'needsAttention': false,
    },
    {
      'id': '3',
      'name': 'Suzuki Alto',
      'make': 'Suzuki',
      'model': 'Alto',
      'year': '2021',
      'registration': 'DEF-456',
      'color': 'Red',
      'fuelType': 'Petrol',
      'engineSize': '660 cc',
      'odometer': '5,200 km',
      'image': null,
      'lastService': 'May 15, 2023',
      'upcomingService': 'None scheduled',
      'needsAttention': false,
    },
  ];

  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredVehicles {
    if (_searchQuery.isEmpty) {
      return _vehicles;
    }
    
    return _vehicles.where((vehicle) {
      final name = vehicle['name'].toString().toLowerCase();
      final registration = vehicle['registration'].toString().toLowerCase();
      final make = vehicle['make'].toString().toLowerCase();
      final model = vehicle['model'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || 
             registration.contains(query) || 
             make.contains(query) || 
             model.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement sort functionality
              if (value == 'name_asc') {
                setState(() {
                  _vehicles.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
                });
              } else if (value == 'name_desc') {
                setState(() {
                  _vehicles.sort((a, b) => b['name'].toString().compareTo(a['name'].toString()));
                });
              } else if (value == 'recent_service') {
                // TODO: Sort by recent service
              } else if (value == 'oldest_service') {
                // TODO: Sort by oldest service
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name_asc',
                child: Text('Sort by Name (A-Z)'),
              ),
              const PopupMenuItem(
                value: 'name_desc',
                child: Text('Sort by Name (Z-A)'),
              ),
              const PopupMenuItem(
                value: 'recent_service',
                child: Text('Most Recently Serviced'),
              ),
              const PopupMenuItem(
                value: 'oldest_service',
                child: Text('Needs Service Soon'),
              ),
            ],
          ),
        ],
      ),
      body: _filteredVehicles.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _filteredVehicles[index];
                return _buildVehicleCard(context, vehicle);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _navigateToAddVehicle();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isFiltering = _searchQuery.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltering ? Icons.search_off : Icons.directions_car_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isFiltering
                  ? 'No vehicles found'
                  : 'No vehicles yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltering
                  ? 'Try a different search term or clear your filters'
                  : 'Add your first vehicle to get started',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            if (!isFiltering)
              CustomButton(
                text: 'Add Vehicle',
                onPressed: () {
                  _navigateToAddVehicle();
                },
                isFullWidth: false,
                height: 44,
              ),
            if (isFiltering)
              CustomButton(
                text: 'Clear Search',
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                isFullWidth: false,
                isOutlined: true,
                height: 44,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Map<String, dynamic> vehicle) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailScreen(
                vehicleName: vehicle['name'],
                registrationNumber: vehicle['registration'],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle['image'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  vehicle['image'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehicle['registration'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (vehicle['needsAttention'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AppTheme.accentRedColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Attention Needed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.accentRedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildVehicleInfoItem(
                        Icons.speed,
                        'Odometer',
                        vehicle['odometer'],
                      ),
                      _buildVehicleInfoItem(
                        Icons.build,
                        'Last Service',
                        vehicle['lastService'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Upcoming Service:',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle['upcomingService'],
                          style: TextStyle(
                            color: vehicle['needsAttention'] == true
                                ? AppTheme.accentRedColor
                                : AppTheme.textPrimaryColor,
                            fontWeight: vehicle['needsAttention'] == true
                                ? FontWeight.w500
                                : FontWeight.normal,
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
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _navigateToAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
    );
    
    if (result != null) {
      // In a real app, you'd save the vehicle to a database
      setState(() {
        _vehicles.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': '${result['make']} ${result['model']}',
          ...result,
          'lastService': 'Not serviced yet',
          'upcomingService': 'None scheduled',
          'needsAttention': false,
        });
      });
    }
  }

  void _showSearchDialog() {
    final controller = TextEditingController(text: _searchQuery);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Vehicles'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter vehicle name or registration',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('CLEAR'),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                Navigator.of(context).pop();
              });
            },
          ),
          TextButton(
            child: const Text('SEARCH'),
            onPressed: () {
              setState(() {
                _searchQuery = controller.text;
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
    );
  }
}
