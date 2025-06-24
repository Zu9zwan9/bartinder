import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/theme/theme_bloc.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main_screen.dart';
import 'theme/theme.dart';

class BeerTinderApp extends StatelessWidget {
  const BeerTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'Beer Tinder',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
          ],
          routerConfig: _createRouter(context),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  // Create router with auth-aware routing
  GoRouter _createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isAuthRoute = state.matchedLocation.startsWith('/auth');

        // If user is authenticated and trying to access auth routes, redirect to main
        if (authState is AuthAuthenticated && isAuthRoute) {
          return '/';
        }

        // If user is not authenticated and not on auth routes, redirect to sign in
        if (authState is AuthUnauthenticated && !isAuthRoute) {
          return '/auth/signin';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthWrapper(
            child: MainScreen(),
          ),
        ),
        GoRoute(
          path: '/auth/signin',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/auth/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/auth/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
      ],
    );
  }
}
