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
  late PageController _pageController;

  // Cache for nav items to prevent recreation
  static const List<NavItem> _navItems = [
    NavItem(Icons.home_rounded, 'Home'),
    NavItem(Icons.explore_rounded, 'Explore'),
    NavItem(Icons.bookmark_border_rounded, 'Saved'),
    NavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  // Screen cache to maintain state
  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_navIndex == index) return;

    setState(() => _navIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _MainScreenContent(
        pageController: _pageController,
        navIndex: _navIndex,
        screens: _screens,
        onPageChanged: (index) {
          if (_navIndex != index) {
            setState(() => _navIndex = index);
          }
        },
      ),
      // bottomNavigationBar: _MainBottomNav(
      //   navIndex: _navIndex,
      //   onNavTap: _onNavTap,
      // ),
    );
  }
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

// Extracted bottom navigation for selective rebuilds
class _MainBottomNav extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavTap;

  const _MainBottomNav({
    required this.navIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      items: _MainScreenState._navItems,
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

// Advanced version with page controller and state preservation
class AdvancedMainScreen extends StatefulWidget {
  const AdvancedMainScreen({super.key});

  @override
  State<AdvancedMainScreen> createState() => _AdvancedMainScreenState();
}

class _AdvancedMainScreenState extends State<AdvancedMainScreen> {
  int _navIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  static const List<NavItem> _navItems = [
    NavItem(Icons.home_rounded, 'Home'),
    NavItem(Icons.explore_rounded, 'Explore'),
    NavItem(Icons.bookmark_border_rounded, 'Saved'),
    NavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_navIndex == index) return;

    setState(() => _navIndex = index);

    // Use animateToPage for smooth transition or jumpToPage for instant
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    if (_navIndex != index) {
      setState(() => _navIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // or PageScrollPhysics() for swipe
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: _MainBottomNav(
        navIndex: _navIndex,
        onNavTap: _onNavTap,
      ),
    );
  }
}