import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/contribute/thankyou.dart';


Future<void> main() async {

  testWidgets('ThankYou page Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: ContributeThankYou())
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byIcon(Icons.add);
    final findText = find.text('Thank you for contributing to UrbanHunt!');

    expect(findText, findsOneWidget);

    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(findText, findsNothing);
  });

}