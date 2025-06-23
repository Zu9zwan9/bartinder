// Basic Flutter widget test for Beer Tinder app

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beertinder/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const BeerTinderRoot());

    // Verify that the app loads without crashing
    expect(find.byType(CupertinoApp), findsOneWidget);
  });
}
