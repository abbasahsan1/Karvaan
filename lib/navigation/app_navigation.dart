import 'package:flutter/material.dart';
import 'package:karvaan/screens/home/home_screen.dart';
import 'package:karvaan/screens/vehicles/vehicles_list_screen.dart';
import 'package:karvaan/screens/services/services_list_screen.dart';
import 'package:karvaan/screens/profile/profile_screen.dart';
import 'package:karvaan/theme/app_theme.dart';

class AppNavigation extends StatefulWidget {
  final int initialIndex;

  const AppNavigation({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _AppNavigationState createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  late int _selectedIndex;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VehiclesListScreen(),
    const ServicesListScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'My Vehicles',
    'Services',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent navigating back to splash screen
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            if (_selectedIndex == 0) // Only show settings icon on home screen
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings/main');
                },
              ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Vehicles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
