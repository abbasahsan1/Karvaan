import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karvaan/models/fuel_entry_model.dart';
import 'package:karvaan/services/fuel_entry_service.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class AddFuelEntryScreen extends StatefulWidget {
  const AddFuelEntryScreen({Key? key}) : super(key: key);

  @override
  _AddFuelEntryScreenState createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends State<AddFuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isFullTank = true;
  bool _isLoading = false;
  bool _updateVehicleMileage = true;

  late String _vehicleId;
  late String _vehicleName;
  final FuelEntryService _fuelService = FuelEntryService.instance;
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
    _dateController.dispose();
    _amountController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveFuelEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final amount = double.parse(_amountController.text.trim());
        final cost = double.parse(_costController.text.trim());
        
        int? odometer;
        if (_odometerController.text.trim().isNotEmpty) {
          odometer = int.parse(_odometerController.text.trim());
        }
        
        final notes = _notesController.text.trim();

        await _fuelService.addFuelEntry(
          vehicleId: _vehicleId,
          date: _selectedDate,
          amount: amount,
          cost: cost,
          odometer: odometer,
          notes: notes.isEmpty ? null : notes,
          isFullTank: _isFullTank,
        );

        // Update vehicle mileage if odometer is provided and user wants to update
        if (odometer != null && _updateVehicleMileage) {
          await _vehicleService.updateMileage(_vehicleId, odometer);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fuel entry added')),
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

  // Calculate price per liter when cost and amount are provided
  String _calculatePricePerLiter() {
    if (_costController.text.isEmpty || _amountController.text.isEmpty) {
      return 'Rs. -';
    }
    
    try {
      final cost = double.parse(_costController.text);
      final amount = double.parse(_amountController.text);
      if (amount <= 0) return 'Rs. -';
      
      final pricePerLiter = cost / amount;
      return 'Rs. ${pricePerLiter.toStringAsFixed(2)}/L';
    } catch (e) {
      return 'Rs. -';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fuel Entry'),
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

              // Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Amount (liters)
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (Liters) *',
                  prefixIcon: Icon(Icons.local_gas_station),
                  hintText: 'e.g. 40.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount of fuel';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return 'Amount must be greater than zero';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              
              // Cost
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Total Cost (Rs.) *',
                  prefixIcon: Icon(Icons.payments),
                  hintText: 'e.g. 5000',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total cost';
                  }
                  try {
                    final cost = double.parse(value);
                    if (cost <= 0) {
                      return 'Cost must be greater than zero';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              
              // Price per liter calculation
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Price per liter: ${_calculatePricePerLiter()}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
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
              
              // Is full tank
              CheckboxListTile(
                title: const Text('Full Tank'),
                subtitle: const Text(
                  'Is this a full tank refill?',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isFullTank,
                onChanged: (value) {
                  setState(() {
                    _isFullTank = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Any additional notes',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Add Fuel Entry',
                onPressed: _saveFuelEntry,
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