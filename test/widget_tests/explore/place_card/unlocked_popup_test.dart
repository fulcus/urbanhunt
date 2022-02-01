import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/explore/unlocked_popup.dart';
import 'package:lottie/lottie.dart';


Future<void> main() async {

  testWidgets('Unlocked popup Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: UnlockedPopup())
    );

    await tester.pumpWidget(testWidget);

    expect(find.byType(Lottie), findsOneWidget);

    final findText = find.text('Congratulations!');

    expect(findText, findsOneWidget);

    final finder = find.text('Keep Exploring');
    await tester.ensureVisible(finder);
    //TODO cannot tap
    await tester.tap(finder);
    await tester.pumpAndSettle();

    //expect(findText, findsNothing);
  });

}
