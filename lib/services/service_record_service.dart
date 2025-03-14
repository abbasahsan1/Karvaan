import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/services/auth_service.dart';
import 'package:karvaan/services/database_service.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ServiceRecordService {
  // Singleton pattern
  ServiceRecordService._privateConstructor();
  static final ServiceRecordService instance = ServiceRecordService._privateConstructor();

  final _db = DatabaseService.instance;
  final _authService = AuthService.instance;

  // Get all service records for a vehicle
  Future<List<ServiceRecordModel>> getServiceRecordsForVehicle(String vehicleId) async {
    try {
      final collection = await _db.getCollection('service_records');
      final vehicleObjectId = mongo.ObjectId.parse(vehicleId);
      
      final cursor = await collection.find(
        mongo.where.eq('vehicleId', vehicleObjectId).sortBy('date', descending: true)
      );
      
      final List<Map<String, dynamic>> records = await cursor.toList();
      return records.map((json) => ServiceRecordModel.fromJson(json)).toList();
    } catch (e) {
      log('Error getting service records for vehicle: $e');
      throw Exception('Failed to get service records: $e');
    }
  }

  Future<List<ServiceRecordModel>> getUpcomingServiceReminders() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.id!;
      final collection = await _db.getCollection('service_records');
      final now = DateTime.now();
      
      // Get records with future reminder dates
      final cursor = await collection.find(
        mongo.where
          .eq('userId', userId)
          .gt('reminderDate', now)
          .sortBy('reminderDate')
      );
      
      final List<Map<String, dynamic>> records = await cursor.toList();
      return records.map((json) => ServiceRecordModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get service reminders: $e');
    }
  }

  // Add a new service record
  Future<ServiceRecordModel> addServiceRecord({
    required String vehicleId,
    required String title,
    required DateTime date,
    required double cost,
    int? odometer,
    String? serviceCenter,
    String? description,
    List<String>? partsReplaced,
    bool isScheduled = false,
    DateTime? reminderDate,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.id!;
      final vehicleObjectId = mongo.ObjectId.parse(vehicleId);
      
      final newRecord = ServiceRecordModel(
        userId: userId,
        vehicleId: vehicleObjectId,
        title: title,
        date: date,
        cost: cost,
        odometer: odometer,
        serviceCenter: serviceCenter,
        description: description,
        partsReplaced: partsReplaced,
        isScheduled: isScheduled,
        reminderDate: reminderDate,
      );

      final collection = await _db.getCollection('service_records');
      final result = await collection.insertOne(newRecord.toMap());
      
      if (result.isSuccess) {
        final id = result.id as mongo.ObjectId;
        return newRecord.copyWith(id: id);
      } else {
        throw Exception('Failed to add service record');
      }
    } catch (e) {
      throw Exception('Failed to add service record: $e');
    }
  }

  // Get service record by ID
  Future<ServiceRecordModel?> getServiceRecordById(String id) async {
    try {
      final collection = await _db.getCollection('service_records');
      final objectId = mongo.ObjectId.parse(id);
      
      final result = await collection.findOne(mongo.where.eq('_id', objectId));
      if (result == null) {
        return null;
      }
      
      return ServiceRecordModel.fromJson(result);
    } catch (e) {
      log('Error getting service record by ID: $e');
      return null;
    }
  }

  // Update service record
  Future<void> updateServiceRecord(ServiceRecordModel record) async {
    try {
      if (record.id == null) {
        throw Exception('Cannot update record without ID');
      }

      final collection = await _db.getCollection('service_records');
      
      final result = await collection.replaceOne(
        mongo.where.eq('_id', record.id),
        record.toMap(),
      );

      if (result.isFailure) {
        throw Exception('Failed to update service record');
      }
    } catch (e) {
      throw Exception('Failed to update service record: $e');
    }
  }

  // Delete service record
  Future<void> deleteServiceRecord(String id) async {
    try {
      final collection = await _db.getCollection('service_records');
      final objectId = mongo.ObjectId.parse(id);
      
      final result = await collection.deleteOne({'_id': objectId});
      
      if (result.isFailure) {
        throw Exception('Failed to delete service record');
      }
    } catch (e) {
      throw Exception('Failed to delete service record: $e');
    }
  }
}
