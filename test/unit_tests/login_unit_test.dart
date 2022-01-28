import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:hunt_app/auth/login_page.dart';

import '../helpers/test_helpers.dart';


/*
* loginFacebook
* loginGoogle
* loginEmailPassword
* signupAndLoginEmailPassword
* validateForm
* placeCard
* helpers
* */

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
  print(user1!.displayName);


  setupFirebaseAuthMocks();


  setUpAll(() async {
    await Firebase.initializeApp();
  });



  group('Backend Utils', () {
    test('redirectHome', () {
      StreamBuilder result = redirectHomeOrLogin();
      expect(result, 'Email is required');
    });

  });
}

