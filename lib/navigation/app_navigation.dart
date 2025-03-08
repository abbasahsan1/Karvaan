import 'package:flutter/material.dart';
import 'package:karvaan/screens/home/home_screen.dart';
import 'package:karvaan/screens/vehicles/vehicle_detail_screen.dart';
import 'package:karvaan/screens/profile/profile_screen.dart';

class AppNavigation extends StatefulWidget {
  final int initialIndex;
  
  const AppNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _AppNavigationState createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  late int _selectedIndex;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text('Services'))), // Placeholder
    const Scaffold(body: Center(child: Text('Analytics'))), // Placeholder
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karvaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-vehicle');
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Vehicle',
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
