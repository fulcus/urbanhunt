
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/auth/login_page.dart';

import '../../helpers/utils.dart';


Future<void> main() async {
  await getMockedUser();
  await getFakeFirestoreInstance();
  setupMockStorage();

  setUpAll(() async {
    await Firebase.initializeApp();
  });


  testWidgets('Try to login with email and password, user is not registered', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: LoginPage())
    );

    await tester.pumpWidget(testWidget);

    final loginBtnFinder = find.text('LOGIN');
    await tester.tap(loginBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'ciao@ciao.it');
    await tester.enterText(find.byType(TextFormField).last, 'HelloWorld');
    await tester.tap(loginBtnFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Try to login with Facebook', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: LoginPage())
    );

    await tester.pumpWidget(testWidget);

    final loginFbBtnFinder = find.text('Login with facebook');
    await tester.tap(loginFbBtnFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Try to login with Google', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: LoginPage())
    );

    await tester.pumpWidget(testWidget);

    final loginGoogleBtnFinder = find.byType(GestureDetector).at(2);
    await tester.tap(loginGoogleBtnFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Tap on forgot password', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: LoginPage())
    );

    await tester.pumpWidget(testWidget);

    final finder = find.text('Forgot Password?');
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(ResetPasswordPage), findsOneWidget);
  });

  testWidgets('Tap on sign up now', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: LoginPage())
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(InkWell).last;
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('Try to sign up', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: SignupPage())
    );

    await tester.pumpWidget(testWidget);

    final submitBtnFinder = find.text('SIGN UP');
    await tester.tap(submitBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'ciao@ciao.it');
    await tester.enterText(find.byType(TextFormField).last, 'HelloWorld');
    await tester.tap(submitBtnFinder);
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('Tap on login now', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: SignupPage())
    );

    await tester.pumpWidget(testWidget);

    final finder = find.text('Login now');
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsNothing);
  });

  testWidgets('Tap on send email', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: ResetPasswordPage())
    );

    await tester.pumpWidget(testWidget);

    final finder = find.text('SEND EMAIL');
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'ciao@ciao.it');
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordPage), findsOneWidget);
  });

  testWidgets('Tap on go back', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: ResetPasswordPage())
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(InkWell).first;
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordPage), findsNothing);
  });

}
