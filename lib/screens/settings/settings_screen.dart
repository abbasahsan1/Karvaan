import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/glass_container.dart';

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
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return KarvaanScaffoldShell(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  _GlassIconCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16, 120, 16, 120 + bottomInset),
          children: [
            _buildNotificationSection(),
            _buildUnitsSection(),
            _buildAppearanceSection(),
            _buildDataSection(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    final theme = Theme.of(context);
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications_none,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            'Enable Notifications',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            'Receive important updates and reminders',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          activeColor: Colors.white,
          activeTrackColor: AppTheme.primaryColor.withOpacity(0.6),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white24,
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            'Service Reminders',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            'Notify when maintenance is due',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          value: _remindersEnabled,
          onChanged: _notificationsEnabled ? (value) {
            setState(() {
              _remindersEnabled = value;
            });
          } : null,
          activeColor: Colors.white,
          activeTrackColor: AppTheme.primaryColor.withOpacity(0.6),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white24,
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Remind Me Before',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            '7 days',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
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
    final theme = Theme.of(context);
    return _buildSection(
      title: 'Units & Format',
      icon: Icons.straighten,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Distance Unit',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            _distanceUnit,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Distance Unit', _distanceUnits, _distanceUnit, (value) {
              setState(() {
                _distanceUnit = value;
              });
            });
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Volume Unit',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            _volumeUnit,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Volume Unit', _volumeUnits, _volumeUnit, (value) {
              setState(() {
                _volumeUnit = value;
              });
            });
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Currency Symbol',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            _currencySymbol,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Currency Symbol', _currencySymbols, _currencySymbol, (value) {
              setState(() {
                _currencySymbol = value;
              });
            });
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Date Format',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            _dateFormat,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
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
    final theme = Theme.of(context);
    return _buildSection(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Language',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            _language,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSelectionDialog('Language', _languages, _language, (value) {
              setState(() {
                _language = value;
              });
            });
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Theme',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            'Light',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement theme selection
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Text Size',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            'Default',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement text size selection
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    final theme = Theme.of(context);
    return _buildSection(
      title: 'Data & Storage',
      icon: Icons.storage_outlined,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Sync Data',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            'Sync your data across devices',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement sync functionality
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Export Data',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            'Export as CSV or PDF',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement export functionality
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Clear Cache',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            'Free up storage space',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
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
    final theme = Theme.of(context);
    return _buildSection(
      title: 'About & Legal',
      icon: Icons.info_outline,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'About Karvaan',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to about screen
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Privacy Policy',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show privacy policy
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Terms of Service',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show terms of service
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'App Version',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            '1.1.0 (build 2)',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
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
    final theme = Theme.of(context);

    final List<Widget> content = [];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
  content.add(Divider(color: Colors.white.withOpacity(0.16), height: 1, thickness: 1));
      }
      content.add(children[i]);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: ListTileTheme(
          contentPadding: EdgeInsets.zero,
          iconColor: Colors.white70,
          textColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ...content,
            ],
          ),
        ),
      ),
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
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: const Color(0xE6101B2B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                final bool isSelected = option == currentValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<String>(
                    tileColor: Colors.white.withOpacity(isSelected ? 0.12 : 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: Text(
                      option,
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                    value: option,
                    groupValue: currentValue,
                    onChanged: (value) {
                      if (value != null) {
                        onSelect(value);
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    activeColor: AppTheme.accentColorLight,
                    selected: isSelected,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }
}

class _GlassIconCircleButton extends StatelessWidget {
  const _GlassIconCircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(10),
      onTap: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }
}
