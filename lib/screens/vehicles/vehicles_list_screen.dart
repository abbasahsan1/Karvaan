import 'package:flutter/material.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/widgets/vehicle_card.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/widgets/glass_container.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: theme.colorScheme.primary,
                  size: 64,
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                          const SizedBox(height: 12),
                          Text(
                            'Something went wrong',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Retry',
                            onPressed: _loadVehicles,
                            isFullWidth: false,
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: theme.colorScheme.primary,
                    backgroundColor: Colors.black54,
                    onRefresh: _loadVehicles,
                    child: _vehicles.isEmpty
                        ? _buildNoVehiclesMessage()
                        : _buildVehiclesList(),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVehicle,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildVehiclesList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _vehicles.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                  child: const Icon(Icons.directions_car_filled, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Garage',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep tabs on every vehicle, service, and stat in a single view.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final vehicle = _vehicles[index - 1];
        return VehicleCard(vehicle: vehicle);
      },
    );
  }

  Widget _buildNoVehiclesMessage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'No vehicles yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first vehicle to unlock live stats, service reminders, and fuel insights.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Add Vehicle',
                onPressed: _addVehicle,
                icon: Icons.add_rounded,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addVehicle() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addVehicle);
    if (result == true) {
      _loadVehicles();
    }
  }
}
