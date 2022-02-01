import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

import 'test_helpers.dart';

Future<User> getMockedUser() async {
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

  setupFirebaseAuthMocks();

  return user;
}

Future<FakeFirebaseFirestore> getFakeFirestoreInstance() async {
  final firestore = FakeFirebaseFirestore();
  final User user = await getMockedUser();

  /// Populate the mock database.
  await firestore.collection('places').add(<String, dynamic>{
    'address': <String, dynamic>{
      'city': 'Milan',
      'country': 'Italy',
      'street': '6, Viale Brianza'
    },
    'categories': <dynamic>[
      'food'
    ],
    'creatorId': '076R1REcV2cFma2h2gFcrPU8kT92',
    'dislikes': 0,
    'imgpath': 'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67',
    'likes': 0,
    'location': GeoPoint(45.464664, 9.188540),
    'lockedDescr': 'none',
    'name': 'mock',
    'unlockedDescr': 'none',
  });

  await firestore.collection('users').add(<String, dynamic>{
    'country': 'Italy',
    'imageURL': '',
    'score': 0,
    'username': 'MockedUser'
  });

  await firestore.collection('users').doc(user.uid)
      .collection('unlockedPlaces')
      .add(<String, dynamic>{
    'disliked': false,
    'liked': false,
    'unlockDate': Timestamp.now(),
  });

  return firestore;
}

Future<void> setupMockStorage() async {
  final storage = MockFirebaseStorage();
  final storageRef = storage.ref().child('assets/images/default-profile.png');
  final image = File('assets/images/default-profile.png');
  await storageRef.putFile(image);
}



