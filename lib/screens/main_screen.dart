import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/explore/explore_screen.dart';
import 'package:house_rent_app/screens/home/components/app_bottom_nav.dart';
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

  late PageController _pageController = PageController(initialPage: _navIndex);

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
    const items = [
      NavItem(Icons.home_rounded, 'Home'),
      NavItem(Icons.explore_rounded, 'Explore'),
      NavItem(Icons.bookmark_border_rounded, 'Saved'),
      NavItem(Icons.person_outline_rounded, 'Profile'),
    ];

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _navIndex = i),
        children: const [
          HomeScreen(),
          ExploreScreen(),
          SavedScreen(),
          ProfileScreen()
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: items,
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}
