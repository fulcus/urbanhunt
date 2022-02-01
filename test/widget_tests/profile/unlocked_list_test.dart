
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:hunt_app/explore/place_card.dart';
import 'package:hunt_app/profile/unlocked_list.dart';

import '../../helpers/utils.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setupMockStorage();

  final allPlaces = await firestore.collection('places').get();
  var placeId = allPlaces.docs.first.id;
  final snapshot = await firestore.collection('users').doc(user.uid).collection('unlockedPlaces').get();
  final List<DocumentSnapshot> places = getDocumentSnapshots(snapshot);

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('UnlockedList Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: UnlockedList(user, firestore))
    );
    await tester.pumpWidget(testWidget);

    final finder = find.byType(StreamBuilder<QuerySnapshot>);
    expect(finder, findsOneWidget);

    await tester.pump(Duration(seconds: 5));

    final textFinder = find.text('You have not unlocked any place yet.\nGet to work!');
    expect(textFinder, findsNothing);

    expect(find.byType(Helper), findsOneWidget);
  });

  testWidgets('Helper Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: Material(
              child: Helper(user, firestore, [placeId], places))
            )
    );
    await tester.pumpWidget(testWidget);

    final finder = find.byType(StreamBuilder<List<PlaceData>>);
    expect(finder, findsOneWidget);

    await tester.pump(Duration(seconds: 5));
    expect(find.byType(UnlockedListRow), findsOneWidget);
  });

  testWidgets('UnlockedListRow Widget', (tester) async {
    List<DocumentSnapshot> places = getDocumentSnapshots(allPlaces);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home:
        Material(
            child: UnlockedListRow(
                user, firestore, PlaceData.fromSnapshot(places.first),
                false, false, Timestamp.now(), 'Milan', 'IT', '6, Viale Brianza', 'none', 'Place'))
        )
    );
    await tester.pumpWidget(testWidget);

    final tapFinder = find.byType(InkWell);
    await tester.tap(tapFinder);
    await tester.pumpAndSettle();
    expect(find.byType(PlaceCard), findsOneWidget);
    expect(find.byType(UnlockedListRow), findsNothing);
  });

}