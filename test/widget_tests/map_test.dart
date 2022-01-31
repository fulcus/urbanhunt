import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:hunt_app/explore/explore.dart';

import '../helpers/test_helpers.dart';

void main() {

  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('MAP TEST', (tester) async {
    /// Mock user sign in
    final googleSignIn = MockGoogleSignIn();
    final signInAccount = await googleSignIn.signIn();
    final googleAuth = await signInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final user = MockUser(
      isAnonymous: false,
      uid: '076R1REcV2cFma2h2gFcrPU8kT92',
      email: 'bob@somedomain.com',
      displayName: 'Bob',
    );
    final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
    await auth.signInWithCredential(credential);

    /// Populate the mock database.
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




    // Render the widget.
    await tester.pumpWidget(MaterialApp(
        title: 'Firestore Example', home: Explore(user, firestore)));
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();
    // // Verify the output.
    //expect(find.text('Hello world!'), findsOneWidget);
  });
}

