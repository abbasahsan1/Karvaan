import 'package:flutter/material.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/service_record_service.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({Key? key}) : super(key: key);

  @override
  _ServicesListScreenState createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ServiceRecordService _serviceService = ServiceRecordService.instance;
  final VehicleService _vehicleService = VehicleService.instance;
  
  bool _isLoading = true;
  List<VehicleModel> _vehicles = [];
  Map<String, List<ServiceRecordModel>> _servicesByVehicle = {};
  List<ServiceRecordModel> _upcomingServices = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load vehicles
      final vehicles = await _vehicleService.getVehiclesForCurrentUser();
      _vehicles = vehicles;
      
      // Initialize map to store services by vehicle
      _servicesByVehicle = {};
      
      // For each vehicle, get service records
      for (var vehicle in vehicles) {
        if (vehicle.id != null) {
          final vehicleId = vehicle.id!.toHexString();
          
          final services = await _serviceService.getServiceRecordsForVehicle(vehicleId);
          _servicesByVehicle[vehicleId] = services;
        }
      }
      
      // Load upcoming service reminders
      _upcomingServices = await _serviceService.getUpcomingServiceReminders();

      if (mounted) {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Services'),
            Tab(text: 'Upcoming'),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllServicesTab(),
                        _buildUpcomingServicesTab(),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildAllServicesTab() {
    if (_vehicles.isEmpty) {
      return const Center(
        child: Text('No vehicles found. Add a vehicle to track service records.'),
      );
    }

    final allServices = <ServiceRecordModel>[];
    for (var services in _servicesByVehicle.values) {
      allServices.addAll(services);
    }
    
    if (allServices.isEmpty) {
      return const Center(
        child: Text('No service records found. Add service records for your vehicles.'),
      );
    }

    // Sort all services by date (newest first)
    allServices.sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allServices.length,
        itemBuilder: (context, index) {
          final service = allServices[index];
          // Find the vehicle this service belongs to
          final vehicleId = service.vehicleId.toHexString();
          final vehicle = _vehicles.firstWhere(
            (v) => v.id!.toHexString() == vehicleId,
            orElse: () => VehicleModel(
              userId: service.userId,
              name: 'Unknown Vehicle',
              registrationNumber: 'Unknown',
            ),
          );
          
          return _buildServiceCard(service, vehicle);
        },
      ),
    );
  }

  Widget _buildUpcomingServicesTab() {
    if (_upcomingServices.isEmpty) {
      return const Center(
        child: Text('No upcoming service reminders found.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingServices.length,
        itemBuilder: (context, index) {
          final service = _upcomingServices[index];
          // Find the vehicle this service belongs to
          final vehicleId = service.vehicleId.toHexString();
          final vehicle = _vehicles.firstWhere(
            (v) => v.id!.toHexString() == vehicleId,
            orElse: () => VehicleModel(
              userId: service.userId,
              name: 'Unknown Vehicle',
              registrationNumber: 'Unknown',
            ),
          );
          
          return _buildUpcomingServiceCard(service, vehicle);
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceRecordModel service, VehicleModel vehicle) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: service.isScheduled ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.isScheduled ? 'Scheduled' : 'Unscheduled',
                    style: TextStyle(
                      fontSize: 12,
                      color: service.isScheduled ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(service.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  currencyFormat.format(service.cost),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (service.odometer != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${service.odometer} km',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            if (service.partsReplaced != null && service.partsReplaced!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Parts replaced:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: service.partsReplaced!.map((part) => Chip(
                  label: Text(
                    part,
                    style: const TextStyle(fontSize: 12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
            if (service.description != null && service.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                service.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingServiceCard(ServiceRecordModel service, VehicleModel vehicle) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    // Calculate days until reminder
    final now = DateTime.now();
    final daysUntil = service.reminderDate != null
      ? service.reminderDate!.difference(now).inDays
      : 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: daysUntil <= 7 ? Colors.red.shade50 : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: daysUntil <= 7 
                      ? Colors.red.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysUntil <= 0
                      ? 'Overdue'
                      : daysUntil <= 7
                        ? 'Due soon'
                        : 'Upcoming',
                    style: TextStyle(
                      fontSize: 12,
                      color: daysUntil <= 7 ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Reminder: ${dateFormat.format(service.reminderDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: daysUntil <= 7 ? Colors.red[700] : Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              daysUntil <= 0
                ? 'This service is overdue!'
                : daysUntil == 1
                  ? 'This service is due tomorrow'
                  : 'This service is due in $daysUntil days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: daysUntil <= 7 ? Colors.red[700] : Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
