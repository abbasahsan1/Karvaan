import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> with SingleTickerProviderStateMixin {
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
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Performance'),
            Tab(text: 'Fuel'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesTab(),
          _buildPerformanceTab(),
          _buildFuelTab(),
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 24),
          _buildExpenseSummaryCard(),
          const SizedBox(height: 24),
          _buildExpenseChart(),
          const SizedBox(height: 24),
          _buildExpenseBreakdownSection(),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 24),
          _buildPerformanceSummaryCards(),
          const SizedBox(height: 24),
          _buildPerformanceChart(),
          const SizedBox(height: 24),
          _buildMaintenanceImpactSection(),
        ],
      ),
    );
  }

  Widget _buildFuelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 24),
          _buildFuelSummaryCards(),
          const SizedBox(height: 24),
          _buildFuelConsumptionChart(),
          const SizedBox(height: 24),
          _buildFuelEfficiencyTipsSection(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: 'Last 3 Months',
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: <String>[
              'Last Month',
              'Last 3 Months',
              'Last 6 Months',
              'Last Year',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // TODO: Change time range
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseSummaryCard() {
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
              'Total Expenses',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rs. 35,750',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildExpenseMetric('Fuel', 'Rs. 18,500'),
                _buildExpenseMetric('Maintenance', 'Rs. 12,250'),
                _buildExpenseMetric('Other', 'Rs. 5,000'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseChart() {
    // TODO: Replace with actual chart implementation
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Expense Chart Placeholder'),
      ),
    );
  }

  Widget _buildExpenseBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildExpenseBreakdownItem('Fuel', 'Rs. 18,500', 0.52),
        const SizedBox(height: 12),
        _buildExpenseBreakdownItem('Maintenance', 'Rs. 12,250', 0.34),
        const SizedBox(height: 12),
        _buildExpenseBreakdownItem('Insurance', 'Rs. 3,000', 0.08),
        const SizedBox(height: 12),
        _buildExpenseBreakdownItem('Cleaning', 'Rs. 2,000', 0.06),
      ],
    );
  }

  Widget _buildExpenseBreakdownItem(String category, String amount, double percentage) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[200],
                  color: _getColorForCategory(category),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Fuel':
        return Colors.green;
      case 'Maintenance':
        return Colors.blue;
      case 'Insurance':
        return Colors.purple;
      case 'Cleaning':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildPerformanceSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Avg. Speed',
            '45 km/h',
            Icons.speed,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Total Distance',
            '1,240 km',
            Icons.map,
            AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    // TODO: Replace with actual chart implementation
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Performance Chart Placeholder'),
      ),
    );
  }

  Widget _buildMaintenanceImpactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maintenance Impact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.build,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Last Oil Change Impact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fuel efficiency improved by 8% after your last oil change on June 10.',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildImpactMetric('Before', '12.5 km/l', Colors.red),
                    const Icon(Icons.arrow_forward),
                    _buildImpactMetric('After', '13.5 km/l', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactMetric(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFuelSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Avg. Consumption',
            '13.5 km/l',
            Icons.local_gas_station,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Fuel Cost',
            'Rs. 18,500',
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildFuelConsumptionChart() {
    // TODO: Replace with actual chart implementation
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Fuel Consumption Chart Placeholder'),
      ),
    );
  }

  Widget _buildFuelEfficiencyTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fuel Efficiency Tips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'Maintain Steady Speed',
          'Avoid rapid acceleration and braking to improve fuel efficiency by up to 20%.',
          Icons.speed,
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          'Check Tire Pressure',
          'Properly inflated tires can improve fuel efficiency by up to 3%.',
          Icons.tire_repair,
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
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
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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
      ),
    );
  }
}
