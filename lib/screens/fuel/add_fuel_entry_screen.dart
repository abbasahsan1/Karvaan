import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karvaan/models/fuel_entry_model.dart';
import 'package:karvaan/services/fuel_entry_service.dart';

class AddFuelEntryScreen extends StatefulWidget {
  final FuelEntryModel? existingEntry;
  final String? vehicleId;

  const AddFuelEntryScreen({
    Key? key,
    this.existingEntry,
    this.vehicleId,
  }) : super(key: key);

  @override
  State<AddFuelEntryScreen> createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends State<AddFuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedFuelType = 'Petrol';
  bool _fullTank = true;
  bool _isLoading = false;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'CNG', 'LPG', 'Other'];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final FuelEntryService _fuelEntryService = FuelEntryService.instance;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _quantityController.text = widget.existingEntry!.quantity.toString();
      _costController.text = widget.existingEntry!.cost.toString();
      _mileageController.text = widget.existingEntry!.mileage?.toString() ?? '';
      _notesController.text = widget.existingEntry!.notes ?? '';
      _selectedDate = widget.existingEntry!.date;
      _selectedFuelType = widget.existingEntry!.fuelType ?? 'Petrol';
      _fullTank = widget.existingEntry!.fullTank;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
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

  Future<void> _saveFuelEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final double quantity = double.parse(_quantityController.text);
        final double cost = double.parse(_costController.text);
        final int? mileage = _mileageController.text.isNotEmpty 
            ? int.tryParse(_mileageController.text) 
            : null;

        final String vehicleId = widget.vehicleId ?? 
            (widget.existingEntry != null 
                ? widget.existingEntry!.vehicleId.toHexString() 
                : throw Exception('Vehicle ID is required'));

        if (widget.existingEntry == null) {
          // Add new fuel entry
          await _fuelEntryService.addFuelEntry(
            vehicleId: vehicleId,
            date: _selectedDate,
            quantity: quantity,
            cost: cost,
            mileage: mileage,
            fuelType: _selectedFuelType,
            fullTank: _fullTank,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          );
        } else {
          // Update existing fuel entry
          final updatedEntry = widget.existingEntry!.copyWith(
            date: _selectedDate,
            quantity: quantity,
            cost: cost,
            mileage: mileage,
            fuelType: _selectedFuelType,
            fullTank: _fullTank,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          );
          
          await _fuelEntryService.updateFuelEntry(updatedEntry);
        }

        // Pop back to previous screen
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
        title: Text(widget.existingEntry == null ? 'Add Fuel Entry' : 'Edit Fuel Entry'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Picker Field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_dateFormat.format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Quantity Field
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (liters) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cost Field
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Total Cost *',
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
              
              // Fuel Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedFuelType,
                items: _fuelTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFuelType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Full Tank Checkbox
              CheckboxListTile(
                title: const Text('Full Tank'),
                value: _fullTank,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      _fullTank = value;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveFuelEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.existingEntry == null ? 'Add Entry' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}