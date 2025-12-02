import 'package:flutter/material.dart';
import 'package:karvaan/models/engine_stats_model.dart';
import 'package:karvaan/models/metric_definition.dart';
import 'package:karvaan/services/engine_stats_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/engine_performance_chart.dart';
import 'package:karvaan/widgets/glass_container.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MetricDetailScreen extends StatefulWidget {
  final MetricDefinition definition;
  final String vehicleId;

  const MetricDetailScreen({
    Key? key,
    required this.definition,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  bool _isLoading = true;
  List<EngineStatsModel> _history = [];
  final _engineStatsService = EngineStatsService.instance;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _engineStatsService.getEngineStatsForVehicle(widget.vehicleId);
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate current value (last in history)
    double currentValue = 0;
    if (_history.isNotEmpty) {
      // Assuming history is sorted or we take the last one added
      // EngineStatsService usually returns sorted by timestamp descending or ascending?
      // Let's sort to be safe
      _history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      currentValue = widget.definition.getValue(_history.last);
    }

    return KarvaanScaffoldShell(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.definition.name),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppTheme.primaryColor,
                  size: 50,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big Current Value Display
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.definition.color.withValues(alpha: 0.1),
                              border: Border.all(
                                color: widget.definition.color.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              widget.definition.icon,
                              size: 40,
                              color: widget.definition.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.definition.formatValue(currentValue),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.definition.unit,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Chart
                    EnginePerformanceChart(
                      title: 'History',
                      stats: _history,
                      getValue: widget.definition.getValue,
                      unit: widget.definition.unit,
                      lineColor: widget.definition.color,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Logs List (Optional but nice)
                    Text(
                      'Recent Logs',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length > 10 ? 10 : _history.length,
                      itemBuilder: (context, index) {
                        // Show latest first
                        final stat = _history[_history.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            borderRadius: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTimestamp(stat.timestamp),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  '${widget.definition.formatValue(widget.definition.getValue(stat))} ${widget.definition.unit}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    // Simple formatter, could use intl package but keeping it simple for now
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}
