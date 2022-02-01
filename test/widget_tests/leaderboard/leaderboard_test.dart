
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/leaderboard/leaderboard.dart';

import '../../helpers/utils.dart';


Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Test tab controller', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: LeaderBoard(user, firestore))
    );

    await tester.pumpWidget(testWidget);
    
    final finder = find.byType(DefaultTabController);
    expect(find.descendant(of: finder, matching: find.byType(Tab)), findsNWidgets(2));

    final globalIconFinder = find.byIcon(Icons.public);
    await tester.tap(globalIconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(GlobalLeaderBoard), findsOneWidget);

    final localIconFinder = find.byIcon(Icons.near_me_outlined);
    await tester.tap(localIconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CountryLeaderBoard), findsOneWidget);
  });


  testWidgets('Test scrolling down global leaderboard', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: GlobalLeaderBoard(user, firestore))
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Flexible);
    expect(finder, findsOneWidget);

    await tester.drag(finder, Offset(0, 50));
    await tester.pumpAndSettle();
  });

  testWidgets('Test scrolling down country leaderboard', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(home: CountryLeaderBoard(user, firestore))
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Flexible);
    expect(finder, findsOneWidget);

    await tester.drag(finder, Offset(0, 50));
    await tester.pumpAndSettle();
  });

  testWidgets('Test Global LeaderboardRow Widget', (tester) async {
    String score = '10';
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(
              child: LeaderBoardRow(
                  user.displayName!,
                  'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67',
                  score,
                  'IT',
                  0,
                  Colors.indigo[50]!,
                  true
              )
            )
        )
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Container);
    expect(finder, findsNWidgets(8));
    expect(find.text('🥇'), findsOneWidget);
    expect(find.byType(Flag), findsOneWidget);
    expect(find.text(score+' '), findsOneWidget);
  });

  testWidgets('Test Country LeaderboardRow Widget', (tester) async {
    String score = '10';
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(
                child: LeaderBoardRow(
                    user.displayName!,
                    'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67',
                    score,
                    'IT',
                    1,
                    Colors.indigo[50]!,
                    false
                )
            )
        )
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Container);
    expect(finder, findsNWidgets(6));
    expect(find.text('🥈'), findsOneWidget);
    expect(find.byType(Flag), findsNothing);
    expect(find.text(score+' '), findsOneWidget);
  });

}