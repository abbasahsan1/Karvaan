import 'package:mongo_dart/mongo_dart.dart';

class ServiceLocationModel {
  final ObjectId? id;
  final ObjectId userId;
  final String name;
  final String category;
  final String? address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceLocationModel({
    this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.address,
    required this.latitude,
    required this.longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'name': name,
      'category': category,
      if (address != null) 'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ServiceLocationModel.fromJson(Map<String, dynamic> json) {
    return ServiceLocationModel(
      id: json['_id'] as ObjectId?,
      userId: json['userId'] as ObjectId,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  ServiceLocationModel copyWith({
    ObjectId? id,
    ObjectId? userId,
    String? name,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return ServiceLocationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
