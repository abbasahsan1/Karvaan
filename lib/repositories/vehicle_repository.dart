import 'dart:developer';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:mongo_dart/mongo_dart.dart';

class VehicleRepository {
  // Singleton pattern
  VehicleRepository._privateConstructor();
  static final VehicleRepository _instance = VehicleRepository._privateConstructor();
  static VehicleRepository get instance => _instance;

  // Get collection reference
  Future<DbCollection> get _vehiclesCollection async {
    final db = await MongoDBConnection.database;
    return db.collection(MongoDBConnection.vehiclesCollection);
  }

  // Get all vehicles for a user
  Future<List<VehicleModel>> getVehiclesByUserId(ObjectId userId) async {
    try {
      final collection = await _vehiclesCollection;
      final cursor = collection.find(where.eq('userId', userId));
      final results = await cursor.toList();
      
      return results.map((doc) => VehicleModel.fromJson(doc)).toList();
    } catch (e) {
      log('Error getting vehicles: $e');
      throw Exception('Failed to retrieve vehicles: $e');
    }
  }

  // Create a new vehicle
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    try {
      final collection = await _vehiclesCollection;
      final result = await collection.insertOne(vehicle.toJson());
      
      if (!result.isSuccess) {
        throw Exception('Failed to create vehicle');
      }
      
      return vehicle.copyWith(id: result.id);
    } catch (e) {
      log('Error creating vehicle: $e');
      throw Exception('Failed to create vehicle: $e');
    }
  }

  // Get vehicle by ID
  Future<VehicleModel?> getVehicleById(ObjectId id) async {
    try {
      final collection = await _vehiclesCollection;
      final doc = await collection.findOne(where.id(id));
      
      return doc != null ? VehicleModel.fromJson(doc) : null;
    } catch (e) {
      log('Error getting vehicle by ID: $e');
      throw Exception('Failed to retrieve vehicle: $e');
    }
  }

  // Update vehicle
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    try {
      final collection = await _vehiclesCollection;
      
      if (vehicle.id == null) {
        throw Exception('Vehicle ID is required for update');
      }
      
      final vehicleMap = vehicle.toJson();
      vehicleMap.remove('_id'); // MongoDB doesn't allow updating the ID field
      
      final result = await collection.updateOne(
        where.id(vehicle.id!),
        {
          '\$set': vehicleMap,
        },
      );
      
      if (result.isFailure) {
        throw Exception('Failed to update vehicle');
      }
      
      return vehicle;
    } catch (e) {
      log('Error updating vehicle: $e');
      throw Exception('Failed to update vehicle: $e');
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(ObjectId id) async {
    try {
      final collection = await _vehiclesCollection;
      final result = await collection.deleteOne(where.id(id));
      
      if (result.isFailure) {
        throw Exception('Failed to delete vehicle');
      }
    } catch (e) {
      log('Error deleting vehicle: $e');
      throw Exception('Failed to delete vehicle: $e');
    }
  }
}
