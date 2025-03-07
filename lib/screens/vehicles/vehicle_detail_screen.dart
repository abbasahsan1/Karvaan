import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/screens/services/add_service_record_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleName;
  final String registrationNumber;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicleName,
    required this.registrationNumber,
  }) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock vehicle data
  late Map<String, dynamic> _vehicleData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initVehicleData();
  }

  void _initVehicleData() {
    // In a real app, you would fetch this data from a database
    _vehicleData = {
      'name': widget.vehicleName,
      'registration': widget.registrationNumber,
      'make': widget.vehicleName.split(' ')[0],
      'model': widget.vehicleName.contains(' ') ? widget.vehicleName.split(' ')[1] : 'Unknown',
      'year': '2020',
      'color': 'White',
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'engineSize': '1800 cc',
      'odometer': '15,000 km',
      'lastService': 'April 10, 2023',
      'purchaseDate': 'Jan 15, 2020',
      'purchasePrice': 'Rs. 2,500,000',
      'documents': [
        'Registration Certificate',
        'Insurance Policy',
        'Maintenance Record',
      ],
      'fuelLog': [
        {
          'date': 'June 1, 2023',
          'amount': '35 L',
          'cost': 'Rs. 7,000',
          'odometer': '14,800 km',
        },
        {
          'date': 'May 15, 2023',
          'amount': '30 L',
          'cost': 'Rs. 6,000',
          'odometer': '14,500 km',
        },
        {
          'date': 'May 1, 2023',
          'amount': '32 L',
          'cost': 'Rs. 6,400',
          'odometer': '14,200 km',
        },
      ],
      'serviceHistory': [
        {
          'id': '1',
          'type': 'Oil Change',
          'date': 'April 10, 2023',
          'odometer': '12,500 km',
          'cost': 'Rs. 2,500',
        },
        {
          'id': '2',
          'type': 'Brake Pad Replacement',
          'date': 'February 15, 2023',
          'odometer': '10,000 km',
          'cost': 'Rs. 5,000',
        },
        {
          'id': '3',
          'type': 'Annual Inspection',
          'date': 'January 5, 2023',
          'odometer': '8,500 km',
          'cost': 'Rs. 2,000',
        },
      ],
      'expenses': [
        {
          'type': 'Fuel',
          'total': 'Rs. 18,500',
        },
        {
          'type': 'Maintenance',
          'total': 'Rs. 9,500',
        },
        {
          'type': 'Insurance',
          'total': 'Rs. 25,000',
        },
        {
          'type': 'Other',
          'total': 'Rs. 5,000',
        },
      ],
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicleData['name']),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Navigate to edit vehicle screen
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Vehicle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Vehicle', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Services'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildServicesTab(),
          _buildExpensesTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddServiceRecordScreen(),
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleImageCard(),
          const SizedBox(height: 24),
          _buildVehicleInfoCard(),
          const SizedBox(height: 24),
          _buildDocumentsSection(),
          const SizedBox(height: 24),
          _buildLatestFuelSection(),
        ],
      ),
    );
  }

  Widget _buildVehicleImageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vehicle image placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _vehicleData['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _vehicleData['registration'],
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: 'Add Photo',
                  onPressed: () {
                    // TODO: Implement photo upload
                  },
                  isOutlined: true,
                  isFullWidth: false,
                  height: 36,
                  icon: Icons.camera_alt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
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
            const Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Make', _vehicleData['make']),
                ),
                Expanded(
                  child: _buildInfoItem('Model', _vehicleData['model']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Year', _vehicleData['year']),
                ),
                Expanded(
                  child: _buildInfoItem('Color', _vehicleData['color']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Fuel Type', _vehicleData['fuelType']),
                ),
                Expanded(
                  child: _buildInfoItem('Transmission', _vehicleData['transmission']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Engine Size', _vehicleData['engineSize']),
                ),
                Expanded(
                  child: _buildInfoItem('Odometer', _vehicleData['odometer']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Last Service', _vehicleData['lastService']),
                ),
                Expanded(
                  child: _buildInfoItem('Purchase Date', _vehicleData['purchaseDate']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Purchase Price', _vehicleData['purchasePrice']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
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
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to add document screen
              },
              child: const Row(
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text('Add'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _vehicleData['documents'].length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: const Icon(Icons.description, color: AppTheme.primaryColor),
                title: Text(_vehicleData['documents'][index]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Open document
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLatestFuelSection() {
    final latestFuel = _vehicleData['fuelLog'][0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Fuel Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to fuel log screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${latestFuel['date']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Amount: ${latestFuel['amount']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cost: ${latestFuel['cost']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Odometer: ${latestFuel['odometer']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Add Fuel Entry',
                  onPressed: () {
                    // TODO: Navigate to add fuel entry screen
                  },
                  icon: Icons.local_gas_station,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceSummaryCard(),
          const SizedBox(height: 24),
          const Text(
            'Service History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vehicleData['serviceHistory'].length,
            itemBuilder: (context, index) {
              final service = _vehicleData['serviceHistory'][index];
              return _buildServiceHistoryCard(service);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
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
            const Text(
              'Service Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildServiceMetric('Last Service', _vehicleData['lastService']),
                _buildServiceMetric('Total Services', _vehicleData['serviceHistory'].length.toString()),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Schedule Service',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddServiceRecordScreen(),
                  ),
                );
              },
              icon: Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceHistoryCard(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to service detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service['type'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${service['date']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Cost: ${service['cost']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentBlueColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Odometer: ${service['odometer']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesTab() {
    double total = 0;
    for (final expense in _vehicleData['expenses']) {
      total += double.parse(expense['total'].toString().replaceAll('Rs. ', '').replaceAll(',', ''));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalExpenseCard(total),
          const SizedBox(height: 24),
          const Text(
            'Expense Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildExpenseChart(),
          const SizedBox(height: 24),
          const Text(
            'Expense Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vehicleData['expenses'].length,
            itemBuilder: (context, index) {
              final expense = _vehicleData['expenses'][index];
              return _buildExpenseDetailCard(
                expense['type'],
                expense['total'],
                _getExpenseIcon(expense['type']),
                _getExpenseColor(expense['type']),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalExpenseCard(double total) {
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
            const Text(
              'Total Expenses',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rs. ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last 12 months',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart() {
    // TODO: Implement actual chart
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Expense Chart Placeholder'),
      ),
    );
  }

  Widget _buildExpenseDetailCard(String type, String amount, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          type,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // TODO: Navigate to expense detail
        },
      ),
    );
  }

  IconData _getExpenseIcon(String type) {
    switch (type) {
      case 'Fuel':
        return Icons.local_gas_station;
      case 'Maintenance':
        return Icons.build;
      case 'Insurance':
        return Icons.security;
      default:
        return Icons.attach_money;
    }
  }

  Color _getExpenseColor(String type) {
    switch (type) {
      case 'Fuel':
        return Colors.green;
      case 'Maintenance':
        return Colors.blue;
      case 'Insurance':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text('Are you sure you want to delete this vehicle? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
              // TODO: Implement actual delete functionality
            },
          ),
        ],
      ),
    );
  }
}