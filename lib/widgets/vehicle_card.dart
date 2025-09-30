import 'package:flutter/material.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';
import 'package:karvaan/widgets/glass_container.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final String? lastService;

  const VehicleCard({
    Key? key,
    required this.vehicle,
    this.lastService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(
              vehicleName: vehicle.name,
              registrationNumber: vehicle.registrationNumber,
              vehicleId: vehicle.id!.toHexString(),
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.25),
                  offset: const Offset(0, 14),
                  blurRadius: 28,
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  vehicle.registrationNumber,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _VehicleMetaChip(
                      icon: Icons.speed,
                      label: vehicle.mileage != null
                          ? '${vehicle.mileage} km'
                          : 'Mileage TBD',
                    ),
                    if (lastService != null) ...[
                      const SizedBox(width: 10),
                      _VehicleMetaChip(
                        icon: Icons.build_rounded,
                        label: 'Serviced $lastService',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}

class _VehicleMetaChip extends StatelessWidget {
  const _VehicleMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.78),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
