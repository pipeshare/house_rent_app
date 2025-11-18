import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/explore/explore_screen.dart';
import 'package:house_rent_app/screens/components/app_bottom_nav.dart';
import 'package:house_rent_app/screens/home/home_screen.dart';
import 'package:house_rent_app/screens/profile/profile_screen.dart';
import 'package:house_rent_app/screens/saved/saved_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _navIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    if (_navIndex == index) return;
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _navIndex,
        children: _screens,
      ),
      bottomNavigationBar: _MainBottomNav(
        navIndex: _navIndex,
        onNavTap: _onNavTap,
      ),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavTap;

  static const List<NavItem> _navItems = [
    NavItem(Icons.home_rounded, 'Home'),
    NavItem(Icons.explore_rounded, 'Explore'),
    NavItem(Icons.bookmark_border_rounded, 'Saved'),
    NavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  const _MainBottomNav({
    required this.navIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      items: _navItems,
      currentIndex: navIndex,
      onTap: onNavTap,
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

// Extracted main screen content for better performance
class _MainScreenContent extends StatelessWidget {
  final PageController pageController;
  final int navIndex;
  final List<Widget> screens;
  final ValueChanged<int> onPageChanged;

  const _MainScreenContent({
    required this.pageController,
    required this.navIndex,
    required this.screens,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: onPageChanged,
      children: screens,
    );
  }
}