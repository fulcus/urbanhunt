import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/profile/profile.dart';

import '../../helpers/utils.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();
  setupMockStorage();

  final snapshot = await firestore.collection('places').get();

  setUpAll(() async {
    await Firebase.initializeApp();
    HttpOverrides.global = null;
  });


  testWidgets('Change photo', (tester) async {

    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: Profile(user, firestore))
    );
    await tester.pumpWidget(testWidget);

  });

}