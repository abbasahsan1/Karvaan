import 'package:flutter/material.dart';
import 'package:karvaan/screens/RiderHistoryPage.dart';
import 'package:karvaan/screens/ResetPasswordPage.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildProfileOptions(context),
    );
  }

  Widget buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        ProfileOption(
          title: "Rider History",
          icon: Icons.history,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RiderHistoryPage()),
            );
          },
        ),
        // Add Reset Password option
        ProfileOption(
          title: "Reset Password",
          icon: Icons.password,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResetPasswordPage()),
            );
          },
        ),
      ],
    );
  }
}

class ProfileOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  ProfileOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}