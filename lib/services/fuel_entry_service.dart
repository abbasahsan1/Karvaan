import 'dart:developer';
import 'package:karvaan/models/fuel_entry_model.dart';
import 'package:karvaan/services/auth_service.dart';
import 'package:karvaan/services/database_service.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class FuelEntryService {
  FuelEntryService._privateConstructor();
  static final FuelEntryService instance = FuelEntryService._privateConstructor();

  final _db = DatabaseService.instance;
  final _authService = AuthService.instance;

  Future<List<FuelEntryModel>> getFuelEntriesForVehicle(String vehicleId) async {
    try {
      final collection = await _db.getCollection('fuel_entries');
      final vehicleObjectId = mongo.ObjectId.parse(vehicleId);
      
      final cursor = await collection.find(
        mongo.where.eq('vehicleId', vehicleObjectId).sortBy('date', descending: true)
      );
      
      final List<Map<String, dynamic>> entries = await cursor.toList();
      return entries.map((json) => FuelEntryModel.fromJson(json)).toList();
    } catch (e) {
      log('Error getting fuel entries: $e');
      throw Exception('Failed to get fuel entries: $e');
    }
  }

  Future<FuelEntryModel> addFuelEntry({
    required String vehicleId,
    required DateTime date,
    required double amount,
    required double cost,
    int? odometer,
    String? notes,
    bool isFullTank = true,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.id!;
      final vehicleObjectId = mongo.ObjectId.parse(vehicleId);
      
      final newEntry = FuelEntryModel(
        userId: userId,
        vehicleId: vehicleObjectId,
        date: date,
        amount: amount,
        cost: cost,
        odometer: odometer,
        notes: notes,
        isFullTank: isFullTank,
      );

      final collection = await _db.getCollection('fuel_entries');
      final result = await collection.insertOne(newEntry.toMap());
      
      if (result.isSuccess) {
        final id = result.id as mongo.ObjectId;
        return newEntry.copyWith(id: id);
      } else {
        throw Exception('Failed to add fuel entry');
      }
    } catch (e) {
      log('Error adding fuel entry: $e');
      throw Exception('Failed to add fuel entry: $e');
    }
  }

  Future<FuelEntryModel?> getFuelEntryById(String id) async {
    try {
      final collection = await _db.getCollection('fuel_entries');
      final objectId = mongo.ObjectId.parse(id);
      
      final result = await collection.findOne(mongo.where.eq('_id', objectId));
      if (result == null) {
        return null;
      }
      
      return FuelEntryModel.fromJson(result);
    } catch (e) {
      log('Error getting fuel entry by ID: $e');
      return null;
    }
  }

  Future<void> updateFuelEntry(FuelEntryModel entry) async {
    try {
      if (entry.id == null) {
        throw Exception('Cannot update entry without ID');
      }

      final collection = await _db.getCollection('fuel_entries');
      
      final result = await collection.replaceOne(
        mongo.where.eq('_id', entry.id),
        entry.toMap(),
      );

      if (result.isFailure) {
        throw Exception('Failed to update fuel entry');
      }
    } catch (e) {
      log('Error updating fuel entry: $e');
      throw Exception('Failed to update fuel entry: $e');
    }
  }

  Future<void> deleteFuelEntry(String id) async {
    try {
      final collection = await _db.getCollection('fuel_entries');
      final objectId = mongo.ObjectId.parse(id);
      
      final result = await collection.deleteOne({'_id': objectId});
      
      if (result.isFailure) {
        throw Exception('Failed to delete fuel entry');
      }
    } catch (e) {
      log('Error deleting fuel entry: $e');
      throw Exception('Failed to delete fuel entry: $e');
    }
  }

  // Get statistics for a vehicle
  Future<Map<String, dynamic>> getVehicleStatistics(String vehicleId) async {
    try {
      final entries = await getFuelEntriesForVehicle(vehicleId);
      
      double totalCost = 0;
      double totalAmount = 0;
      double? avgConsumption;
      int entriesCount = entries.length;
      
      int? minOdometer;
      int? maxOdometer;
      int? distance;
      
      for (var entry in entries) {
        totalCost += entry.cost;
        totalAmount += entry.amount;
        
        if (entry.odometer != null) {
          if (minOdometer == null || entry.odometer! < minOdometer) {
            minOdometer = entry.odometer;
          }
          
          if (maxOdometer == null || entry.odometer! > maxOdometer) {
            maxOdometer = entry.odometer;
          }
        }
      }
      
      // Calculate distance driven if we have odometer readings
      if (minOdometer != null && maxOdometer != null) {
        distance = maxOdometer - minOdometer;
        
        // Calculate avg consumption per 100km if we have distance
        if (distance > 0) {
          avgConsumption = (totalAmount * 100) / distance;
        }
      }
      
      return {
        'totalCost': totalCost,
        'totalAmount': totalAmount,
        'entriesCount': entriesCount,
        'distance': distance,
        'avgConsumption': avgConsumption,
        'avgCostPerLiter': totalAmount > 0 ? totalCost / totalAmount : null,
      };
    } catch (e) {
      log('Error getting vehicle statistics: $e');
      rethrow;
    }
  }
}
