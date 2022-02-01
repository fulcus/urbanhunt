import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunt_app/explore/explore.dart';
import 'package:hunt_app/explore/place_card.dart';

import '../../helpers/utils.dart';


Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  final snapshot1 = await firestore.collection('places').get();
  final List<DocumentSnapshot> places = getDocumentSnapshots(snapshot1);

  final snapshot2 = await firestore.collection('users').doc(user.uid).collection('unlockedPlaces').get();
  final List<DocumentSnapshot> unlockedPlaces = getDocumentSnapshots(snapshot2);

  final Completer<GoogleMapController> _mapController = Completer();


  testWidgets('PlaceMap Widget', (tester) async {
    final initialPosition = LatLng(0.0, 0.0);
    final mapController = Completer<GoogleMapController>();

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: Material(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child:
                PlaceMap(
                  loggedUser: user,
                  db: firestore,
                  places: places,
                  unlockedPlaces: unlockedPlaces,
                  initialPosition: initialPosition,
                  mapController: mapController
                )
            )
        ));

    await tester.pumpWidget(testWidget);

    //create the finders
    final gmapFinder = find.byType(GoogleMap);
    final finder = find.byType(CircleAvatar);

    expect(gmapFinder, findsOneWidget);
    expect(finder, findsNWidgets(2));
    expect(find.descendant(of: finder, matching: find.byType(CircleAvatar)), findsOneWidget);
    expect(find.descendant(of: finder, matching: find.byType(Icon)), findsOneWidget);

    expect(find.descendant(of: finder, matching: find.byIcon(Icons.my_location)), findsOneWidget);
    await tester.drag(gmapFinder, Offset(10, 10));
    //final controller = await mapController.future;
    //await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(10, 10))));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pump();

    expect(initialPosition, LatLng(0, 0));


    expect(find.descendant(of: finder, matching: find.byIcon(Icons.explore)), findsNothing);
   /* var testGesture = await tester.createGesture();
    await testGesture.downWithCustomEvent(Offset(10, 30), PointerDownEvent(
        position: Offset(48, 20), orientation: 34));
    await tester.pumpAndSettle();
    expect(find.descendant(of: finder, matching: find.byIcon(Icons.explore)), findsOneWidget);
    await tester.tap(find.byIcon(Icons.explore));
    await tester.pumpAndSettle();
    expect(find.descendant(of: finder, matching: find.byIcon(Icons.explore)), findsNothing);*/
  });

  testWidgets('No PlaceCard by default', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: Material(
            child: Directionality(
                textDirection: TextDirection.ltr,
                child:
                PlaceMap(
                    loggedUser: user,
                    db: firestore,
                    places: places,
                    unlockedPlaces: unlockedPlaces,
                    initialPosition: LatLng(0, 0),
                    mapController: _mapController
                )
            )
        ));

    await tester.pumpWidget(testWidget);

    expect(find.byType(GoogleMap), findsOneWidget);
    expect(find.byType(PlaceCard), findsNothing);


    /*tester.tap(marker);
    tester.pumpAndSettle();

    final placeCardFinder = find.byType(PlaceCard);
    expect(placeCardFinder, findsOneWidget);*/

  });

}
