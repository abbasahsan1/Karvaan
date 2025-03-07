import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/screens/services/add_service_record_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  // Mock service data - in real app, fetch from database
  late Map<String, dynamic> _serviceData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // This would be fetched from a database in a real app
    setState(() {
      _serviceData = {
        'id': widget.serviceId,
        'title': 'Oil Change',
        'description': 'Regular engine oil change with filter replacement',
        'vehicle': 'Toyota Corolla',
        'vehicleRegistration': 'ABC-123',
        'serviceType': 'Oil Change',
        'serviceProvider': 'AutoCare Workshop',
        'serviceDate': 'April 10, 2023',
        'odometer': '12,500 km',
        'cost': 'Rs. 2,500',
        'parts': [
          {'name': 'Engine Oil (4L)', 'cost': 'Rs. 1,800'},
          {'name': 'Oil Filter', 'cost': 'Rs. 400'},
          {'name': 'Labor', 'cost': 'Rs. 300'},
        ],
        'notes': 'Used synthetic oil for better performance. Recommended next service after 5,000 km.',
        'isRecurring': true,
        'recurrenceInterval': 'Every 5,000 km or 3 months',
        'nextServiceDate': 'July 10, 2023',
        'status': 'Completed',
        'attachments': 2,
        'invoiceAvailable': true,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddServiceRecordScreen(
                    existingService: _serviceData,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              } else if (value == 'share') {
                // TODO: Implement share functionality
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceHeader(),
                  const SizedBox(height: 24),
                  _buildServiceDetails(),
                  const SizedBox(height: 24),
                  if (_serviceData['parts'] != null) ...[
                    _buildPartsList(),
                    const SizedBox(height: 24),
                  ],
                  _buildNotesSection(),
                  const SizedBox(height: 24),
                  _buildAttachmentsSection(),
                  if (_serviceData['isRecurring'] == true) ...[
                    const SizedBox(height: 24),
                    _buildRecurrenceSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildServiceHeader() {
    IconData statusIcon;
    Color statusColor;

    switch (_serviceData['status']) {
      case 'Pending':
        statusIcon = Icons.schedule;
        statusColor = Colors.orange;
        break;
      case 'In Progress':
        statusIcon = Icons.autorenew;
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      default:
        statusIcon = Icons.info;
        statusColor = AppTheme.textSecondaryColor;
    }

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
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _serviceData['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _serviceData['title'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _serviceData['description'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_serviceData['vehicle']} (${_serviceData['vehicleRegistration']})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails() {
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
            _buildDetailRow('Type', _serviceData['serviceType'] ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Provider', _serviceData['serviceProvider'] ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Date', _serviceData['serviceDate'] ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Odometer', _serviceData['odometer'] ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Cost', _serviceData['cost'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsList() {
    final parts = _serviceData['parts'] as List;
    
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
              'Parts and Costs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Cost',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: parts.length,
              itemBuilder: (context, index) {
                final part = parts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(part['name']),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          part['cost'],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _serviceData['cost'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    if (_serviceData['notes'] == null || _serviceData['notes'].toString().isEmpty) {
      return const SizedBox.shrink();
    }
    
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
            const SizedBox(height: 8),
            Text(
              _serviceData['notes'],
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    final hasAttachments = ((_serviceData['attachments'] as int?) ?? 0) > 0;
    final hasInvoice = _serviceData['invoiceAvailable'] == true;
    
    if (!hasAttachments && !hasInvoice) {
      return const SizedBox.shrink();
    }
    
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
              'Attachments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (hasInvoice)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: const Text('Invoice'),
                subtitle: const Text('Service invoice document'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: View invoice
                },
              ),
            if (hasAttachments)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                title: Text('Photos (${_serviceData['attachments']})'),
                subtitle: const Text('Service related photos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: View photos
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
              'Recurring Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Interval', _serviceData['recurrenceInterval'] ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Next Due', _serviceData['nextServiceDate'] ?? 'N/A'),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Edit Recurrence',
              onPressed: () {
                // TODO: Edit recurrence settings
              },
              isOutlined: true,
              icon: Icons.edit,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Record'),
        content: const Text('Are you sure you want to delete this service record? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
              // TODO: Implement actual delete functionality
            },
          ),
        ],
      ),
    );
  }
}