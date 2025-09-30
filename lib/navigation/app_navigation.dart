import 'package:flutter/material.dart';
import 'package:karvaan/screens/home/home_screen.dart';
import 'package:karvaan/screens/vehicles/vehicles_list_screen.dart';
import 'package:karvaan/screens/services/services_list_screen.dart';
import 'package:karvaan/screens/profile/profile_screen.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/glass_container.dart';

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
      child: KarvaanScaffoldShell(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: _GlassAppBar(
            title: _titles[_selectedIndex],
            trailing: _selectedIndex == 0
                ? IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    color: Colors.white,
                    onPressed: () => Navigator.pushNamed(context, '/settings/main'),
                  )
                : null,
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: _GlassAppBar.height + 12),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: 28,
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.directions_car_rounded),
                    label: 'Vehicles',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.build_rounded),
                    label: 'Services',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GlassAppBar({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  static const double height = 96;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Flexible(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Karvaan',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withOpacity(0.72),
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (trailing != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}
