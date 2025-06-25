import 'package:flutter/cupertino.dart';

class BeerTinderApp extends StatelessWidget {
  const BeerTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('BeerTinder')),
      child: Center(child: Text('Welcome to BeerTinder!')),
    );
  }
}
