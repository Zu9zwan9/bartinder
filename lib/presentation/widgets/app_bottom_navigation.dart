import 'package:flutter/cupertino.dart';

import '../theme/theme.dart';

/// Bottom navigation bar for the app
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      activeColor: AppTheme.primaryColor,
      inactiveColor: AppTheme.secondaryTextColor(context),
      backgroundColor: AppTheme.cardColor(context),
      border: const Border(
        top: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_2_fill),
          label: 'People',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.map_fill),
          label: 'Bars',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chat_bubble_2_fill),
          label: 'Matches',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_crop_circle),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
