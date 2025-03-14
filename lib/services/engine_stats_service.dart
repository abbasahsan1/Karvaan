import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/services/database_service.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:karvaan/providers/user_provider.dart';

class EngineStatsService {
  // Singleton pattern
  EngineStatsService._privateConstructor();
  static final EngineStatsService instance = EngineStatsService._privateConstructor();
  
  final DatabaseService _db = DatabaseService.instance;
  
  // Get the latest engine stats for a vehicle
  Future<EngineStatsModel?> getLatestEngineStatsForVehicle(String vehicleId) async {
    try {
      final collection = await _db.getCollection(MongoDBConnection.engineStatsCollection);
      final result = await collection.findOne(
        where.eq('vehicleId', ObjectId.fromHexString(vehicleId))
          .sortBy('timestamp', descending: true)
      );
      
      if (result == null) return null;
      
      return EngineStatsModel.fromJson(result);
    } catch (e) {
      log('Error getting latest engine stats: $e');
      throw Exception('Failed to get latest engine stats: $e');
    }
  }
  
  // Get all engine stats for a vehicle
  Future<List<EngineStatsModel>> getEngineStatsForVehicle(String vehicleId) async {
    try {
      final collection = await _db.getCollection(MongoDBConnection.engineStatsCollection);
      final results = await collection.find(
        where.eq('vehicleId', ObjectId.fromHexString(vehicleId))
          .sortBy('timestamp', descending: true)
      ).toList();
      
      return results.map((json) => EngineStatsModel.fromJson(json)).toList();
    } catch (e) {
      log('Error getting engine stats: $e');
      throw Exception('Failed to get engine stats: $e');
    }
  }
  
  // Add new engine stats
  Future<EngineStatsModel> addEngineStats({
    required String vehicleId,
    required double engineRpm,
    required double calculatedLoadValue,
    required double coolantTemperature,
    required String fuelSystemStatus,
    required double vehicleSpeed,
    required double shortTermFuelTrim,
    required double longTermFuelTrim,
    required double intakeManifoldPressure,
    required double timingAdvance,
    required double intakeAirTemperature,
    required double airFlowRate,
    required double absoluteThrottlePosition,
    required Map<String, double> oxygenSensorVoltages,
    required Map<String, double> oxygenSensorFuelTrims,
    required double fuelPressure,
  }) async {
    try {
      // We should get the userId from the passed parameter or context
      // For now, using a placeholder ObjectId
      final userId = ObjectId();
      
      final newStats = EngineStatsModel(
        userId: userId,
        vehicleId: ObjectId.fromHexString(vehicleId),
        timestamp: DateTime.now(),
        engineRpm: engineRpm,
        calculatedLoadValue: calculatedLoadValue,
        coolantTemperature: coolantTemperature,
        fuelSystemStatus: fuelSystemStatus,
        vehicleSpeed: vehicleSpeed,
        shortTermFuelTrim: shortTermFuelTrim,
        longTermFuelTrim: longTermFuelTrim,
        intakeManifoldPressure: intakeManifoldPressure,
        timingAdvance: timingAdvance,
        intakeAirTemperature: intakeAirTemperature,
        airFlowRate: airFlowRate,
        absoluteThrottlePosition: absoluteThrottlePosition,
        oxygenSensorVoltages: oxygenSensorVoltages,
        oxygenSensorFuelTrims: oxygenSensorFuelTrims,
        fuelPressure: fuelPressure,
      );
      
      final collection = await _db.getCollection(MongoDBConnection.engineStatsCollection);
      final result = await collection.insertOne(newStats.toMap());
      
      if (result.isSuccess) {
        return newStats.copyWith(id: result.id as ObjectId);
      }
      
      throw Exception('Failed to add engine stats');
    } catch (e) {
      log('Error adding engine stats: $e');
      throw Exception('Failed to add engine stats: $e');
    }
  }
  
  // Generate random engine stats for demo purposes
  Future<EngineStatsModel> generateRandomEngineStats(String vehicleId) async {
    try {
      // We should get the userId from the passed parameter or context
      // For now, using a placeholder ObjectId
      final userId = ObjectId();
      
      final randomStats = EngineStatsModel.generateRandom(
        userId: userId,
        vehicleId: ObjectId.fromHexString(vehicleId),
      );
      
      final collection = await _db.getCollection(MongoDBConnection.engineStatsCollection);
      final result = await collection.insertOne(randomStats.toMap());
      
      if (result.isSuccess) {
        return randomStats.copyWith(id: result.id as ObjectId);
      }
      
      throw Exception('Failed to generate random engine stats');
    } catch (e) {
      log('Error generating random engine stats: $e');
      throw Exception('Failed to generate random engine stats: $e');
    }
  }
  
  // Delete engine stats
  Future<void> deleteEngineStats(String id) async {
    try {
      final collection = await _db.getCollection(MongoDBConnection.engineStatsCollection);
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      
      if (!result.isSuccess) {
        throw Exception('Failed to delete engine stats');
      }
    } catch (e) {
      log('Error deleting engine stats: $e');
      throw Exception('Failed to delete engine stats: $e');
    }
  }
}