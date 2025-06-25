import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipswipe/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const BeerTinderRoot());

    // Verify that the app loads without crashing
    expect(find.byType(CupertinoApp), findsOneWidget);
  });
}
