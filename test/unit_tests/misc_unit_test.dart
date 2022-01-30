

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/utils/misc.dart';

void main() {
  Map<String, String?> _data1 = {'providerId':'password'};
  Map<String, String?> _data2 = {'providerId':'google.com'};


  final user1 = MockUser(
    isAnonymous: false,
    uid: '076R1REcV2cFma2h2gFcrPU8kT92',
    email: 'bob@somedomain.com',
    displayName: 'Bob',
    providerData: [UserInfo(_data1)]
  );

  final user2 = MockUser(
      isAnonymous: false,
      uid: '076R1REcV2cFma2h2gFcrPU8kT92',
      email: 'bob@somedomain.com',
      displayName: 'Bob',
      providerData: [UserInfo(_data2)]
  );

  group('Test if user is EmailAuth or not', ()
  {
    test('EmailAuth', () {
      var result = isEmailAuthProvider(user1);
      expect(result, true);
    });

    test('Not EmailAuth', () {
      var result = isEmailAuthProvider(user2);
      expect(result, false);
    });
  });

}