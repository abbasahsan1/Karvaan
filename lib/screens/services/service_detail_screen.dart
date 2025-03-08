import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/services/service_record_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServiceRecordService _serviceRecordService = ServiceRecordService.instance;
  bool _isLoading = true;
  ServiceModel? _service;
  String? _errorMessage;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadServiceRecord();
  }

  Future<void> _loadServiceRecord() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await _serviceRecordService.getServiceRecordById(widget.serviceId);
      
      if (mounted) {
        setState(() {
          _service = service;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading service record: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editServiceRecord() async {
    if (_service == null) return;

    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.addService,
      arguments: {'existingService': _service},
    );

    if (result == true) {
      _loadServiceRecord();
    }
  }

  Future<void> _deleteServiceRecord() async {
    if (_service == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this service record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _serviceRecordService.deleteServiceRecord(widget.serviceId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service record deleted')),
          );
          Navigator.pop(context, true); // Return to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting service record: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        actions: [
          if (!_isLoading && _service != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editServiceRecord,
            ),
          if (!_isLoading && _service != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteServiceRecord,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _service == null
                  ? const Center(child: Text('Service record not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Date
                          Text(
                            _service!.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dateFormat.format(_service!.serviceDate),
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const Divider(height: 32),
                          
                          // Cost
                          _buildInfoRow('Cost', '\$${_service!.cost.toStringAsFixed(2)}'),
                          
                          // Mileage (if available)
                          if (_service!.mileage != null)
                            _buildInfoRow('Mileage', '${_service!.mileage} km'),
                          
                          // Service Type (if available)
                          if (_service!.serviceType != null)
                            _buildInfoRow('Type', _service!.serviceType!),
                          
                          // Parts (if available)
                          if (_service!.parts != null && _service!.parts!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parts',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  ...(_service!.parts!.map((part) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle, size: 8),
                                        const SizedBox(width: 8),
                                        Text(part),
                                      ],
                                    ),
                                  ))).toList(),
                                ],
                              ),
                            ),
                          
                          // Description (if available)
                          if (_service!.description != null && _service!.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_service!.description!),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}