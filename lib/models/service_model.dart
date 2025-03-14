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

class ServiceRecordModel {
  final ObjectId? id;
  final ObjectId userId;
  final ObjectId vehicleId;
  final String title;
  final DateTime date;
  final double cost;
  final int? odometer;
  final String? serviceCenter;
  final String? description;
  final List<String>? partsReplaced;
  final bool isScheduled; // Is this a scheduled maintenance
  final DateTime? reminderDate; // Date for next service reminder
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRecordModel({
    this.id,
    required this.userId,
    required this.vehicleId,
    required this.title,
    required this.date,
    required this.cost,
    this.odometer,
    this.serviceCenter,
    this.description,
    this.partsReplaced,
    this.isScheduled = false,
    this.reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for MongoDB storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'title': title,
      'date': date,
      'cost': cost,
      if (odometer != null) 'odometer': odometer,
      if (serviceCenter != null) 'serviceCenter': serviceCenter,
      if (description != null) 'description': description,
      if (partsReplaced != null) 'partsReplaced': partsReplaced,
      'isScheduled': isScheduled,
      if (reminderDate != null) 'reminderDate': reminderDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from MongoDB document
  factory ServiceRecordModel.fromJson(Map<String, dynamic> json) {
    List<String>? parts;
    if (json['partsReplaced'] != null) {
      parts = (json['partsReplaced'] as List).map((e) => e.toString()).toList();
    }
    
    return ServiceRecordModel(
      id: json['_id'] as ObjectId,
      userId: json['userId'] as ObjectId,
      vehicleId: json['vehicleId'] as ObjectId,
      title: json['title'] as String,
      date: json['date'] is DateTime 
        ? json['date'] 
        : DateTime.parse(json['date'].toString()),
      cost: json['cost'] is int 
        ? (json['cost'] as int).toDouble() 
        : json['cost'] as double,
      odometer: json['odometer'] as int?,
      serviceCenter: json['serviceCenter'] as String?,
      description: json['description'] as String?,
      partsReplaced: parts,
      isScheduled: json['isScheduled'] as bool? ?? false,
      reminderDate: json['reminderDate'] != null
        ? json['reminderDate'] is DateTime
          ? json['reminderDate']
          : DateTime.parse(json['reminderDate'].toString())
        : null,
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : DateTime.parse(json['updatedAt'].toString()),
    );
  }

  ServiceRecordModel copyWith({
    ObjectId? id,
    ObjectId? userId,
    ObjectId? vehicleId,
    String? title,
    DateTime? date,
    double? cost,
    int? odometer,
    String? serviceCenter,
    String? description,
    List<String>? partsReplaced,
    bool? isScheduled,
    DateTime? reminderDate,
  }) {
    return ServiceRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      odometer: odometer ?? this.odometer,
      serviceCenter: serviceCenter ?? this.serviceCenter,
      description: description ?? this.description,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      isScheduled: isScheduled ?? this.isScheduled,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
