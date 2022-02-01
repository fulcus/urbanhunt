import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/explore/explore.dart';

import '../../helpers/utils.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Explore Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Explore(user, firestore))
    );

    await tester.pumpWidget(testWidget);

    //create the finders
    final finder = find.byType(Scaffold);

    expect(finder, findsOneWidget);
    expect(find.descendant(of: finder, matching: find.byType(StreamBuilder<QuerySnapshot>)), findsNWidgets(2));
  });
}
