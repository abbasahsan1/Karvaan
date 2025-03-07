import 'package:flutter/material.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+92 300 1234567',
    'profileImage': null, // No image for now
    'createdAt': 'January 2023',
    'vehicles': 3,
    'services': 12,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileDetails(),
            _buildAccountActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: _userData['profileImage'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      _userData['profileImage'],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    _getUserInitials(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userData['email'],
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUserStat('Vehicles', _userData['vehicles'].toString()),
              Container(
                height: 24,
                width: 1,
                color: AppTheme.dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildUserStat('Services', _userData['services'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.phone,
            'Phone Number',
            _userData['phone'],
          ),
          const Divider(),
          _buildInfoItem(
            Icons.calendar_today,
            'Member Since',
            _userData['createdAt'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.textSecondaryColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Column(
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            Icons.lock_outline,
            'Change Password',
            () {
              // Navigate to change password screen
            },
          ),
          const Divider(),
          _buildActionItem(
            Icons.notifications_none,
            'Notifications',
            () {
              // Navigate to notifications settings
            },
          ),
          const Divider(),
          _buildActionItem(
            Icons.help_outline,
            'Help & Support',
            () {
              // Navigate to help screen
            },
          ),
          const Divider(),
          _buildActionItem(
            Icons.info_outline,
            'About',
            () {
              // Navigate to about screen
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Log Out',
            onPressed: _confirmLogout,
            isOutlined: true,
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.textPrimaryColor,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('LOG OUT'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getUserInitials() {
    final nameParts = _userData['name'].split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return nameParts[0][0];
  }
}
