import 'package:mongo_dart/mongo_dart.dart';

class FuelEntryModel {
  final ObjectId? id;
  final ObjectId userId;
  final ObjectId vehicleId;
  final DateTime date;
  final double amount; // Amount in liters
  final double cost;  // Total cost
  final int? odometer; // Current mileage
  final String? notes;
  final bool isFullTank;
  final DateTime createdAt;
  final DateTime updatedAt;

  FuelEntryModel({
    this.id,
    required this.userId,
    required this.vehicleId,
    required this.date,
    required this.amount,
    required this.cost,
    this.odometer,
    this.notes,
    this.isFullTank = true,
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
      'date': date,
      'amount': amount,
      'cost': cost,
      if (odometer != null) 'odometer': odometer,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'isFullTank': isFullTank,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from MongoDB document
  factory FuelEntryModel.fromJson(Map<String, dynamic> json) {
    return FuelEntryModel(
      id: json['_id'] as ObjectId,
      userId: json['userId'] as ObjectId,
      vehicleId: json['vehicleId'] as ObjectId,
      date: json['date'] is DateTime 
        ? json['date'] 
        : DateTime.parse(json['date'].toString()),
      amount: json['amount'] is int 
        ? (json['amount'] as int).toDouble() 
        : json['amount'] as double,
      cost: json['cost'] is int 
        ? (json['cost'] as int).toDouble() 
        : json['cost'] as double,
      odometer: json['odometer'] as int?,
      notes: json['notes'] as String?,
      isFullTank: json['isFullTank'] as bool? ?? true,
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
    ObjectId? userId,
    ObjectId? vehicleId,
    DateTime? date,
    double? amount,
    double? cost,
    int? odometer,
    String? notes,
    bool? isFullTank,
  }) {
    return FuelEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      cost: cost ?? this.cost,
      odometer: odometer ?? this.odometer,
      notes: notes ?? this.notes,
      isFullTank: isFullTank ?? this.isFullTank,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Calculate fuel price per liter
  double get pricePerLiter => amount > 0 ? cost / amount : 0;
}
