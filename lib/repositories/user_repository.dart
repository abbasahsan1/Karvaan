import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:karvaan/models/user_model.dart';
import 'package:karvaan/services/database/mongodb_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  // Private constructor for singleton pattern
  UserRepository._privateConstructor();
  static final UserRepository _instance = UserRepository._privateConstructor();
  static UserRepository get instance => _instance;

  // Get MongoDB collection reference
  final Future<Db> _db = MongoDBConnection.database;
  Future<DbCollection> get _usersCollection async => (await _db).collection('users');

  // Method to get current user ID (returns ObjectId, not String)
  Future<ObjectId?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if (userId == null) {
      return null;
    }
    
    // Convert stored String ID to ObjectId
    return ObjectId.parse(userId);
  }

  // Get user by ID
  Future<UserModel?> getUserById(ObjectId id) async {
    final collection = await _usersCollection;
    final result = await collection.findOne(where.id(id));
    
    if (result == null) {
      return null;
    }
    
    return UserModel.fromJson(result);
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final collection = await _usersCollection;
    final result = await collection.findOne(where.eq('email', email));
    
    if (result == null) {
      return null;
    }
    
    return UserModel.fromJson(result);
  }

  // Create user
  Future<UserModel> createUser(UserModel user) async {
    final collection = await _usersCollection;
    final result = await collection.insertOne(user.toJson());
    
    if (!result.isSuccess) {
      throw Exception('Failed to create user');
    }
    
    // Set the user ID in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', result.id!.$oid);
    
    user = UserModel(
      id: result.id,
      email: user.email,
      password: user.password,
      name: user.name,
      phone: user.phone,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
    
    return user;
  }

  // Update user
  Future<UserModel> updateUser(UserModel user) async {
    final collection = await _usersCollection;
    
    if (user.id == null) {
      throw Exception('User ID is required for update');
    }
    
    final userMap = user.toJson();
    userMap.remove('_id'); // MongoDB doesn't allow updating the ID field
    
    final result = await collection.updateOne(
      where.id(user.id!),
      {
        '\$set': userMap,
      },
    );
    
    if (result.isFailure) {
      throw Exception('Failed to update user');
    }
    
    return user;
  }

  // Delete user
  Future<void> deleteUser(ObjectId id) async {
    final collection = await _usersCollection;
    final result = await collection.deleteOne(where.id(id));
    
    if (result.isFailure) {
      throw Exception('Failed to delete user');
    }
    
    // Remove the user ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Set current user ID in shared preferences
  Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Clear current user ID from shared preferences (for logout)
  Future<void> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}
