import 'package:mongo_dart/mongo_dart.dart';

class ServiceModel {
  final ObjectId? id;
  final ObjectId vehicleId;
  final String title;
  final String? description;
  final DateTime serviceDate;
  final int? mileage;
  final double cost;
  final String? serviceType;
  final List<String>? parts;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    this.id,
    required this.vehicleId,
    required this.title,
    this.description,
    required this.serviceDate,
    this.mileage,
    required this.cost,
    this.serviceType,
    this.parts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'serviceDate': serviceDate,
      'mileage': mileage,
      'cost': cost,
      'serviceType': serviceType,
      'parts': parts,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] as ObjectId,
      vehicleId: json['vehicleId'] as ObjectId,
      title: json['title'] as String,
      description: json['description'] as String?,
      serviceDate: json['serviceDate'] is DateTime 
        ? json['serviceDate'] 
        : DateTime.parse(json['serviceDate'].toString()),
      mileage: json['mileage'] as int?,
      cost: (json['cost'] is int) 
        ? (json['cost'] as int).toDouble() 
        : json['cost'] as double,
      serviceType: json['serviceType'] as String?,
      parts: (json['parts'] as List?)?.map((e) => e as String).toList(),
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : DateTime.parse(json['updatedAt'].toString()),
    );
  }

  ServiceModel copyWith({
    ObjectId? id,
    ObjectId? vehicleId,
    String? title,
    String? description,
    DateTime? serviceDate,
    int? mileage,
    double? cost,
    String? serviceType,
    List<String>? parts,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceDate: serviceDate ?? this.serviceDate,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      serviceType: serviceType ?? this.serviceType,
      parts: parts ?? this.parts,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
