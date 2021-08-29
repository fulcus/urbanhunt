import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:hunt_app/explore/explore.dart';

import '../helpers/test_helpers.dart';


Future<void> main() async {
  // Mock sign in with Google.
  final googleSignIn = MockGoogleSignIn();
  final signInAccount = await googleSignIn.signIn();
  final googleAuth = await signInAccount!.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  // Sign in.
  final user = MockUser(
    isAnonymous: false,
    uid: '076R1REcV2cFma2h2gFcrPU8kT92',
    email: 'bob@somedomain.com',
    displayName: 'Bob',
  );
  final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
  final result = await auth.signInWithCredential(credential);

  setupFirebaseAuthMocks();


  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('PlaceMap Widget', (tester) async {

    final firestore = FakeFirebaseFirestore();
    await firestore.collection('places').add(<String, dynamic> {
      'address': <String, dynamic> {
        'city': 'Milan',
        'country': 'Italy',
        'address': '6, Viale Brianza'
      },
      'categories': <String, dynamic> {},
      'dislikes': 0,
      'imgpath': null,
      'likes': 0,
      'location': GeoPoint(0, 0),
      'lockedDescr': 'none',
      'name': 'mock',
      'unlockedDescr': 'none',
    });

    await firestore.collection('users').add(<String, dynamic> {
      'country': 'Italy',
      'imageURL': '',
      'score': 0,
      'username': 'MockedUser'
    });

    final List<DocumentSnapshot> places;
    final List<DocumentSnapshot> unlockedPlaces;
    final initialPosition = LatLng(0.0, 0.0);
    final mapController = Completer<GoogleMapController>();

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: Material(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child:
                PlaceMap(
                  places: [],
                  unlockedPlaces: [],
                  initialPosition: initialPosition,
                  mapController: mapController
                )
            )
        ));

    await tester.pumpWidget(testWidget);

    //create the finders
    final gmapFinder = find.byType(GoogleMap);
    final paddingFinder = find.byType(Padding);

    expect(gmapFinder, findsOneWidget);
    expect(paddingFinder, findsNWidgets(2));
    expect(find.descendant(of: paddingFinder, matching: find.byType(CircleAvatar)), findsOneWidget);
    expect(find.descendant(of: paddingFinder, matching: find.byType(IconButton)), findsOneWidget);
    expect(find.descendant(of: paddingFinder, matching: find.byType(Icon)), findsOneWidget);

    expect(find.descendant(of: paddingFinder, matching: find.byIcon(Icons.explore)), findsNothing);

    await tester.tap(find.byIcon(Icons.my_location));

    await tester.pump();

    //expect()


    var testGesture = await tester.createGesture();
    await testGesture.downWithCustomEvent(Offset(10, 30), PointerDownEvent(
        position: Offset(48, 20),orientation: 34));
    await tester.pumpAndSettle();
    /*expect(find.descendant(of: paddingFinder, matching: find.byIcon(Icons.explore)), findsOneWidget);
    await tester.tap(find.byIcon(Icons.explore));
    await tester.pump();
    expect(find.descendant(of: paddingFinder, matching: find.byIcon(Icons.explore)), findsNothing);
*/
  });
}
