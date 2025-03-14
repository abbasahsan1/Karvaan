import 'package:mongo_dart/mongo_dart.dart';

class EngineStatsModel {
  final ObjectId? id;
  final ObjectId userId;
  final ObjectId vehicleId;
  final DateTime timestamp;
  
  // Engine health metrics
  final double engineRpm;
  final double calculatedLoadValue; // Percentage
  final double coolantTemperature; // Celsius
  final String fuelSystemStatus;
  final double vehicleSpeed; // km/h
  final double shortTermFuelTrim; // Percentage
  final double longTermFuelTrim; // Percentage
  final double intakeManifoldPressure; // kPa
  final double timingAdvance; // Degrees
  final double intakeAirTemperature; // Celsius
  final double airFlowRate; // g/s
  final double absoluteThrottlePosition; // Percentage
  final Map<String, double> oxygenSensorVoltages; // Map of sensor ID to voltage
  final Map<String, double> oxygenSensorFuelTrims; // Map of sensor ID to fuel trim percentage
  final double fuelPressure; // kPa
  
  final DateTime createdAt;
  final DateTime updatedAt;

  EngineStatsModel({
    this.id,
    required this.userId,
    required this.vehicleId,
    required this.timestamp,
    required this.engineRpm,
    required this.calculatedLoadValue,
    required this.coolantTemperature,
    required this.fuelSystemStatus,
    required this.vehicleSpeed,
    required this.shortTermFuelTrim,
    required this.longTermFuelTrim,
    required this.intakeManifoldPressure,
    required this.timingAdvance,
    required this.intakeAirTemperature,
    required this.airFlowRate,
    required this.absoluteThrottlePosition,
    required this.oxygenSensorVoltages,
    required this.oxygenSensorFuelTrims,
    required this.fuelPressure,
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
      'timestamp': timestamp,
      'engineRpm': engineRpm,
      'calculatedLoadValue': calculatedLoadValue,
      'coolantTemperature': coolantTemperature,
      'fuelSystemStatus': fuelSystemStatus,
      'vehicleSpeed': vehicleSpeed,
      'shortTermFuelTrim': shortTermFuelTrim,
      'longTermFuelTrim': longTermFuelTrim,
      'intakeManifoldPressure': intakeManifoldPressure,
      'timingAdvance': timingAdvance,
      'intakeAirTemperature': intakeAirTemperature,
      'airFlowRate': airFlowRate,
      'absoluteThrottlePosition': absoluteThrottlePosition,
      'oxygenSensorVoltages': oxygenSensorVoltages,
      'oxygenSensorFuelTrims': oxygenSensorFuelTrims,
      'fuelPressure': fuelPressure,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from MongoDB document
  factory EngineStatsModel.fromJson(Map<String, dynamic> json) {
    return EngineStatsModel(
      id: json['_id'] as ObjectId?,
      userId: json['userId'] as ObjectId,
      vehicleId: json['vehicleId'] as ObjectId,
      timestamp: json['timestamp'] is DateTime 
        ? json['timestamp'] 
        : DateTime.parse(json['timestamp'].toString()),
      engineRpm: _parseDouble(json['engineRpm']),
      calculatedLoadValue: _parseDouble(json['calculatedLoadValue']),
      coolantTemperature: _parseDouble(json['coolantTemperature']),
      fuelSystemStatus: json['fuelSystemStatus'] as String,
      vehicleSpeed: _parseDouble(json['vehicleSpeed']),
      shortTermFuelTrim: _parseDouble(json['shortTermFuelTrim']),
      longTermFuelTrim: _parseDouble(json['longTermFuelTrim']),
      intakeManifoldPressure: _parseDouble(json['intakeManifoldPressure']),
      timingAdvance: _parseDouble(json['timingAdvance']),
      intakeAirTemperature: _parseDouble(json['intakeAirTemperature']),
      airFlowRate: _parseDouble(json['airFlowRate']),
      absoluteThrottlePosition: _parseDouble(json['absoluteThrottlePosition']),
      oxygenSensorVoltages: (json['oxygenSensorVoltages'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, _parseDouble(value)),
      ),
      oxygenSensorFuelTrims: (json['oxygenSensorFuelTrims'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, _parseDouble(value)),
      ),
      fuelPressure: _parseDouble(json['fuelPressure']),
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : DateTime.parse(json['updatedAt'].toString()),
    );
  }

  // Helper method to parse double values from various types
  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Generate random engine stats for demo purposes
  static EngineStatsModel generateRandom({
    required ObjectId userId,
    required ObjectId vehicleId,
  }) {
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 100;
    
    // Create a map with 2-4 oxygen sensors
    final oxygenSensorCount = 2 + (random * 3).floor();
    final oxygenSensorVoltages = <String, double>{};
    final oxygenSensorFuelTrims = <String, double>{};
    
    for (var i = 1; i <= oxygenSensorCount; i++) {
      oxygenSensorVoltages['Bank1-Sensor$i'] = 0.1 + (random * 0.9); // 0.1-1.0V
      oxygenSensorFuelTrims['Bank1-Sensor$i'] = -10 + (random * 20); // -10% to +10%
    }
    
    return EngineStatsModel(
      userId: userId,
      vehicleId: vehicleId,
      timestamp: DateTime.now(),
      engineRpm: 700 + (random * 5000), // 700-5700 RPM
      calculatedLoadValue: random * 100, // 0-100%
      coolantTemperature: 80 + (random * 40), // 80-120°C
      fuelSystemStatus: random > 0.8 ? 'Open Loop' : 'Closed Loop',
      vehicleSpeed: random * 120, // 0-120 km/h
      shortTermFuelTrim: -10 + (random * 20), // -10% to +10%
      longTermFuelTrim: -10 + (random * 20), // -10% to +10%
      intakeManifoldPressure: 30 + (random * 70), // 30-100 kPa
      timingAdvance: random * 40, // 0-40 degrees
      intakeAirTemperature: 10 + (random * 40), // 10-50°C
      airFlowRate: 5 + (random * 15), // 5-20 g/s
      absoluteThrottlePosition: random * 100, // 0-100%
      oxygenSensorVoltages: oxygenSensorVoltages,
      oxygenSensorFuelTrims: oxygenSensorFuelTrims,
      fuelPressure: 300 + (random * 100), // 300-400 kPa
    );
  }

  EngineStatsModel copyWith({
    ObjectId? id,
    ObjectId? userId,
    ObjectId? vehicleId,
    DateTime? timestamp,
    double? engineRpm,
    double? calculatedLoadValue,
    double? coolantTemperature,
    String? fuelSystemStatus,
    double? vehicleSpeed,
    double? shortTermFuelTrim,
    double? longTermFuelTrim,
    double? intakeManifoldPressure,
    double? timingAdvance,
    double? intakeAirTemperature,
    double? airFlowRate,
    double? absoluteThrottlePosition,
    Map<String, double>? oxygenSensorVoltages,
    Map<String, double>? oxygenSensorFuelTrims,
    double? fuelPressure,
  }) {
    return EngineStatsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      timestamp: timestamp ?? this.timestamp,
      engineRpm: engineRpm ?? this.engineRpm,
      calculatedLoadValue: calculatedLoadValue ?? this.calculatedLoadValue,
      coolantTemperature: coolantTemperature ?? this.coolantTemperature,
      fuelSystemStatus: fuelSystemStatus ?? this.fuelSystemStatus,
      vehicleSpeed: vehicleSpeed ?? this.vehicleSpeed,
      shortTermFuelTrim: shortTermFuelTrim ?? this.shortTermFuelTrim,
      longTermFuelTrim: longTermFuelTrim ?? this.longTermFuelTrim,
      intakeManifoldPressure: intakeManifoldPressure ?? this.intakeManifoldPressure,
      timingAdvance: timingAdvance ?? this.timingAdvance,
      intakeAirTemperature: intakeAirTemperature ?? this.intakeAirTemperature,
      airFlowRate: airFlowRate ?? this.airFlowRate,
      absoluteThrottlePosition: absoluteThrottlePosition ?? this.absoluteThrottlePosition,
      oxygenSensorVoltages: oxygenSensorVoltages ?? this.oxygenSensorVoltages,
      oxygenSensorFuelTrims: oxygenSensorFuelTrims ?? this.oxygenSensorFuelTrims,
      fuelPressure: fuelPressure ?? this.fuelPressure,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}