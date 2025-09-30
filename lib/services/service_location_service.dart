import 'dart:developer';

import 'package:karvaan/models/service_location_model.dart';
import 'package:karvaan/services/auth_service.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:karvaan/services/database_service.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ServiceLocationService {
  ServiceLocationService._();
  static final ServiceLocationService instance = ServiceLocationService._();

  final DatabaseService _databaseService = DatabaseService.instance;
  final AuthService _authService = AuthService.instance;

  Future<List<ServiceLocationModel>> getSavedLocations() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('User not authenticated');
      }

      final collection = await _databaseService.getCollection(
        MongoDBConnection.serviceLocationsCollection,
      );

  final cursor = collection.find(mongo.where.eq('userId', currentUser.id));
  final docs = await cursor.toList();
      return docs.map((doc) => ServiceLocationModel.fromJson(doc)).toList();
    } catch (e, stack) {
      log('Failed to load saved locations: $e', stackTrace: stack);
      rethrow;
    }
  }

  Future<ServiceLocationModel> saveLocation({
    required String name,
    required String category,
    String? address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('User not authenticated');
      }

      final location = ServiceLocationModel(
        userId: currentUser.id!,
        name: name,
        category: category,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      final collection = await _databaseService.getCollection(
        MongoDBConnection.serviceLocationsCollection,
      );
      final result = await collection.insertOne(location.toMap());

      if (result.isSuccess) {
        final insertedId = result.id as mongo.ObjectId;
        return location.copyWith(id: insertedId);
      }

      throw Exception('Failed to save location');
    } catch (e, stack) {
      log('Failed to save location: $e', stackTrace: stack);
      rethrow;
    }
  }
}
