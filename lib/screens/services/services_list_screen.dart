import 'package:flutter/material.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/service_record_service.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:karvaan/screens/services/service_locator_map_screen.dart';
import 'package:karvaan/widgets/glass_container.dart';

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
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GlassContainer(
            borderRadius: 28,
            padding: const EdgeInsets.all(6),
            child: TabBar(
              controller: _tabController,
              splashBorderRadius: BorderRadius.circular(22),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                ),
              ),
              tabs: const [
                Tab(text: 'All Services'),
                Tab(text: 'Upcoming'),
              ],
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: LoadingAnimationWidget.bouncingBall(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                )
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
    final theme = Theme.of(context);
    final List<Widget> items = [
      _buildMapExploreCard(),
    ];

    if (_vehicles.isEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'No vehicles found. Add a vehicle to track service records and start logging maintenance.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
      );
    } else {
      final allServices = <ServiceRecordModel>[];
      for (var services in _servicesByVehicle.values) {
        allServices.addAll(services);
      }

      if (allServices.isEmpty) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'No service records found. Keep your maintenance history up to date by logging services here.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ),
        );
      } else {
        // Sort all services by date (newest first)
        allServices.sort((a, b) => b.date.compareTo(a.date));

        items.add(const SizedBox(height: 16));

        for (final service in allServices) {
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
          items.add(_buildServiceCard(service, vehicle));
        }
      }
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: items,
      ),
    );
  }

  Widget _buildMapExploreCard() {
    final theme = Theme.of(context);
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.map_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Explore nearby services',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Open the interactive Karvaan map to locate petrol & CNG stations, workshops, and your saved mechanics. Add new spots with a long press and get instant routing.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openServiceLocator,
            icon: const Icon(Icons.navigation_rounded),
            label: const Text('Open service map'),
          ),
        ],
      ),
    );
  }

  void _openServiceLocator() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ServiceLocatorMapScreen()),
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
    final theme = Theme.of(context);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: service.isScheduled
                        ? const [Color(0xFF34D399), Color(0xFF22C55E)]
                        : const [Color(0xFF94A3B8), Color(0xFF64748B)],
                  ),
                ),
                child: Text(
                  service.isScheduled ? 'Scheduled' : 'Logged',
                  style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetaIconText(
                icon: Icons.directions_car_rounded,
                label: vehicle.name,
              ),
              const SizedBox(width: 16),
              _MetaIconText(
                icon: Icons.calendar_month,
                label: dateFormat.format(service.date),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _ChipBadge(
                icon: Icons.payments_outlined,
                label: currencyFormat.format(service.cost),
              ),
              if (service.odometer != null)
                _ChipBadge(
                  icon: Icons.speed,
                  label: '${service.odometer} km',
                ),
            ],
          ),
          if (service.partsReplaced != null && service.partsReplaced!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Parts replaced',
                style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: service.partsReplaced!
                  .map((part) => _Pill(label: part))
                  .toList(),
            ),
          ],
          if (service.description != null && service.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '"${service.description!.trim()}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
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
    
    final theme = Theme.of(context);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        colors: daysUntil <= 7
            ? const [Color(0xFFF97316), Color(0xFFEA580C)]
            : const [Color(0xFF3B82F6), Color(0xFF2563EB)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  daysUntil <= 0
                      ? 'Overdue'
                      : daysUntil <= 7
                          ? 'Due soon'
                          : 'Upcoming',
                  style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetaIconText(
                icon: Icons.directions_car_rounded,
                label: vehicle.name,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              _MetaIconText(
                icon: Icons.calendar_today_rounded,
                label: dateFormat.format(service.reminderDate ?? service.date),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            daysUntil <= 0
                ? 'This service is overdue. Prioritize scheduling it now.'
                : daysUntil <= 7
                    ? 'Due within the next week. Lock in a slot to avoid last-minute stress.'
                    : 'Coming up soon—plan ahead so your ride stays in peak condition.',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}

class _MetaIconText extends StatelessWidget {
  const _MetaIconText({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Colors.white70;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: textColor.withOpacity(0.9)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
            ),
      ),
    );
  }
}
