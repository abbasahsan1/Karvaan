import 'package:flutter/material.dart';
import 'package:karvaan/models/engine_stats_model.dart';

class MetricDefinition {
  final String id;
  final String name;
  final IconData icon;
  final String unit;
  final Color color;
  final double Function(EngineStatsModel) getValue;
  final String Function(double) formatValue;

  const MetricDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.unit,
    required this.color,
    required this.getValue,
    this.formatValue = _defaultFormat,
  });

  static String _defaultFormat(double value) {
    return value.toStringAsFixed(1);
  }
}
