import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/repositories/service_repository.dart';

class ServiceRecordService {
  final ServiceRepository _serviceRepository = ServiceRepository.instance;
  
  // Singleton pattern
  ServiceRecordService._privateConstructor();
  static final ServiceRecordService _instance = ServiceRecordService._privateConstructor();
  static ServiceRecordService get instance => _instance;

  // Get all service records for a vehicle
  Future<List<ServiceModel>> getServiceRecordsForVehicle(String vehicleId) async {
    try {
      // Convert String to ObjectId
      final vehicleObjId = ObjectId.parse(vehicleId);
      return await _serviceRepository.getServicesByVehicleId(vehicleObjId);
    } catch (e) {
      log('Error getting service records for vehicle: $e');
      return [];
    }
  }

  // Add a new service record
  Future<ServiceModel> addServiceRecord({
    required String vehicleId,
    required String title,
    String? description,
    required DateTime serviceDate,
    int? mileage,
    required double cost,
    String? serviceType,
    List<String>? parts,
  }) async {
    try {
      // Convert String to ObjectId
      final vehicleObjId = ObjectId.parse(vehicleId);
      
      final service = ServiceModel(
        vehicleId: vehicleObjId,
        title: title,
        description: description,
        serviceDate: serviceDate,
        mileage: mileage,
        cost: cost,
        serviceType: serviceType,
        parts: parts,
      );
      
      return await _serviceRepository.createService(service);
    } catch (e) {
      log('Error adding service record: $e');
      rethrow;
    }
  }

  // Get service record by ID
  Future<ServiceModel?> getServiceRecordById(String id) async {
    try {
      // Convert String to ObjectId
      final objectId = ObjectId.parse(id);
      return await _serviceRepository.getServiceById(objectId);
    } catch (e) {
      log('Error getting service record by ID: $e');
      return null;
    }
  }

  // Update service record
  Future<ServiceModel> updateServiceRecord(ServiceModel service) async {
    try {
      return await _serviceRepository.updateService(service);
    } catch (e) {
      log('Error updating service record: $e');
      rethrow;
    }
  }

  // Delete service record
  Future<void> deleteServiceRecord(String id) async {
    try {
      // Convert String to ObjectId
      final objectId = ObjectId.parse(id);
      await _serviceRepository.deleteService(objectId);
    } catch (e) {
      log('Error deleting service record: $e');
      rethrow;
    }
  }
}
