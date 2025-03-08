import 'dart:developer';
import 'package:karvaan/models/fuel_entry_model.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:mongo_dart/mongo_dart.dart';

class FuelEntryRepository {
  // Singleton pattern
  FuelEntryRepository._privateConstructor();
  static final FuelEntryRepository _instance = FuelEntryRepository._privateConstructor();
  static FuelEntryRepository get instance => _instance;

  // Get collection reference
  Future<DbCollection> get _fuelEntriesCollection async {
    final db = await MongoDBConnection.database;
    return db.collection(MongoDBConnection.fuelEntriesCollection);
  }

  // Get all fuel entries for a vehicle
  Future<List<FuelEntryModel>> getFuelEntriesByVehicleId(ObjectId vehicleId) async {
    try {
      final collection = await _fuelEntriesCollection;
      final cursor = collection.find(where.eq('vehicleId', vehicleId));
      final results = await cursor.toList();
      
      return results.map((doc) => FuelEntryModel.fromJson(doc)).toList();
    } catch (e) {
      log('Error getting fuel entries: $e');
      throw Exception('Failed to retrieve fuel entries: $e');
    }
  }

  // Create a new fuel entry
  Future<FuelEntryModel> createFuelEntry(FuelEntryModel entry) async {
    try {
      final collection = await _fuelEntriesCollection;
      final result = await collection.insertOne(entry.toJson());
      
      if (!result.isSuccess) {
        throw Exception('Failed to create fuel entry');
      }
      
      return entry.copyWith(id: result.id);
    } catch (e) {
      log('Error creating fuel entry: $e');
      throw Exception('Failed to create fuel entry: $e');
    }
  }

  // Get fuel entry by ID
  Future<FuelEntryModel?> getFuelEntryById(ObjectId id) async {
    try {
      final collection = await _fuelEntriesCollection;
      final doc = await collection.findOne(where.id(id));
      
      return doc != null ? FuelEntryModel.fromJson(doc) : null;
    } catch (e) {
      log('Error getting fuel entry by ID: $e');
      throw Exception('Failed to retrieve fuel entry: $e');
    }
  }

  // Update fuel entry
  Future<FuelEntryModel> updateFuelEntry(FuelEntryModel entry) async {
    try {
      final collection = await _fuelEntriesCollection;
      
      if (entry.id == null) {
        throw Exception('Fuel entry ID is required for update');
      }
      
      final entryMap = entry.toJson();
      entryMap.remove('_id'); // MongoDB doesn't allow updating the ID field
      
      final result = await collection.updateOne(
        where.id(entry.id!),
        {
          '\$set': entryMap,
        },
      );
      
      if (result.isFailure) {
        throw Exception('Failed to update fuel entry');
      }
      
      return entry;
    } catch (e) {
      log('Error updating fuel entry: $e');
      throw Exception('Failed to update fuel entry: $e');
    }
  }

  // Delete fuel entry
  Future<void> deleteFuelEntry(ObjectId id) async {
    try {
      final collection = await _fuelEntriesCollection;
      final result = await collection.deleteOne(where.id(id));
      
      if (result.isFailure) {
        throw Exception('Failed to delete fuel entry');
      }
    } catch (e) {
      log('Error deleting fuel entry: $e');
      throw Exception('Failed to delete fuel entry: $e');
    }
  }
}