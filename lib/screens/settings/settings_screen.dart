import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  // Add const to constructor
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock settings data
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
  String _distanceUnit = 'Kilometers (km)';
  String _volumeUnit = 'Liters (L)';
  String _currencySymbol = 'Rs.';
  String _dateFormat = 'MMM DD, YYYY';
  String _language = 'English';

  final List<String> _distanceUnits = ['Kilometers (km)', 'Miles (mi)'];
  final List<String> _volumeUnits = ['Liters (L)', 'Gallons (gal)'];
  final List<String> _currencySymbols = ['Rs.', '\$', '€', '£'];
  final List<String> _dateFormats = ['MMM DD, YYYY', 'DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'];
  final List<String> _languages = ['English', 'Urdu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNotificationSection(),
            const Divider(height: 1),
            _buildUnitsSection(),
            const Divider(height: 1),
            _buildAppearanceSection(),
            const Divider(height: 1),
            _buildDataSection(),
            const Divider(height: 1),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications_none,
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive important updates and reminders'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        SwitchListTile(
          title: const Text('Service Reminders'),
          subtitle: const Text('Notify when maintenance is due'),
          value: _remindersEnabled,
          onChanged: _notificationsEnabled ? (value) {
            setState(() {
              _remindersEnabled = value;
            });
          } : null,
          activeColor: AppTheme.primaryColor,
        ),
        ListTile(
          title: const Text('Remind Me Before'),
          subtitle: const Text('7 days'),
          trailing: const Icon(Icons.chevron_right),
          enabled: _notificationsEnabled && _remindersEnabled,
          onTap: _notificationsEnabled && _remindersEnabled ? () {
            // Navigate to reminder settings
          } : null,
        ),
      ],
    );
  }

  Widget _buildUnitsSection() {
    return _buildSection(
      title: 'Units & Format',
      icon: Icons.straighten,
      children: [
        ListTile(
          title: const Text('Distance Unit'),
          subtitle: Text(_distanceUnit),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Distance Unit', _distanceUnits, _distanceUnit, (value) {
              setState(() {
                _distanceUnit = value;
              });
            });
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Volume Unit'),
          subtitle: Text(_volumeUnit),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Volume Unit', _volumeUnits, _volumeUnit, (value) {
              setState(() {
                _volumeUnit = value;
              });
            });
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Currency Symbol'),
          subtitle: Text(_currencySymbol),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Currency Symbol', _currencySymbols, _currencySymbol, (value) {
              setState(() {
                _currencySymbol = value;
              });
            });
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Date Format'),
          subtitle: Text(_dateFormat),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Date Format', _dateFormats, _dateFormat, (value) {
              setState(() {
                _dateFormat = value;
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      children: [
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_language),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Language', _languages, _language, (value) {
              setState(() {
                _language = value;
              });
            });
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Theme'),
          subtitle: const Text('Light'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement theme selection
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Text Size'),
          subtitle: const Text('Default'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement text size selection
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: 'Data & Storage',
      icon: Icons.storage_outlined,
      children: [
        ListTile(
          title: const Text('Sync Data'),
          subtitle: const Text('Sync your data across devices'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement sync functionality
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Export Data'),
          subtitle: const Text('Export as CSV or PDF'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement export functionality
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Clear Cache'),
          subtitle: const Text('Free up storage space'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showClearCacheConfirmation();
          },
        ),
      ],
    );
  }

  void _showClearCacheConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Your personal information and records will not be affected.'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('CLEAR'),
            onPressed: () {
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About & Legal',
      icon: Icons.info_outline,
      children: [
        ListTile(
          title: const Text('About Karvaan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to about screen
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show privacy policy
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show terms of service
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: const Text('App Version'),
          subtitle: const Text('1.1.0 (build 2)'),
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  void _showSelectionDialog(
    String title,
    List<String> options,
    String currentValue,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: currentValue,
                onChanged: (value) {
                  if (value != null) {
                    onSelect(value);
                    Navigator.of(context).pop();
                  }
                },
                activeColor: AppTheme.primaryColor,
                selected: option == currentValue,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
