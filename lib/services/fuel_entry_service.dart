import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/models/fuel_entry_model.dart';
import 'package:karvaan/repositories/fuel_entry_repository.dart';

class FuelEntryService {
  final FuelEntryRepository _fuelEntryRepository = FuelEntryRepository.instance;
  
  // Singleton pattern
  FuelEntryService._privateConstructor();
  static final FuelEntryService _instance = FuelEntryService._privateConstructor();
  static FuelEntryService get instance => _instance;

  // Get all fuel entries for a vehicle
  Future<List<FuelEntryModel>> getFuelEntriesForVehicle(String vehicleId) async {
    try {
      // Convert String to ObjectId
      final vehicleObjId = ObjectId.parse(vehicleId);
      return await _fuelEntryRepository.getFuelEntriesByVehicleId(vehicleObjId);
    } catch (e) {
      log('Error getting fuel entries for vehicle: $e');
      return [];
    }
  }

  // Add a new fuel entry
  Future<FuelEntryModel> addFuelEntry({
    required String vehicleId,
    required DateTime date,
    required double quantity,
    required double cost,
    int? mileage,
    String? fuelType,
    bool fullTank = true,
    String? notes,
  }) async {
    try {
      // Convert String to ObjectId
      final vehicleObjId = ObjectId.parse(vehicleId);
      
      final fuelEntry = FuelEntryModel(
        vehicleId: vehicleObjId,
        date: date,
        quantity: quantity,
        cost: cost,
        mileage: mileage,
        fuelType: fuelType,
        fullTank: fullTank,
        notes: notes,
      );
      
      return await _fuelEntryRepository.createFuelEntry(fuelEntry);
    } catch (e) {
      log('Error adding fuel entry: $e');
      rethrow;
    }
  }

  // Get fuel entry by ID
  Future<FuelEntryModel?> getFuelEntryById(String id) async {
    try {
      // Convert String to ObjectId
      final objectId = ObjectId.parse(id);
      return await _fuelEntryRepository.getFuelEntryById(objectId);
    } catch (e) {
      log('Error getting fuel entry by ID: $e');
      return null;
    }
  }

  // Update fuel entry
  Future<FuelEntryModel> updateFuelEntry(FuelEntryModel fuelEntry) async {
    try {
      return await _fuelEntryRepository.updateFuelEntry(fuelEntry);
    } catch (e) {
      log('Error updating fuel entry: $e');
      rethrow;
    }
  }

  // Delete fuel entry
  Future<void> deleteFuelEntry(String id) async {
    try {
      // Convert String to ObjectId
      final objectId = ObjectId.parse(id);
      await _fuelEntryRepository.deleteFuelEntry(objectId);
    } catch (e) {
      log('Error deleting fuel entry: $e');
      rethrow;
    }
  }
}
