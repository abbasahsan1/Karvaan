import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karvaan/models/service_model.dart';
import 'package:karvaan/services/service_record_service.dart';

class AddServiceRecordScreen extends StatefulWidget {
  final ServiceModel? existingService;
  final String? vehicleId;

  const AddServiceRecordScreen({
    Key? key,
    this.existingService,
    this.vehicleId,
  }) : super(key: key);

  @override
  State<AddServiceRecordScreen> createState() => _AddServiceRecordScreenState();
}

class _AddServiceRecordScreenState extends State<AddServiceRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _partsController = TextEditingController(); // Comma-separated list
  DateTime _selectedDate = DateTime.now();
  String _selectedServiceType = 'Regular Maintenance';
  bool _isLoading = false;

  final List<String> _serviceTypes = [
    'Regular Maintenance',
    'Oil Change',
    'Brake Service',
    'Tire Service',
    'Engine Service',
    'Electrical Service',
    'Other'
  ];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final ServiceRecordService _serviceRecordService = ServiceRecordService.instance;

  @override
  void initState() {
    super.initState();
    if (widget.existingService != null) {
      _titleController.text = widget.existingService!.title;
      _descriptionController.text = widget.existingService!.description ?? '';
      _costController.text = widget.existingService!.cost.toString();
      _mileageController.text = widget.existingService!.mileage?.toString() ?? '';
      _selectedDate = widget.existingService!.serviceDate;
      _selectedServiceType = widget.existingService!.serviceType ?? 'Regular Maintenance';
      if (widget.existingService!.parts != null) {
        _partsController.text = widget.existingService!.parts!.join(', ');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _partsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  List<String>? _parsePartsList() {
    if (_partsController.text.isEmpty) return null;
    
    final parts = _partsController.text
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    
    return parts.isEmpty ? null : parts;
  }

  Future<void> _saveServiceRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final double cost = double.parse(_costController.text);
        final int? mileage = _mileageController.text.isNotEmpty 
            ? int.tryParse(_mileageController.text) 
            : null;
        
        final String vehicleId = widget.vehicleId ?? 
            (widget.existingService != null 
                ? widget.existingService!.vehicleId.toHexString() 
                : throw Exception('Vehicle ID is required'));

        if (widget.existingService == null) {
          // Add new service record
          await _serviceRecordService.addServiceRecord(
            vehicleId: vehicleId,
            title: _titleController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            serviceDate: _selectedDate,
            mileage: mileage,
            cost: cost,
            serviceType: _selectedServiceType,
            parts: _parsePartsList(),
          );
        } else {
          // Update existing service record
          final updatedService = widget.existingService!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            serviceDate: _selectedDate,
            mileage: mileage,
            cost: cost,
            serviceType: _selectedServiceType,
            parts: _parsePartsList(),
          );
          
          await _serviceRecordService.updateServiceRecord(updatedService);
        }

        // Pop back to previous screen
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingService == null ? 'Add Service Record' : 'Edit Service Record'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker Field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Service Date *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_dateFormat.format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Cost Field
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Mileage Field
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Odometer Reading (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Service Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedServiceType,
                items: _serviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedServiceType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Parts Field
              TextFormField(
                controller: _partsController,
                decoration: const InputDecoration(
                  labelText: 'Parts (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveServiceRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.existingService == null ? 'Add Record' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
