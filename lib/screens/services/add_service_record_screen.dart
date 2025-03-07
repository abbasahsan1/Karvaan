import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';

class AddServiceRecordScreen extends StatefulWidget {
  final Map<String, dynamic>? existingService; // For editing an existing service, null for new
  final String? vehicleId; // If coming from a specific vehicle, this will be set

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
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  final _serviceDateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVehicle;
  String? _selectedServiceType;
  DateTime? _selectedServiceDate;
  bool _isRecurring = false;
  String? _selectedRecurrenceInterval;

  // Mock data for dropdowns
  final List<String> _vehicles = ['Toyota Corolla', 'Honda City', 'Suzuki Alto'];
  final List<String> _serviceTypes = [
    'Oil Change', 
    'Brake Pad Replacement', 
    'Tire Rotation', 
    'Air Filter Replacement', 
    'Annual Inspection',
    'Other'
  ];
  final List<String> _recurrenceIntervals = [
    'Every 3 months',
    'Every 6 months',
    'Yearly',
    'Every 5,000 km',
    'Every 10,000 km',
    'Every 20,000 km',
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
    // If vehicle ID is provided, set the selected vehicle
    if (widget.vehicleId != null) {
      // In a real app, you would look up the vehicle name from the ID
      _selectedVehicle = _vehicles.first;
    }

    // If editing, populate the form with existing service data
    if (widget.existingService != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final service = widget.existingService!;
    _titleController.text = service['title'] ?? '';
    _descriptionController.text = service['description'] ?? '';
    _serviceProviderController.text = service['serviceProvider'] ?? '';
    _odometerController.text = service['odometer']?.toString().replaceAll(' km', '') ?? '';
    _costController.text = service['cost']?.toString().replaceAll('Rs. ', '').replaceAll(',', '') ?? '';
    _notesController.text = service['notes'] ?? '';
    _selectedVehicle = service['vehicle'];
    _selectedServiceType = service['serviceType'];
    _isRecurring = service['isRecurring'] ?? false;
    _selectedRecurrenceInterval = service['recurrenceInterval'];
    
    // Handle service date
    if (service['serviceDate'] != null) {
      final dateParts = service['serviceDate'].toString().split(' ');
      if (dateParts.length == 3) {
        final month = _getMonthNumber(dateParts[0]);
        final day = int.parse(dateParts[1].replaceAll(',', ''));
        final year = int.parse(dateParts[2]);
        _selectedServiceDate = DateTime(year, month, day);
        _serviceDateController.text = '${dateParts[0]} ${dateParts[1]} ${dateParts[2]}';
      }
    }
  }

  int _getMonthNumber(String month) {
    final months = {
      'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6,
      'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12
    };
    return months[month] ?? 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _serviceProviderController.dispose();
    _serviceDateController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectServiceDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedServiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedServiceDate) {
      setState(() {
        _selectedServiceDate = picked;
        _serviceDateController.text = '${_getMonthName(picked.month)} ${picked.day}, ${picked.year}';
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _saveServiceRecord() {
    if (_formKey.currentState!.validate()) {
      // Create service record object
      final service = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'vehicle': _selectedVehicle,
        'serviceType': _selectedServiceType,
        'serviceProvider': _serviceProviderController.text,
        'serviceDate': _serviceDateController.text,
        'odometer': '${_odometerController.text} km',
        'cost': 'Rs. ${_costController.text}',
        'notes': _notesController.text,
        'isRecurring': _isRecurring,
        'recurrenceInterval': _isRecurring ? _selectedRecurrenceInterval : null,
      };
      
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service record saved successfully'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      
      // Return to previous screen
      Navigator.pop(context, service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingService != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Service Record' : 'Add Service Record'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildServiceDetailsSection(),
              const SizedBox(height: 24),
              _buildRecurrenceSection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Update Service Record' : 'Save Service Record',
                onPressed: _saveServiceRecord,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Vehicle',
              ),
              value: _selectedVehicle,
              items: _vehicles.map((String vehicle) {
                return DropdownMenuItem<String>(
                  value: vehicle,
                  child: Text(vehicle),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVehicle = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a vehicle';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Service Type',
              ),
              value: _selectedServiceType,
              items: _serviceTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServiceType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a service type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Service Title',
                hintText: 'e.g. Regular Oil Change',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title for this service';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description of the service',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceProviderController,
              decoration: const InputDecoration(
                labelText: 'Service Provider',
                hintText: 'e.g. ABC Workshop',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceDateController,
              decoration: const InputDecoration(
                labelText: 'Service Date',
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectServiceDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a service date';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(
                labelText: 'Odometer Reading (km)',
                hintText: 'e.g. 15000',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the odometer reading';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost (Rs.)',
                hintText: 'e.g. 2500',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the service cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recurrence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _isRecurring,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Set as recurring service'),
              ],
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Recurrence Interval',
                ),
                value: _selectedRecurrenceInterval,
                items: _recurrenceIntervals.map((String interval) {
                  return DropdownMenuItem<String>(
                    value: interval,
                    child: Text(interval),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRecurrenceInterval = newValue;
                  });
                },
                validator: (value) {
                  if (_isRecurring && (value == null || value.isEmpty)) {
                    return 'Please select a recurrence interval';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Any additional information about this service',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
