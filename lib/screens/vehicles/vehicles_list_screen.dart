import 'package:flutter/material.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/widgets/vehicle_card.dart';
import 'package:karvaan/routes/app_routes.dart';

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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _loadVehicles,
                  child: _vehicles.isEmpty
                      ? _buildNoVehiclesMessage()
                      : _buildVehiclesList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVehicle,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildVehiclesList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Here are all your vehicles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _vehicles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return VehicleCard(vehicle: _vehicles[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoVehiclesMessage() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'No vehicles added yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add your first vehicle to start tracking fuel, services, and more',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Add Vehicle',
              onPressed: _addVehicle,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addVehicle() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addVehicle);
    if (result == true) {
      _loadVehicles();
    }
  }
}
