import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/screens/services/add_service_record_screen.dart';
import 'package:karvaan/screens/services/service_detail_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
            Tab(text: 'Reminders'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(),
          _buildHistoryTab(),
          _buildRemindersTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceRecordScreen()),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingTab() {
    // Sample upcoming services
    final upcomingServices = [
      {
        'id': '1',
        'title': 'Oil Change',
        'vehicle': 'Toyota Corolla',
        'date': 'June 15, 2023',
        'status': 'Due in 2 days',
        'urgent': true,
        'icon': Icons.oil_barrel,
        'iconColor': Colors.amber,
      },
      {
        'id': '2',
        'title': 'Tire Rotation',
        'vehicle': 'Honda City',
        'date': 'June 20, 2023',
        'status': 'Due in 1 week',
        'urgent': false,
        'icon': Icons.tire_repair,
        'iconColor': Colors.blue,
      },
      {
        'id': '3',
        'title': 'Air Filter Replacement',
        'vehicle': 'Toyota Corolla',
        'date': 'July 5, 2023',
        'status': 'Due in 3 weeks',
        'urgent': false,
        'icon': Icons.air,
        'iconColor': Colors.purple,
      },
    ];

    if (upcomingServices.isEmpty) {
      return _buildEmptyState(
        'No upcoming services',
        'You have no scheduled maintenance coming up.',
        Icons.build_circle_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingServices.length,
      itemBuilder: (context, index) {
        final service = upcomingServices[index];
        return _buildServiceCard(
          id: service['id'].toString(),
          title: service['title'].toString(),
          vehicle: service['vehicle'].toString(),
          date: service['date'].toString(),
          status: service['status'].toString(),
          urgent: service['urgent'] as bool,
          icon: service['icon'] as IconData,
          iconColor: service['iconColor'] as Color,
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    // Sample service history
    final serviceHistory = [
      {
        'id': '4',
        'title': 'Oil Change',
        'vehicle': 'Toyota Corolla',
        'date': 'April 10, 2023',
        'mileage': '12,500 km',
        'cost': 'Rs. 2,500',
        'icon': Icons.oil_barrel,
        'iconColor': Colors.amber,
      },
      {
        'id': '5',
        'title': 'Brake Pad Replacement',
        'vehicle': 'Honda City',
        'date': 'March 22, 2023',
        'mileage': '8,000 km',
        'cost': 'Rs. 5,200',
        'icon': Icons.build, // Fixed: Changed from Icons.brake_alert to Icons.build
        'iconColor': Colors.red,
      },
      {
        'id': '6',
        'title': 'Annual Inspection',
        'vehicle': 'Toyota Corolla',
        'date': 'February 15, 2023',
        'mileage': '10,000 km',
        'cost': 'Rs. 3,500',
        'icon': Icons.checklist,
        'iconColor': Colors.green,
      },
    ];

    if (serviceHistory.isEmpty) {
      return _buildEmptyState(
        'No service history',
        'You haven\'t recorded any services yet.',
        Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: serviceHistory.length,
      itemBuilder: (context, index) {
        final service = serviceHistory[index];
        return _buildHistoryCard(
          id: service['id'].toString(),
          title: service['title'].toString(),
          vehicle: service['vehicle'].toString(),
          date: service['date'].toString(),
          mileage: service['mileage'].toString(),
          cost: service['cost'].toString(),
          icon: service['icon'] as IconData,
          iconColor: service['iconColor'] as Color,
        );
      },
    );
  }

  Widget _buildRemindersTab() {
    // Sample reminders
    final reminders = [
      {
        'id': '7',
        'title': 'Oil Change',
        'vehicle': 'Toyota Corolla',
        'interval': 'Every 5,000 km or 3 months',
        'next': 'Due in 2 weeks',
        'icon': Icons.oil_barrel,
        'iconColor': Colors.amber,
      },
      {
        'id': '8',
        'title': 'Tire Rotation',
        'vehicle': 'Honda City',
        'interval': 'Every 10,000 km or 6 months',
        'next': 'Due in 1 month',
        'icon': Icons.tire_repair,
        'iconColor': Colors.blue,
      },
      {
        'id': '9',
        'title': 'Registration Renewal',
        'vehicle': 'Toyota Corolla',
        'interval': 'Yearly',
        'next': 'Due in 3 months',
        'icon': Icons.how_to_reg,
        'iconColor': Colors.green,
      },
    ];

    if (reminders.isEmpty) {
      return _buildEmptyState(
        'No reminders set',
        'You haven\'t set up any service reminders yet.',
        Icons.notifications_none,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _buildReminderCard(
          id: reminder['id'].toString(),
          title: reminder['title'].toString(),
          vehicle: reminder['vehicle'].toString(),
          interval: reminder['interval'].toString(),
          next: reminder['next'].toString(),
          icon: reminder['icon'] as IconData,
          iconColor: reminder['iconColor'] as Color,
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String id,
    required String title,
    required String vehicle,
    required String date,
    required String status,
    required bool urgent,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(serviceId: id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scheduled Date',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: urgent ? AppTheme.accentRedColor : AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Reschedule',
                    onPressed: () {
                      // TODO: Implement reschedule
                    },
                    isOutlined: true,
                    isFullWidth: false,
                    height: 36,
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: 'Mark Complete',
                    onPressed: () {
                      // TODO: Implement mark as complete
                    },
                    isFullWidth: false,
                    height: 36,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String id,
    required String title,
    required String vehicle,
    required String date,
    required String mileage,
    required String cost,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(serviceId: id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHistoryDetail('Date', date),
                  _buildHistoryDetail('Mileage', mileage),
                  _buildHistoryDetail('Cost', cost, alignRight: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryDetail(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard({
    required String id,
    required String title,
    required String vehicle,
    required String interval,
    required String next,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle,
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // TODO: Edit reminder
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interval',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      interval,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Next',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      next,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add Service',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddServiceRecordScreen()),
                );
              },
              isFullWidth: false,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}
