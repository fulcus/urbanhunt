import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/contribute/form.dart';
import 'package:hunt_app/contribute/multiselect.dart';

import '../../helpers/utils.dart';


Future<void> main() async {
  final User user = await getMockedUser();

  setUpAll(() async {
    await Firebase.initializeApp();
  });


  testWidgets('Insert text', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: AddPlaceForm(loggedUser: user))
    );

    await tester.pumpWidget(testWidget);

    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    await tester.enterText(find.byType(TextFormField).first, 'ciao');
    await tester.enterText(find.byType(TextFormField).at(1), 'ciao');
    await tester.enterText(find.byType(TextFormField).last, 'ciao');
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField).first, findsOneWidget);
  });

  testWidgets('Select category', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: AddPlaceForm(loggedUser: user))
    );

    await tester.pumpWidget(testWidget);

    final multiChipFinder = find.byType(MultiSelectChip);
    await tester.ensureVisible(multiChipFinder);
    await tester.tap(multiChipFinder);
    await tester.pumpAndSettle();
    print('button tapped');

    expect(find.byType(Form), findsOneWidget);
  });

  testWidgets('Tap choose picture button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: AddPlaceForm(loggedUser: user))
    );

    await tester.pumpWidget(testWidget);

    final buttonFinder = find.byType(Center).first;
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    print('button tapped');

    expect(find.byType(Form), findsOneWidget);
  });

  testWidgets('Tap select location button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: AddPlaceForm(loggedUser: user))
    );

    await tester.pumpWidget(testWidget);

    final buttonFinder = find.byType(Center).at(1);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    print('button tapped');

    expect(find.byType(Form), findsOneWidget);
  });

  testWidgets('Tap submit button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: AddPlaceForm(loggedUser: user))
    );

    await tester.pumpWidget(testWidget);

    final buttonFinder = find.byType(Center).last;
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    print('button tapped');

    expect(find.byType(TextFormField), findsNothing);
  });

}
