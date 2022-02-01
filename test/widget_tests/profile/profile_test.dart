import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hunt_app/auth/login_page.dart';
import 'package:hunt_app/profile/custom_alert_dialog.dart';
import 'package:hunt_app/profile/profile.dart';
import 'package:hunt_app/profile/unlocked_list.dart';

import '../../helpers/utils.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  user.providerData.add(UserInfo({'providerId':'password'}));
  setupMockStorage();

  setUpAll(() async {
    await Firebase.initializeApp();
    HttpOverrides.global = null;
  });


  testWidgets('Tap change photo button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);
    
    final finder = find.byType(StreamBuilder<QuerySnapshot>);
    expect(finder, findsOneWidget);

    await tester.pump(Duration(seconds: 5));

    final iconFinder = find.byIcon(Icons.camera_alt);
    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    print('button tapped');
  });

  testWidgets('Edit name and tap Cancel', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));
    final iconFinder = find.byIcon(Icons.edit).first;
    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    final textFinder = find.byType(TextFormField).first;
    await tester.tap(textFinder);
    await tester.pumpAndSettle();
    await tester.enterText(textFinder, 'NewName');
    expect(find.text('NewName'), findsOneWidget);

    final cancelBtnFinder = find.byType(ElevatedButton).last;
    await tester.tap(cancelBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('NewName'), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Edit name and tap Save', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));
    final iconFinder = find.byIcon(Icons.edit).first;
    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    final textFinder = find.byType(TextFormField).first;
    await tester.tap(textFinder);
    await tester.pumpAndSettle();
    await tester.enterText(textFinder, 'NewName');
    expect(find.text('NewName'), findsOneWidget);

    final saveBtnFinder = find.byType(ElevatedButton).first;
    await tester.tap(saveBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('NewName'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Test password field and verification icon presence, GoogleAuth', (tester) async {
    user.providerData.clear();
    user.providerData.add(UserInfo({'providerId':'google.com'}));

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));

    //no password provider => password is not shown
    final pswField = find.text('Password');
    expect(pswField, findsNothing);

    //no password provider => verified by default
    expect(find.byIcon(Icons.verified), findsOneWidget);
    expect(find.byType(FaIcon), findsOneWidget);

    user.providerData.clear();
    user.providerData.add(UserInfo({'providerId':'password'}));
  });

  testWidgets('Test password field and verification icon presence, EmailAuth', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));

    final pswField = find.text('Password');
    expect(pswField, findsOneWidget);

    //email is verified => verification icon is present
    expect(find.byIcon(Icons.verified), findsOneWidget);
    expect(find.byType(FaIcon), findsOneWidget);
  });

  //change isEmailVerified to false in utils and then execute this test
  /*testWidgets('Test email not verified', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));

    final pswField = find.text('Password');
    expect(pswField, findsOneWidget);

    expect(find.byIcon(Icons.verified), findsNothing);
    final iconFinder = find.byType(FaIcon);
    expect(iconFinder, findsNWidgets(2));

    await tester.tap(iconFinder.first);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });*/

  testWidgets('Edit password and tap Cancel', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));
    final iconFinder = find.byIcon(Icons.edit).last;
    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    final textFinder = find.byType(TextFormField).last;
    await tester.tap(textFinder);
    await tester.pumpAndSettle();
    await tester.enterText(textFinder, 'NewPassword');
    expect(find.text('NewPassword'), findsOneWidget);

    final cancelBtnFinder = find.byType(ElevatedButton).last;
    await tester.tap(cancelBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('**********'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Edit password and tap Save', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));
    final iconFinder = find.byIcon(Icons.edit).last;
    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    final textFinder = find.byType(TextFormField).last;
    await tester.tap(textFinder);
    await tester.pumpAndSettle();
    await tester.enterText(textFinder, 'NewPassword');
    expect(find.text('NewPassword'), findsOneWidget);

    final saveBtnFinder = find.byType(ElevatedButton).last;
    await tester.tap(saveBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('**********'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Tap update country button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));

    final countryFinder = find.byIcon(Icons.arrow_drop_down);
    await tester.ensureVisible(countryFinder);
    await tester.tap(countryFinder, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(countryFinder, findsOneWidget);
  });

  testWidgets('Check total score', (tester) async {
    String score = '0';
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));
    expect(find.text(score+' '), findsOneWidget);
  });

  testWidgets('Tap on MyUnlockedPlaces button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));

    final iconFinder = find.byType(FaIcon).last;
    await tester.dragUntilVisible(iconFinder, find.byType(ListView), Offset(0, 50));
    await tester.pumpAndSettle();
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockedList), findsOneWidget);
    expect(find.byType(Profile), findsNothing);
  });

  testWidgets('Tap on logout button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));

    final btnFinder = find.byIcon(Icons.exit_to_app);
    await tester.dragUntilVisible(btnFinder, find.byType(ListView), Offset(0, 50));
    await tester.pumpAndSettle();
    await tester.tap(btnFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(Profile), findsNothing);
  });

  testWidgets('Tap on delete account button', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 5));

    final btnFinder = find.byIcon(Icons.delete_outline);
    await tester.dragUntilVisible(btnFinder, find.byType(ListView), Offset(0, 50));
    await tester.pumpAndSettle();
    await tester.tap(btnFinder);
    await tester.pumpAndSettle();

    expect(find.byType(CustomAlertDialog), findsOneWidget);
    expect(find.byType(Profile), findsOneWidget);
  });

}