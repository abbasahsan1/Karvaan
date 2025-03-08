import 'package:mongo_dart/mongo_dart.dart';

class VehicleModel {
  final ObjectId? id;
  final ObjectId userId;
  final String name;
  final String registrationNumber;
  final String? make;
  final String? model;
  final int? year;
  final String? color;
  final int? mileage;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    this.id,
    required this.userId,
    required this.name,
    required this.registrationNumber,
    this.make,
    this.model,
    this.year,
    this.color,
    this.mileage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'name': name,
      'registrationNumber': registrationNumber,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'mileage': mileage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id'] as ObjectId,
      userId: json['userId'] as ObjectId,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      mileage: json['mileage'] as int?,
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : DateTime.parse(json['updatedAt'].toString()),
    );
  }

  VehicleModel copyWith({
    ObjectId? id,
    ObjectId? userId,
    String? name,
    String? registrationNumber,
    String? make,
    String? model,
    int? year,
    String? color,
    int? mileage,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      mileage: mileage ?? this.mileage,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
