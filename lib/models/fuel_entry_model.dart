import 'package:mongo_dart/mongo_dart.dart';

class FuelEntryModel {
  final ObjectId? id;
  final ObjectId vehicleId;
  final DateTime date;
  final double quantity;
  final double cost;
  final int? mileage;
  final String? fuelType;
  final bool fullTank;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FuelEntryModel({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.quantity,
    required this.cost,
    this.mileage,
    this.fuelType,
    this.fullTank = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'vehicleId': vehicleId,
      'date': date,
      'quantity': quantity,
      'cost': cost,
      'mileage': mileage,
      'fuelType': fuelType,
      'fullTank': fullTank,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory FuelEntryModel.fromJson(Map<String, dynamic> json) {
    return FuelEntryModel(
      id: json['_id'] as ObjectId,
      vehicleId: json['vehicleId'] as ObjectId,
      date: json['date'] is DateTime 
        ? json['date'] 
        : DateTime.parse(json['date'].toString()),
      quantity: (json['quantity'] is int) 
        ? (json['quantity'] as int).toDouble() 
        : json['quantity'] as double,
      cost: (json['cost'] is int) 
        ? (json['cost'] as int).toDouble() 
        : json['cost'] as double,
      mileage: json['mileage'] as int?,
      fuelType: json['fuelType'] as String?,
      fullTank: json['fullTank'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : DateTime.parse(json['updatedAt'].toString()),
    );
  }

  FuelEntryModel copyWith({
    ObjectId? id,
    ObjectId? vehicleId,
    DateTime? date,
    double? quantity,
    double? cost,
    int? mileage,
    String? fuelType,
    bool? fullTank,
    String? notes,
  }) {
    return FuelEntryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      fullTank: fullTank ?? this.fullTank,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
