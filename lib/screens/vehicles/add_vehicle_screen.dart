import 'package:flutter/material.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleModel? existingVehicle;

  const AddVehicleScreen({Key? key, this.existingVehicle}) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
  bool _isLoading = false;

  final VehicleService _vehicleService = VehicleService.instance;

  @override
  void initState() {
    super.initState();
    if (widget.existingVehicle != null) {
      _nameController.text = widget.existingVehicle!.name;
      _registrationController.text = widget.existingVehicle!.registrationNumber;
      _makeController.text = widget.existingVehicle!.make ?? '';
      _modelController.text = widget.existingVehicle!.model ?? '';
      _yearController.text = widget.existingVehicle!.year?.toString() ?? '';
      _colorController.text = widget.existingVehicle!.color ?? '';
      _mileageController.text = widget.existingVehicle!.mileage?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final int? year = _yearController.text.isNotEmpty 
            ? int.tryParse(_yearController.text) 
            : null;
        final int? mileage = _mileageController.text.isNotEmpty 
            ? int.tryParse(_mileageController.text) 
            : null;

        if (widget.existingVehicle == null) {
          // Add new vehicle
          await _vehicleService.addVehicle(
            name: _nameController.text,
            registrationNumber: _registrationController.text,
            make: _makeController.text.isNotEmpty ? _makeController.text : null,
            model: _modelController.text.isNotEmpty ? _modelController.text : null,
            year: year,
            color: _colorController.text.isNotEmpty ? _colorController.text : null,
            mileage: mileage,
          );
        } else {
          // Update existing vehicle
          final updatedVehicle = widget.existingVehicle!.copyWith(
            name: _nameController.text,
            registrationNumber: _registrationController.text,
            make: _makeController.text.isNotEmpty ? _makeController.text : null,
            model: _modelController.text.isNotEmpty ? _modelController.text : null,
            year: year,
            color: _colorController.text.isNotEmpty ? _colorController.text : null,
            mileage: mileage,
          );
          
          await _vehicleService.updateVehicle(updatedVehicle);
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
        title: Text(widget.existingVehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter registration number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveVehicle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.existingVehicle == null ? 'Add Vehicle' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}