import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();

  runApp(const BeerTinderRoot());
}

class BeerTinderRoot extends StatelessWidget {
  const BeerTinderRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => ThemeBloc()..add(const LoadThemeEvent())),
      ],
      child: const BeerTinderApp(),
    );
  }
}
