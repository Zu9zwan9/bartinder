import 'package:flutter/cupertino.dart';

import '../widgets/app_bottom_navigation.dart';
import 'bars_screen.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BarsScreen(),
    const MatchesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Current screen
          _screens[_currentIndex],

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
