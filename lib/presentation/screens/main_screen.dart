import 'package:flutter/cupertino.dart';

import '../widgets/app_bottom_navigation.dart';
import 'home_screen.dart';

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

/// Placeholder for the Bars screen
class BarsScreen extends StatelessWidget {
  const BarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Discover Bars'),
      ),
      child: Center(
        child: Text('Bars screen coming soon!'),
      ),
    );
  }
}

/// Placeholder for the Matches screen
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Your Matches'),
      ),
      child: Center(
        child: Text('Matches screen coming soon!'),
      ),
    );
  }
}

/// Placeholder for the Profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Your Profile'),
      ),
      child: Center(
        child: Text('Profile screen coming soon!'),
      ),
    );
  }
}
