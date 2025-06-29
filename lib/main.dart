import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'core/bloc_observer.dart';
import 'data/services/auth_service.dart';
import 'presentation/app.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme
  AppTheme.initialize();

  // Load environment variables
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  // Initialize AuthService for listening to auth state
  AuthService.initialize();

  // Initialize deep link handling for OAuth callbacks
  _initializeDeepLinks();

  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();

  runApp(const BeerTinderRoot());
}

/// Initialize deep link handling for OAuth callbacks
void _initializeDeepLinks() {
  final appLinks = AppLinks();

  // Handle incoming deep links when app is already running
  appLinks.uriLinkStream.listen((uri) {
    _handleDeepLink(uri);
  }, onError: (err) {
    if (kDebugMode) {
      print('Deep link error: $err');
    }
  });

  // Handle deep link when app is launched from a deep link
  appLinks.getInitialLink().then((uri) {
    if (uri != null) {
      _handleDeepLink(uri);
    }
  }).catchError((err) {
    if (kDebugMode) {
      print('Initial deep link error: $err');
    }
  });
}

/// Handle incoming deep link URIs
void _handleDeepLink(Uri uri) {
  if (kDebugMode) {
    print('Received deep link: $uri');
  }

  // Check if this is an OAuth callback
  if (uri.scheme == 'com.7wells.sipswipe' && uri.host == 'login-callback') {
    if (kDebugMode) {
      print('OAuth callback received, processing with Supabase...');
    }

    // Handle the OAuth callback by passing the full URI to Supabase
    _handleOAuthCallback(uri);
  }
}

/// Handle OAuth callback from deep link
void _handleOAuthCallback(Uri uri) async {
  try {
    // Extract the fragment or query parameters that contain the OAuth response
    final String uriString = uri.toString();

    if (kDebugMode) {
      print('Processing OAuth callback: $uriString');
    }

    // Supabase expects the callback to be handled through its session management
    // The auth state listener in AuthService will automatically detect the session change
    await Supabase.instance.client.auth.getSessionFromUrl(uri);

    if (kDebugMode) {
      print('OAuth callback processed successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error processing OAuth callback: $e');
    }
  }
}

class BeerTinderRoot extends StatelessWidget {
  const BeerTinderRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(
          create: (context) => ThemeBloc()..add(const LoadThemeEvent()),
        ),
      ],
      child: const BeerTinderApp(),
    );
  }
}
