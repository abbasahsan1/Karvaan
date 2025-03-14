import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karvaan/models/vehicle_model.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
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
  VehicleModel? _existingVehicle;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args != null && args.containsKey('existingVehicle')) {
        setState(() {
          _existingVehicle = args['existingVehicle'] as VehicleModel;
          _nameController.text = _existingVehicle!.name;
          _registrationController.text = _existingVehicle!.registrationNumber;
          _makeController.text = _existingVehicle!.make ?? '';
          _modelController.text = _existingVehicle!.model ?? '';
          _yearController.text = _existingVehicle!.year?.toString() ?? '';
          _colorController.text = _existingVehicle!.color ?? '';
          _mileageController.text = _existingVehicle!.mileage?.toString() ?? '';
        });
      }
    });
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
        final name = _nameController.text.trim();
        final registrationNumber = _registrationController.text.trim();
        final make = _makeController.text.trim();
        final model = _modelController.text.trim();
        final yearText = _yearController.text.trim();
        final color = _colorController.text.trim();
        final mileageText = _mileageController.text.trim();

        final year = yearText.isNotEmpty ? int.parse(yearText) : null;
        final mileage = mileageText.isNotEmpty ? int.parse(mileageText) : null;

        if (_existingVehicle != null) {
          // Update existing vehicle
          final updatedVehicle = _existingVehicle!.copyWith(
            name: name,
            registrationNumber: registrationNumber,
            make: make.isNotEmpty ? make : null,
            model: model.isNotEmpty ? model : null,
            year: year,
            color: color.isNotEmpty ? color : null,
            mileage: mileage,
          );

          await _vehicleService.updateVehicle(updatedVehicle);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle updated')),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Add new vehicle
          await _vehicleService.addVehicle(
            name: name,
            registrationNumber: registrationNumber,
            make: make.isNotEmpty ? make : null,
            model: model.isNotEmpty ? model : null,
            year: year,
            color: color.isNotEmpty ? color : null,
            mileage: mileage,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle added')),
            );
            Navigator.pop(context, true);
          }
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
        title: Text(_existingVehicle != null ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Vehicle name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Name *',
                  hintText: 'e.g. My Toyota',
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your vehicle';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Registration number
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number *',
                  hintText: 'e.g. ABC-123',
                  prefixIcon: Icon(Icons.app_registration),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the registration number';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              
              // Make
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make (Optional)',
                  hintText: 'e.g. Toyota',
                  prefixIcon: Icon(Icons.business),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model (Optional)',
                  hintText: 'e.g. Corolla',
                  prefixIcon: Icon(Icons.model_training),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Year
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year (Optional)',
                  hintText: 'e.g. 2020',
                  prefixIcon: Icon(Icons.date_range),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      final year = int.parse(value);
                      if (year < 1900 || year > DateTime.now().year + 1) {
                        return 'Please enter a valid year';
                      }
                    } catch (e) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (Optional)',
                  hintText: 'e.g. Red',
                  prefixIcon: Icon(Icons.color_lens),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Mileage
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Current Mileage (km) (Optional)',
                  hintText: 'e.g. 15000',
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      int.parse(value);
                    } catch (e) {
                      return 'Please enter a valid mileage';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: _existingVehicle != null ? 'Update Vehicle' : 'Add Vehicle',
                onPressed: _saveVehicle,
                isLoading: _isLoading,
                icon: _existingVehicle != null ? Icons.update : Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}