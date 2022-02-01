import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/explore/place_card.dart';


Future<void> main() async {

  testWidgets('Google Maps button Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: GmapButton(latitude: 0, longitude: 0))
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(GestureDetector);
    final textFinder = find.text('Start');

    expect(finder, findsOneWidget);
    expect(textFinder, findsOneWidget);

    //after tapping the GestureDetector is still there,
    //the url launcher cannot be tested
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(finder, findsOneWidget);

  });
}
