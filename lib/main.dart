import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/bloc_observer.dart';
import 'presentation/app.dart';
import 'presentation/blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();

  runApp(const BeerTinderRoot());
}

class BeerTinderRoot extends StatelessWidget {
  const BeerTinderRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const BeerTinderApp(),
    );
  }
}
