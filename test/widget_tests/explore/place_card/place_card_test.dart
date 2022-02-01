import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:hunt_app/explore/place_card.dart';

import '../../../helpers/utils.dart';

bool isClosed = false;

void onCardClose() {
  isClosed = true;
}

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  user.providerData.add(UserInfo({'providerId':'password'}));
  setupMockStorage();
  final snapshot = await firestore.collection('places').get();

  setUpAll(() async {
    await Firebase.initializeApp();
    HttpOverrides.global = null;
  });

  testWidgets('Like PlaceCard', (tester) async {
    var placeCard = PlaceCard(user, firestore, PlaceData.fromSnapshot(snapshot.docs.first), false,
        false, false, onCardClose, unlockDate: Timestamp.now(),);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child:
            Directionality(textDirection: TextDirection.ltr, child: placeCard));

    await tester.pumpWidget(testWidget);

    final columnFinder = find.byType(Column);
    expect(columnFinder, findsWidgets);
    expect(
        find.descendant(
            of: columnFinder, matching: find.byType(GestureDetector)),
        findsNWidgets(5));
    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.widgetWithIcon(IconButton, Icons.lock), findsNothing);

    final finder = find.widgetWithIcon(GestureDetector, Icons.thumb_up_alt);
    expect(finder, findsOneWidget);

    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(placeCard.isLiked, true);
    expect(placeCard.isDisliked, false);
  });

  testWidgets('Dislike PlaceCard', (tester) async {
    var placeCard = PlaceCard(user, firestore, PlaceData.fromSnapshot(snapshot.docs.first), false,
      false, false, onCardClose, unlockDate: Timestamp.now(),);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child:
        Directionality(textDirection: TextDirection.ltr, child: placeCard));

    await tester.pumpWidget(testWidget);

    expect(find.widgetWithIcon(IconButton, Icons.lock), findsNothing);

    final finder = find.widgetWithIcon(GestureDetector, Icons.thumb_down_alt);
    expect(finder, findsOneWidget);

    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(placeCard.isLiked, false);
    expect(placeCard.isDisliked, true);

  });

  testWidgets('Swipe like and dislike', (tester) async {
    var placeCard = PlaceCard(user, firestore, PlaceData.fromSnapshot(snapshot.docs.first), false,
      true, false, onCardClose, unlockDate: Timestamp.now(),);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child:
        Directionality(textDirection: TextDirection.ltr, child: placeCard));

    await tester.pumpWidget(testWidget);

    expect(find.widgetWithIcon(IconButton, Icons.lock), findsNothing);

    final finder = find.widgetWithIcon(GestureDetector, Icons.thumb_down_alt);
    expect(finder, findsOneWidget);

    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(placeCard.isLiked, false);
    expect(placeCard.isDisliked, true);

  });

  testWidgets('Close place card', (tester) async {
    var placeCard = PlaceCard(user, firestore, PlaceData.fromSnapshot(snapshot.docs.first), true,
        true, false, onCardClose);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child:
            Directionality(textDirection: TextDirection.ltr, child: placeCard));

    await tester.pumpWidget(testWidget);

    final closeButton = find.widgetWithIcon(IconButton, Icons.close_rounded);
    await tester.ensureVisible(closeButton);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(isClosed, true);
  });

  testWidgets('Try unlock place card, GPS off', (tester) async {
    //TODO GPS off
    var placeCard = PlaceCard(user, firestore, PlaceData.fromSnapshot(snapshot.docs.first), true,
        false, false, onCardClose);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child:
            Directionality(textDirection: TextDirection.ltr, child: placeCard));

    await tester.pumpWidget(testWidget);

    final finder = find.widgetWithIcon(IconButton, Icons.lock);
    expect(finder, findsOneWidget);

    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(finder, findsOneWidget);
    expect(placeCard.isLocked, true);
  });

}
