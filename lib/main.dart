import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/bloc_observer.dart';
import 'presentation/app.dart';
import 'presentation/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );
  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();

  final prefs = await SharedPreferences.getInstance();
  final hasUser = prefs.getString('user_name') != null &&
      prefs.getString('user_age') != null &&
      prefs.getString('user_email') != null;

  runApp(_BeerTinderRoot(showSignUp: !hasUser));
}

class _BeerTinderRoot extends StatefulWidget {
  final bool showSignUp;
  const _BeerTinderRoot({required this.showSignUp});

  @override
  State<_BeerTinderRoot> createState() => _BeerTinderRootState();
}

class _BeerTinderRootState extends State<_BeerTinderRoot> {
  late bool _showSignUp;

  @override
  void initState() {
    super.initState();
    _showSignUp = widget.showSignUp;
  }

  void _onSignedUp() {
    setState(() {
      _showSignUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSignUp) {
      return CupertinoApp(
        home: SignUpScreen(onSignedUp: _onSignedUp),
        debugShowCheckedModeBanner: false,
      );
    }
    return const BeerTinderApp();
  }
}
