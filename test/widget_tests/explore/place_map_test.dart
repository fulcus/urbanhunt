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

import '../../helpers/test_helpers.dart';


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
  await auth.signInWithCredential(credential);

  setupFirebaseAuthMocks();
  TestWidgetsFlutterBinding.ensureInitialized();


  setUpAll(() async {
    await Firebase.initializeApp();
  });


  testWidgets('PlaceMap Widget', (tester) async {

    final firestore = FakeFirebaseFirestore();
    await firestore.collection('places').add(<String, dynamic> {
      'address': <String, dynamic> {
        'city': 'Milan',
        'country': 'Italy',
        'street': '6, Viale Brianza'
      },
      'categories': <dynamic>[
        'food'
      ],
      'dislikes': 0,
      'imgpath': 'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67',
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

    //final List<DocumentSnapshot> places;
    //final List<DocumentSnapshot> unlockedPlaces;
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
