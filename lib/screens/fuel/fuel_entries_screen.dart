import 'package:flutter/material.dart';
import 'package:karvaan/models/fuel_entry_model.dart';
import 'package:karvaan/services/fuel_entry_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class FuelEntriesScreen extends StatefulWidget {
  final String vehicleId;
  final String vehicleName;

  const FuelEntriesScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
  }) : super(key: key);

  @override
  _FuelEntriesScreenState createState() => _FuelEntriesScreenState();
}

class _FuelEntriesScreenState extends State<FuelEntriesScreen> {
  final FuelEntryService _fuelService = FuelEntryService.instance;
  
  bool _isLoading = true;
  List<FuelEntryModel> _entries = [];
  Map<String, dynamic> _stats = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFuelEntries();
  }

  Future<void> _loadFuelEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _fuelService.getFuelEntriesForVehicle(widget.vehicleId);
      final stats = await _fuelService.getVehicleStatistics(widget.vehicleId);
      
      if (mounted) {
        setState(() {
          _entries = entries;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading fuel entries: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addFuelEntry() async {
    final result = await Navigator.pushNamed(
      context,
      '/fuel/add',
      arguments: {
        'vehicleId': widget.vehicleId,
        'vehicleName': widget.vehicleName,
      },
    );

    if (result == true) {
      _loadFuelEntries();
    }
  }

  Future<void> _confirmDeleteEntry(FuelEntryModel entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fuel Entry'),
        content: const Text(
          'Are you sure you want to delete this fuel entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _fuelService.deleteFuelEntry(entry.id!.toHexString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fuel entry deleted')),
        );
        _loadFuelEntries();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicleName} - Fuel Entries'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _loadFuelEntries,
                  child: Column(
                    children: [
                      // Statistics card
                      if (_stats.isNotEmpty) _buildStatsCard(),
                      
                      // Entries list
                      Expanded(
                        child: _entries.isEmpty
                            ? _buildNoEntriesMessage()
                            : _buildEntriesList(),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFuelEntry,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildStatsCard() {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final numberFormat = NumberFormat('###,###,##0.0#');
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fuel Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Cost',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      Text(
                        currencyFormat.format(_stats['totalCost'] ?? 0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Fuel',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      Text(
                        '${numberFormat.format(_stats['totalAmount'] ?? 0)} L',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avg. Price / L',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      Text(
                        _stats['avgCostPerLiter'] != null
                            ? 'Rs. ${numberFormat.format(_stats['avgCostPerLiter'] ?? 0)}'
                            : '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avg. Consumption',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      Text(
                        _stats['avgConsumption'] != null
                            ? '${numberFormat.format(_stats['avgConsumption'])} L/100km'
                            : '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_stats['distance'] != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Distance',
                          style: TextStyle(color: AppTheme.textSecondaryColor),
                        ),
                        Text(
                          '${_stats['distance']} km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Number of Entries',
                          style: TextStyle(color: AppTheme.textSecondaryColor),
                        ),
                        Text(
                          '${_stats['entriesCount']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList() {
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final numberFormat = NumberFormat('###,###,##0.0#');
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Dismissible(
          key: Key(entry.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            await _confirmDeleteEntry(entry);
            return false;
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_gas_station,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              dateFormat.format(entry.date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${numberFormat.format(entry.amount)} L'),
                    const SizedBox(width: 8),
                    const Text('•'),
                    const SizedBox(width: 8),
                    Text(currencyFormat.format(entry.cost)),
                  ],
                ),
                if (entry.odometer != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Mileage: ${entry.odometer} km',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${numberFormat.format(entry.pricePerLiter)}/L',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.isFullTank ? 'Full tank' : 'Partial fill',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () {
              // Show fuel entry details in a dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(dateFormat.format(entry.date)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dialogItem('Amount:', '${numberFormat.format(entry.amount)} L'),
                      _dialogItem('Cost:', currencyFormat.format(entry.cost)),
                      _dialogItem('Price per liter:', 'Rs. ${numberFormat.format(entry.pricePerLiter)}/L'),
                      if (entry.odometer != null) _dialogItem('Odometer:', '${entry.odometer} km'),
                      _dialogItem('Type:', entry.isFullTank ? 'Full tank' : 'Partial fill'),
                      if (entry.notes != null && entry.notes!.isNotEmpty) 
                        _dialogItem('Notes:', entry.notes!),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CLOSE'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _confirmDeleteEntry(entry);
                      },
                      child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _dialogItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEntriesMessage() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_gas_station_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'No fuel entries yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start tracking your fuel consumption to see statistics and insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Add Fuel Entry',
              onPressed: _addFuelEntry,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
