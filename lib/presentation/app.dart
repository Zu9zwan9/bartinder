import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'screens/main_screen.dart';
import 'theme/theme.dart';

class BeerTinderApp extends StatelessWidget {
  const BeerTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'Beer Tinder',
      theme: AppTheme.cupertinoTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  // Router configuration
  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      // Additional routes will be added here
    ],
  );
}
