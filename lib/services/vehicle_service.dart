import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/repositories/user_repository.dart';
import 'package:karvaan/repositories/vehicle_repository.dart';
import 'package:karvaan/services/auth_service.dart';
import 'package:karvaan/services/database_service.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class VehicleService {
  VehicleService._privateConstructor();
  static final VehicleService instance = VehicleService._privateConstructor();

  final _db = DatabaseService.instance;
  final _authService = AuthService.instance;

  Future<List<VehicleModel>> getVehiclesForCurrentUser() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('User not authenticated');
      }

      final collection = await _db.getCollection('vehicles');
      final userId = currentUser.id!;
      
      final cursor = await collection.find(mongo.where.eq('userId', userId));
      final List<Map<String, dynamic>> vehicles = await cursor.toList();

      return vehicles.map((json) => VehicleModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  Future<VehicleModel> getVehicleById(String id) async {
    try {
      final collection = await _db.getCollection('vehicles');
      final objectId = mongo.ObjectId.parse(id);
      
      final result = await collection.findOne(mongo.where.eq('_id', objectId));
      if (result == null) {
        throw Exception('Vehicle not found');
      }
      
      return VehicleModel.fromJson(result);
    } catch (e) {
      throw Exception('Failed to get vehicle: $e');
    }
  }

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
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.id!;
      
      // Create the vehicle model
      final newVehicle = VehicleModel(
        userId: userId,
        name: name,
        registrationNumber: registrationNumber,
        make: make,
        model: model,
        year: year,
        color: color,
        mileage: mileage,
      );

      // Save to database
      final collection = await _db.getCollection('vehicles');
      final result = await collection.insertOne(newVehicle.toMap());
      
      if (result.isSuccess) {
        final id = result.id as mongo.ObjectId;
        return newVehicle.copyWith(id: id);
      } else {
        throw Exception('Failed to add vehicle');
      }
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    try {
      if (vehicle.id == null) {
        throw Exception('Cannot update vehicle without ID');
      }

      final collection = await _db.getCollection('vehicles');
      
      final result = await collection.replaceOne(
        mongo.where.eq('_id', vehicle.id),
        vehicle.toMap(),
      );

      if (result.isFailure) {
        throw Exception('Failed to update vehicle');
      }
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final collection = await _db.getCollection('vehicles');
      final objectId = mongo.ObjectId.parse(id);
      
      final result = await collection.deleteOne({'_id': objectId});
      
      if (result.isFailure) {
        throw Exception('Failed to delete vehicle');
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  Future<void> updateMileage(String vehicleId, int newMileage) async {
    try {
      final collection = await _db.getCollection('vehicles');
      final objectId = mongo.ObjectId.parse(vehicleId);
      
      final result = await collection.updateOne(
        mongo.where.eq('_id', objectId),
        mongo.modify.set('mileage', newMileage).set('updatedAt', DateTime.now()),
      );
      
      if (result.isFailure) {
        throw Exception('Failed to update mileage');
      }
    } catch (e) {
      throw Exception('Failed to update mileage: $e');
    }
  }
}
