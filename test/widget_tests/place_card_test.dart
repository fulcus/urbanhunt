import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:hunt_app/explore/place_card.dart';

import '../helpers/test_helpers.dart';

bool isClosed = false;

void onCardClose() {
  isClosed = true;
}

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

  final storage = MockFirebaseStorage();
  final storageRef = storage.ref().child('assets/images/as.png');
  final image = File('assets/images/as.png');
  await storageRef.putFile(image);

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
    'location': GeoPoint(45.464664, 9.188540),
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

  final snapshot = await firestore.collection('places').get();

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
    HttpOverrides.global = null;
  });



  testWidgets('Like PlaceCard', (tester) async {

    var placeCard = PlaceCard(snapshot.docs.first, true, false, false, onCardClose, Timestamp.now());

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: placeCard
        )
    );

    await tester.pumpWidget(testWidget);

    final columnFinder = find.byType(Column);
    expect(columnFinder, findsWidgets);
    expect(find.descendant(of: columnFinder, matching: find.byType(GestureDetector)), findsNWidgets(5));
    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.widgetWithIcon(IconButton, Icons.lock), findsNothing);

    final finder = find.widgetWithIcon(GestureDetector, Icons.thumb_up_alt);
    expect(finder, findsOneWidget);

    await tester.tap(finder);
    await tester.pump();
    expect(placeCard.isLiked, true); //TODO not working (because of db call)

  });

  testWidgets('Close place card', (tester) async {
    var placeCard = PlaceCard(snapshot.docs.first, true, true, false, onCardClose, Timestamp.now());

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: placeCard
        )
    );

    await tester.pumpWidget(testWidget);

    final finder = find.widgetWithIcon(IconButton, Icons.close_rounded);
    await tester.tap(finder);
    await tester.pump();
    expect(isClosed, true);
  });

  testWidgets('Unlock place card', (tester) async {
    var placeCard = PlaceCard(snapshot.docs.first, true, true, false, onCardClose, Timestamp.now());

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: placeCard
        )
    );

    await tester.pumpWidget(testWidget);

    final finder = find.widgetWithIcon(IconButton, Icons.lock);
    expect(finder, findsOneWidget);

    await tester.tap(finder);
    await tester.pump();

    expect(finder, findsWidgets);


  });

}
