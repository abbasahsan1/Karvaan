import 'package:flutter/material.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/engine_stats_service.dart';
import 'package:karvaan/services/service_record_service.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:karvaan/screens/services/service_locator_map_screen.dart';
import 'package:karvaan/widgets/glass_container.dart';
import 'package:karvaan/screens/services/ai_car_companion_tab.dart';
import 'package:karvaan/widgets/engine_performance_chart.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({Key? key}) : super(key: key);

  @override
  _ServicesListScreenState createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ServiceRecordService _serviceService = ServiceRecordService.instance;
  final EngineStatsService _engineStatsService = EngineStatsService.instance;
  final VehicleService _vehicleService = VehicleService.instance;
  
  bool _isLoading = true;
  List<VehicleModel> _vehicles = [];
  Map<String, List<ServiceRecordModel>> _servicesByVehicle = {};
  Map<String, List<EngineStatsModel>> _engineStatsByVehicle = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      _engineStatsByVehicle = {};
      
      // For each vehicle, get service records
      for (var vehicle in vehicles) {
        if (vehicle.id != null) {
          final vehicleId = vehicle.id!.toHexString();
          
          final services = await _serviceService.getServiceRecordsForVehicle(vehicleId);
          _servicesByVehicle[vehicleId] = services;

          final stats = await _engineStatsService.getEngineStatsForVehicle(vehicleId);
          _engineStatsByVehicle[vehicleId] = stats;
        }
      }
      
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
                Tab(text: 'Reports'),
                Tab(text: 'AI Companion'),
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
                        _buildReportsTab(),
                        const AICarCompanionTab(),
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

  Widget _buildReportsTab() {
    final theme = Theme.of(context);
    final vehiclesWithStats = _vehicles.where((v) {
      final id = v.id?.toHexString();
      return id != null && (_engineStatsByVehicle[id]?.isNotEmpty ?? false);
    }).toList();

    if (_vehicles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              'Add a vehicle to start seeing live telemetry, health reports, and charts.',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (vehiclesWithStats.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              'Start a live session from the vehicle dashboard to stream metrics. We will chart RPM, speed, temps, load, O2 sensors and more here.',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Live telemetry reports',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...vehiclesWithStats.map((vehicle) {
            final vehicleId = vehicle.id!.toHexString();
            final stats = _engineStatsByVehicle[vehicleId] ?? [];
            final latest = _latestStat(stats);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ReportStatCard(
                        title: 'RPM',
                        value: latest != null ? latest.engineRpm.toStringAsFixed(0) : '—',
                        icon: Icons.speed,
                        gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF6366F1)]),
                        width: 160,
                      ),
                      _ReportStatCard(
                        title: 'Speed (km/h)',
                        value: latest != null ? latest.vehicleSpeed.toStringAsFixed(1) : '—',
                        icon: Icons.directions_car_filled_rounded,
                        gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
                        width: 160,
                      ),
                      _ReportStatCard(
                        title: 'Coolant (°C)',
                        value: latest != null ? latest.coolantTemperature.toStringAsFixed(1) : '—',
                        icon: Icons.thermostat,
                        gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF59E0B)]),
                        width: 160,
                      ),
                      _ReportStatCard(
                        title: 'Engine Load %',
                        value: latest != null ? latest.calculatedLoadValue.toStringAsFixed(0) : '—',
                        icon: Icons.auto_graph,
                        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                        width: 160,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  EnginePerformanceChart(
                    stats: stats,
                    title: 'Engine RPM trend',
                    getValue: (s) => s.engineRpm,
                    lineColor: const Color(0xFF38BDF8),
                    unit: 'rpm',
                  ),
                  const SizedBox(height: 12),
                  EnginePerformanceChart(
                    stats: stats,
                    title: 'Vehicle speed trend',
                    getValue: (s) => s.vehicleSpeed,
                    lineColor: const Color(0xFF22C55E),
                    unit: 'km/h',
                  ),
                  const SizedBox(height: 12),
                  EnginePerformanceChart(
                    stats: stats,
                    title: 'Coolant temperature trend',
                    getValue: (s) => s.coolantTemperature,
                    lineColor: const Color(0xFFF97316),
                    unit: '°C',
                  ),
                ],
              ),
            );
          }),
        ],
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

  EngineStatsModel? _latestStat(List<EngineStatsModel> stats) {
    if (stats.isEmpty) return null;
    stats.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return stats.first;
  }
}

class _ReportStatCard extends StatelessWidget {
  const _ReportStatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.gradient,
    this.width,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Gradient? gradient;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        gradient: gradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white.withOpacity(0.85)),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ],
        ),
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
