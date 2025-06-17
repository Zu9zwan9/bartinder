
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/bloc_observer.dart';
import 'presentation/app.dart';

void main() {
  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();

  runApp(const BeerTinderApp());
}
