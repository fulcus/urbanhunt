import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  final result = await auth.signInWithCredential(credential);
  final user1 = result.user;

  setupFirebaseAuthMocks();


  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Explore Widget', (tester) async {

    // Populate the mock database.
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
      'username': 'Bob'
    });

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Explore(user1!, firestore))
    );

    await tester.pumpWidget(testWidget);

    //create the finders
    final finder = find.byType(Scaffold);

    expect(finder, findsOneWidget);
    expect(find.descendant(of: finder, matching: find.byType(StreamBuilder<QuerySnapshot>)), findsNWidgets(2));
  });
}
