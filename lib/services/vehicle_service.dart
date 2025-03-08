import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/repositories/user_repository.dart';
import 'package:karvaan/repositories/vehicle_repository.dart';

class VehicleService {
  final VehicleRepository _vehicleRepository = VehicleRepository.instance;
  final UserRepository _userRepository = UserRepository.instance;
  
  // Singleton pattern
  VehicleService._privateConstructor();
  static final VehicleService _instance = VehicleService._privateConstructor();
  static VehicleService get instance => _instance;

  // Get all vehicles for current user
  Future<List<VehicleModel>> getVehiclesForCurrentUser() async {
    try {
      // Get current user ID as ObjectId
      final userId = await _userRepository.getCurrentUserId();
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Use the ObjectId directly
      return await _vehicleRepository.getVehiclesByUserId(userId);
    } catch (e) {
      log('Error getting vehicles for current user: $e');
      return [];
    }
  }

  // Add a new vehicle
  Future<VehicleModel> addVehicle({
    required String name,
    required String registrationNumber,
    String? make,
    String? model,
    int? year,
    String? color,
    int? mileage,
  }) async {
    try {
      // Get current user ID as ObjectId
      final userId = await _userRepository.getCurrentUserId();
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final vehicle = VehicleModel(
        userId: userId,
        name: name,
        registrationNumber: registrationNumber,
        make: make,
        model: model,
        year: year,
        color: color,
        mileage: mileage,
      );
      
      return await _vehicleRepository.createVehicle(vehicle);
    } catch (e) {
      log('Error adding vehicle: $e');
      rethrow;
    }
  }

  // Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id) async {
    try {
      // Convert String to ObjectId
      final objectId = ObjectId.parse(id);
      return await _vehicleRepository.getVehicleById(objectId);
    } catch (e) {
      log('Error getting vehicle by ID: $e');
      return null;
    }
  }

  // Update vehicle
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    try {
      return await _vehicleRepository.updateVehicle(vehicle);
    } catch (e) {
      log('Error updating vehicle: $e');
      rethrow;
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      // Convert String to ObjectId
      final objectId = ObjectId.parse(id);
      await _vehicleRepository.deleteVehicle(objectId);
    } catch (e) {
      log('Error deleting vehicle: $e');
      rethrow;
    }
  }
}
