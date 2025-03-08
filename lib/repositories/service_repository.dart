import 'dart:developer';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ServiceRepository {
  // Singleton pattern
  ServiceRepository._privateConstructor();
  static final ServiceRepository _instance = ServiceRepository._privateConstructor();
  static ServiceRepository get instance => _instance;

  // Get collection reference
  Future<DbCollection> get _servicesCollection async {
    final db = await MongoDBConnection.database;
    return db.collection(MongoDBConnection.servicesCollection);
  }

  // Get all service records for a vehicle
  Future<List<ServiceModel>> getServicesByVehicleId(ObjectId vehicleId) async {
    try {
      final collection = await _servicesCollection;
      final cursor = collection.find(where.eq('vehicleId', vehicleId));
      final results = await cursor.toList();
      
      return results.map((doc) => ServiceModel.fromJson(doc)).toList();
    } catch (e) {
      log('Error getting service records: $e');
      throw Exception('Failed to retrieve service records: $e');
    }
  }

  // Create a new service record
  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      final collection = await _servicesCollection;
      final result = await collection.insertOne(service.toJson());
      
      if (!result.isSuccess) {
        throw Exception('Failed to create service record');
      }
      
      return service.copyWith(id: result.id);
    } catch (e) {
      log('Error creating service record: $e');
      throw Exception('Failed to create service record: $e');
    }
  }

  // Get service record by ID
  Future<ServiceModel?> getServiceById(ObjectId id) async {
    try {
      final collection = await _servicesCollection;
      final doc = await collection.findOne(where.id(id));
      
      return doc != null ? ServiceModel.fromJson(doc) : null;
    } catch (e) {
      log('Error getting service record by ID: $e');
      throw Exception('Failed to retrieve service record: $e');
    }
  }

  // Update service record
  Future<ServiceModel> updateService(ServiceModel service) async {
    try {
      final collection = await _servicesCollection;
      
      if (service.id == null) {
        throw Exception('Service record ID is required for update');
      }
      
      final serviceMap = service.toJson();
      serviceMap.remove('_id'); // MongoDB doesn't allow updating the ID field
      
      final result = await collection.updateOne(
        where.id(service.id!),
        {
          '\$set': serviceMap,
        },
      );
      
      if (result.isFailure) {
        throw Exception('Failed to update service record');
      }
      
      return service;
    } catch (e) {
      log('Error updating service record: $e');
      throw Exception('Failed to update service record: $e');
    }
  }

  // Delete service record
  Future<void> deleteService(ObjectId id) async {
    try {
      final collection = await _servicesCollection;
      final result = await collection.deleteOne(where.id(id));
      
      if (result.isFailure) {
        throw Exception('Failed to delete service record');
      }
    } catch (e) {
      log('Error deleting service record: $e');
      throw Exception('Failed to delete service record: $e');
    }
  }
}
