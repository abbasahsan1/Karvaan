import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karvaan/services/service_record_service.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _serviceCenterController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isScheduled = false;
  bool _updateVehicleMileage = false;
  bool _hasReminder = false;
  DateTime? _reminderDate;
  final TextEditingController _reminderDateController = TextEditingController();
  
  final List<String> _partsReplaced = [];
  final TextEditingController _partController = TextEditingController();

  bool _isLoading = false;
  late String _vehicleId;
  late String _vehicleName;
  
  final ServiceRecordService _serviceService = ServiceRecordService.instance;
  final VehicleService _vehicleService = VehicleService.instance;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        _vehicleId = args['vehicleId'];
        _vehicleName = args['vehicleName'];
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _serviceCenterController.dispose();
    _descriptionController.dispose();
    _reminderDateController.dispose();
    _partController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isReminderDate) async {
    // For reminder dates, allow future dates
    final lastDate = isReminderDate 
      ? DateTime.now().add(const Duration(days: 3650))  // 10 years ahead
      : DateTime.now().add(const Duration(days: 1));
    
    final initialDate = isReminderDate
      ? _reminderDate ?? DateTime.now().add(const Duration(days: 180)) // Default 6 months
      : _selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );
    
    if (picked != null) {
      setState(() {
        if (isReminderDate) {
          _reminderDate = picked;
          _reminderDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _selectedDate = picked;
          _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  void _addPart() {
    final partName = _partController.text.trim();
    if (partName.isNotEmpty) {
      setState(() {
        _partsReplaced.add(partName);
        _partController.clear();
      });
    }
  }

  void _removePart(int index) {
    setState(() {
      _partsReplaced.removeAt(index);
    });
  }

  Future<void> _saveServiceRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final title = _titleController.text.trim();
        final cost = double.parse(_costController.text.trim());
        
        int? odometer;
        if (_odometerController.text.trim().isNotEmpty) {
          odometer = int.parse(_odometerController.text.trim());
        }
        
        final serviceCenter = _serviceCenterController.text.trim();
        final description = _descriptionController.text.trim();

        await _serviceService.addServiceRecord(
          vehicleId: _vehicleId,
          title: title,
          date: _selectedDate,
          cost: cost,
          odometer: odometer,
          serviceCenter: serviceCenter.isEmpty ? null : serviceCenter,
          description: description.isEmpty ? null : description,
          partsReplaced: _partsReplaced.isEmpty ? null : _partsReplaced,
          isScheduled: _isScheduled,
          reminderDate: _hasReminder ? _reminderDate : null,
        );

        // Update vehicle mileage if odometer is provided and user wants to update
        if (odometer != null && _updateVehicleMileage) {
          await _vehicleService.updateMileage(_vehicleId, odometer);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service record added')),
          );
          Navigator.pop(context, true);
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
        title: const Text('Add Service Record'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle name display
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vehicle: $_vehicleName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Service title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Service Title *',
                  prefixIcon: Icon(Icons.title),
                  hintText: 'e.g. Oil Change, Brake Service',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Service Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, false),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cost
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Service Cost (Rs.) *',
                  prefixIcon: Icon(Icons.payments),
                  hintText: 'e.g. 5000',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service cost';
                  }
                  try {
                    final cost = double.parse(value);
                    if (cost < 0) {
                      return 'Cost cannot be negative';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Odometer reading
              TextFormField(
                controller: _odometerController,
                decoration: const InputDecoration(
                  labelText: 'Odometer Reading (km)',
                  prefixIcon: Icon(Icons.speed),
                  hintText: 'e.g. 12000',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      int.parse(value);
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              // Update mileage checkbox
              CheckboxListTile(
                title: const Text('Update vehicle mileage'),
                subtitle: const Text(
                  'This will update the current mileage of your vehicle',
                  style: TextStyle(fontSize: 12),
                ),
                value: _updateVehicleMileage,
                onChanged: _odometerController.text.isEmpty 
                  ? null  // Disable if no odometer value
                  : (value) {
                    setState(() {
                      _updateVehicleMileage = value ?? true;
                    });
                  },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: 16),
              
              // Service center
              TextFormField(
                controller: _serviceCenterController,
                decoration: const InputDecoration(
                  labelText: 'Service Center (Optional)',
                  prefixIcon: Icon(Icons.store),
                  hintText: 'e.g. Toyota Service Center',
                ),
              ),
              const SizedBox(height: 16),
              
              // Is scheduled maintenance
              CheckboxListTile(
                title: const Text('Scheduled Maintenance'),
                subtitle: const Text(
                  'Is this a regularly scheduled maintenance?',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isScheduled,
                onChanged: (value) {
                  setState(() {
                    _isScheduled = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primaryColor,
              ),
              
              // Service reminder
              CheckboxListTile(
                title: const Text('Set service reminder'),
                subtitle: const Text(
                  'Remind me for the next service',
                  style: TextStyle(fontSize: 12),
                ),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() {
                    _hasReminder = value ?? false;
                    if (_hasReminder && _reminderDate == null) {
                      // Default to 6 months from now
                      _reminderDate = DateTime.now().add(const Duration(days: 180));
                      _reminderDateController.text = 
                          DateFormat('dd/MM/yyyy').format(_reminderDate!);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primaryColor,
              ),
              
              // Reminder date (if enabled)
              if (_hasReminder)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
                  child: TextFormField(
                    controller: _reminderDateController,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Date *',
                      prefixIcon: Icon(Icons.notification_important),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                    validator: (value) {
                      if (_hasReminder && (value == null || value.isEmpty)) {
                        return 'Please select a reminder date';
                      }
                      return null;
                    },
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Parts replaced
              const Text(
                'Parts Replaced',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _partController,
                      decoration: const InputDecoration(
                        labelText: 'Part name',
                        hintText: 'e.g. Oil Filter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addPart,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Parts list
              if (_partsReplaced.isNotEmpty) ...[
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _partsReplaced.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_partsReplaced[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removePart(index),
                        ),
                        dense: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Description / Notes
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description / Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Additional details about the service',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Add Service Record',
                onPressed: _saveServiceRecord,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}