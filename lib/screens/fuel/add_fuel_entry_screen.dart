import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';

class AddFuelEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? existingEntry; // For editing an existing entry, null for new
  final String? vehicleId; // If coming from a specific vehicle, this will be set

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
  
  // Form controllers
  final _dateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _fuelAmountController = TextEditingController();
  final _fuelCostController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVehicle;
  String? _selectedFuelType;
  DateTime? _selectedDate;
  bool _isFillUp = true;

  // Mock data for dropdowns
  final List<String> _vehicles = ['Toyota Corolla', 'Honda City', 'Suzuki Alto'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric'];

  @override
  void initState() {
    super.initState();
    // If vehicle ID is provided, set the selected vehicle
    if (widget.vehicleId != null) {
      // In a real app, you would look up the vehicle name from the ID
      _selectedVehicle = _vehicles.first;
    }

    // Set default date to today
    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate!);
  }

  String _formatDate(DateTime date) {
    return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _dateController.dispose();
    _odometerController.dispose();
    _fuelAmountController.dispose();
    _fuelCostController.dispose();
    _totalCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateForm() {
    if (widget.existingEntry == null) return;

    final entry = widget.existingEntry!;
    _selectedVehicle = entry['vehicle'];
    _selectedFuelType = entry['fuelType'];
    _isFillUp = entry['isFillUp'] ?? true;
    
    _odometerController.text = entry['odometer']?.toString().replaceAll(' km', '') ?? '';
    _fuelAmountController.text = entry['fuelAmount']?.toString().replaceAll(' L', '') ?? '';
    _fuelCostController.text = entry['fuelCost']?.toString().replaceAll('Rs. ', '').replaceAll('/L', '') ?? '';
    _totalCostController.text = entry['totalCost']?.toString().replaceAll('Rs. ', '') ?? '';
    _notesController.text = entry['notes'] ?? '';
    
    // Handle date
    if (entry['date'] != null) {
      final dateParts = entry['date'].toString().split(' ');
      if (dateParts.length >= 3) {
        final month = _getMonthNumber(dateParts[0]);
        final day = int.parse(dateParts[1].replaceAll(',', ''));
        final year = int.parse(dateParts[2]);
        _selectedDate = DateTime(year, month, day);
        _dateController.text = entry['date'];
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _calculateTotalCost() {
    if (_fuelAmountController.text.isNotEmpty && _fuelCostController.text.isNotEmpty) {
      try {
        final amount = double.parse(_fuelAmountController.text);
        final costPerLiter = double.parse(_fuelCostController.text);
        final total = amount * costPerLiter;
        _totalCostController.text = total.toStringAsFixed(2);
      } catch (e) {
        // Error in calculation, leave the field as is
      }
    }
  }

  void _saveFuelEntry() {
    if (_formKey.currentState!.validate()) {
      // Create fuel entry object
      final fuelEntry = {
        'vehicle': _selectedVehicle,
        'date': _dateController.text,
        'fuelType': _selectedFuelType,
        'odometer': '${_odometerController.text} km',
        'fuelAmount': '${_fuelAmountController.text} L',
        'fuelCost': 'Rs. ${_fuelCostController.text}/L',
        'totalCost': 'Rs. ${_totalCostController.text}',
        'isFillUp': _isFillUp,
        'notes': _notesController.text,
      };
      
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fuel entry saved successfully'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      
      // Return to previous screen
      Navigator.pop(context, fuelEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Fuel Entry' : 'Add Fuel Entry'),
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
              _buildFuelDetailsSection(),
              const SizedBox(height: 24),
              _buildCostSection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Update Fuel Entry' : 'Save Fuel Entry',
                onPressed: _saveFuelEntry,
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
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date',
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
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
          ],
        ),
      ),
    );
  }

  Widget _buildFuelDetailsSection() {
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
              'Fuel Details',
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
            TextFormField(
              controller: _fuelAmountController,
              decoration: const InputDecoration(
                labelText: 'Fuel Amount (L)',
                hintText: 'e.g. 35',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculateTotalCost(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the amount of fuel';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _isFillUp,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _isFillUp = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Complete Fill Up'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection() {
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
              'Cost Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fuelCostController,
              decoration: const InputDecoration(
                labelText: 'Fuel Cost (Rs. per liter)',
                hintText: 'e.g. 200',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculateTotalCost(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the cost per liter';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalCostController,
              decoration: const InputDecoration(
                labelText: 'Total Cost (Rs.)',
                hintText: 'e.g. 7000',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the total cost';
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
                hintText: 'Any additional information about this fuel entry',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}