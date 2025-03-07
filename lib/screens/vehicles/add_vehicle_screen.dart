import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';

class AddVehicleScreen extends StatefulWidget {
  final Map<String, dynamic>? existingVehicle; // For editing an existing vehicle, null for new

  const AddVehicleScreen({
    Key? key,
    this.existingVehicle,
  }) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _registrationController = TextEditingController();
  final _colorController = TextEditingController();
  final _engineSizeController = TextEditingController();
  final _odometerController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  String? _selectedFuelType;
  String? _selectedTransmission;
  DateTime? _selectedPurchaseDate;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'];
  final List<String> _transmissionTypes = ['Manual', 'Automatic', 'CVT', 'Semi-Automatic'];

  @override
  void initState() {
    super.initState();
    // If editing, populate the form with existing vehicle data
    if (widget.existingVehicle != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final vehicle = widget.existingVehicle!;
    _makeController.text = vehicle['make'] ?? '';
    _modelController.text = vehicle['model'] ?? '';
    _yearController.text = vehicle['year'] ?? '';
    _registrationController.text = vehicle['registration'] ?? '';
    _colorController.text = vehicle['color'] ?? '';
    _engineSizeController.text = vehicle['engineSize'] ?? '';
    _odometerController.text = vehicle['odometer']?.toString().replaceAll(' km', '') ?? '';
    _selectedFuelType = vehicle['fuelType'];
    _selectedTransmission = vehicle['transmission'];
    _purchasePriceController.text = vehicle['purchasePrice']?.toString().replaceAll('Rs. ', '').replaceAll(',', '') ?? '';
    
    // Handle purchase date
    if (vehicle['purchaseDate'] != null) {
      final dateParts = vehicle['purchaseDate'].toString().split(' ');
      if (dateParts.length == 3) {
        final month = _getMonthNumber(dateParts[0]);
        final day = int.parse(dateParts[1].replaceAll(',', ''));
        final year = int.parse(dateParts[2]);
        _selectedPurchaseDate = DateTime(year, month, day);
        _purchaseDateController.text = '${dateParts[0]} ${dateParts[1]} ${dateParts[2]}';
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
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _registrationController.dispose();
    _colorController.dispose();
    _engineSizeController.dispose();
    _odometerController.dispose();
    _purchaseDateController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedPurchaseDate) {
      setState(() {
        _selectedPurchaseDate = picked;
        _purchaseDateController.text = '${_getMonthName(picked.month)} ${picked.day}, ${picked.year}';
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

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      // Create vehicle object
      final vehicle = {
        'make': _makeController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'registration': _registrationController.text,
        'color': _colorController.text,
        'fuelType': _selectedFuelType,
        'transmission': _selectedTransmission,
        'engineSize': _engineSizeController.text,
        'odometer': '${_odometerController.text} km',
        'purchaseDate': _purchaseDateController.text,
        'purchasePrice': 'Rs. ${_purchasePriceController.text}',
      };
      
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle saved successfully'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      
      // Return to previous screen
      Navigator.pop(context, vehicle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingVehicle != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
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
              _buildTechnicalInfoSection(),
              const SizedBox(height: 24),
              _buildPurchaseInfoSection(),
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Update Vehicle' : 'Add Vehicle',
                onPressed: _saveVehicle,
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
            TextFormField(
              controller: _makeController,
              decoration: const InputDecoration(
                labelText: 'Make',
                hintText: 'e.g. Toyota, Honda',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the vehicle make';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'e.g. Corolla, Civic',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the vehicle model';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g. 2020',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the vehicle year';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid year';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registrationController,
              decoration: const InputDecoration(
                labelText: 'Registration Number',
                hintText: 'e.g. ABC-123',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the registration number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                hintText: 'e.g. White, Black, Silver',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalInfoSection() {
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
              'Technical Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Fuel Type',
              ),
              value: _selectedFuelType,
              items: _fuelTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFuelType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a fuel type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Transmission',
              ),
              value: _selectedTransmission,
              items: _transmissionTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTransmission = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a transmission type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _engineSizeController,
              decoration: const InputDecoration(
                labelText: 'Engine Size (cc)',
                hintText: 'e.g. 1800',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(
                labelText: 'Current Odometer (km)',
                hintText: 'e.g. 15000',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the current odometer reading';
                }
                if (int.tryParse(value) == null) {
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

  Widget _buildPurchaseInfoSection() {
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
              'Purchase Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purchaseDateController,
              decoration: const InputDecoration(
                labelText: 'Purchase Date',
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectPurchaseDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purchasePriceController,
              decoration: const InputDecoration(
                labelText: 'Purchase Price (Rs.)',
                hintText: 'e.g. 2500000',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}