import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/glass_container.dart';

class EnginePerformanceChart extends StatefulWidget {
  final List<EngineStatsModel> stats;
  final String title;
  final Color lineColor;
  final double Function(EngineStatsModel) getValue;
  final String unit;

  const EnginePerformanceChart({
    Key? key,
    required this.stats,
    required this.title,
    required this.getValue,
    this.lineColor = AppTheme.primaryColor,
    this.unit = '',
  }) : super(key: key);

  @override
  State<EnginePerformanceChart> createState() => _EnginePerformanceChartState();
}

class _EnginePerformanceChartState extends State<EnginePerformanceChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.stats.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort stats by timestamp
    final sortedStats = List<EngineStatsModel>.from(widget.stats)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Take last 20 points for better visibility
    final displayStats = sortedStats.length > 20 
        ? sortedStats.sublist(sortedStats.length - 20) 
        : sortedStats;

    final spots = displayStats.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), widget.getValue(entry.value));
    }).toList();

    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final interval = (maxY - minY) > 0 ? (maxY - minY) / 4 : 1.0;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.70,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (displayStats.length - 1).toDouble(),
                minY: minY * 0.9,
                maxY: maxY * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        widget.lineColor,
                        widget.lineColor.withValues(alpha: 0.5),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          widget.lineColor.withValues(alpha: 0.2),
                          widget.lineColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black.withValues(alpha: 0.8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toStringAsFixed(1)} ${widget.unit}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
