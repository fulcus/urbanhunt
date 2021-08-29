
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/utils/validation_helper.dart';

ValidationHelper validationHelper = ValidationHelper();

void main() {
  String? result;

  group('Email Validator', () {
    test('Null Email Test', () {
      result = validationHelper.validateEmail(null);
      expect(result, 'Email is required');
    });

    test('Empty Email Test', () {
      result = validationHelper.validateEmail('');
      expect(result, 'Email is required');
    });

    test('Invalid Email test 1', () {
      result = validationHelper.validateEmail(' ');
      expect(result, 'Invalid email');
    });

    test('Invalid Email test 2', () {
      result = validationHelper.validateEmail('ciao');
      expect(result, 'Invalid email');
    });

    test('Invalid Email test 3', () {
      result = validationHelper.validateEmail('ciao@mail');
      expect(result, 'Invalid email');
    });

    test('Valid Email test', () {
      result = validationHelper.validateEmail('ciao@mail.it');
      expect(result, null);
    });
  });


  group('Password Validator', () {
    test('Null Password Test', () {
      result = validationHelper.validatePassword(null);
      expect(result, 'Password is required');
    });

    test('Empty Password Test', () {
      result = validationHelper.validatePassword('');
      expect(result, 'Password is required');
    });

    test('Weak Password test 1', () {
      result = validationHelper.validatePassword(' ');
      expect(result, 'The password is too weak, please insert another one');
    });

    test('Weak Password test 2', () {
      result = validationHelper.validatePassword('Milan');
      expect(result, 'The password is too weak, please insert another one');
    });

    test('Invalid Password test', () {
      result = validationHelper.validatePassword('                    ');
      expect(result, 'Invalid password');
    });

    test('Valid Password test', () {
      result = validationHelper.validatePassword('HuntApp');
      expect(result, null);
    });
  });


  group('PlaceName Validator', () {
    test('Null PlaceName Test', () {
      result = validationHelper.validatePlaceName(null);
      expect(result, 'Name is required');
    });

    test('Empty PlaceName Test 1', () {
      result = validationHelper.validatePlaceName('');
      expect(result, 'Name is required');
    });

    test('Empty PlaceName Test 2', () {
      result = validationHelper.validatePlaceName('                     ');
      expect(result, 'Name is required');
    });

    test('Too Short PlaceName Test', () {
      result = validationHelper.validatePlaceName('Pm');
      expect(result, 'Name is too short, use at least 3 characters');
    });

    test('Too Long PlaceName Test', () {
      result = validationHelper.validatePlaceName('PmsYCwqJsBb4Oww8XeF2zBwhl8zWDwT45rdEWY63zsq56l2RYiS');
      expect(result, 'Name is too long, use at most 50 characters');
    });

    test('Valid PlaceName test', () {
      result = validationHelper.validatePlaceName('Wonderful Place');
      expect(result, null);
    });
  });


  group('Locked Description Validator', () {
    test('Null Locked description Test', () {
      result = validationHelper.validateLockedDescr(null);
      expect(result, 'Locked description is required');
    });

    test('Empty Locked description Test 1', () {
      result = validationHelper.validateLockedDescr('');
      expect(result, 'Locked description is required');
    });

    test('Empty Locked description Test 2', () {
      result = validationHelper.validateLockedDescr('                     ');
      expect(result, 'Locked description is required');
    });

    test('Too Long Locked description Test', () {
      result = validationHelper.validateLockedDescr('aFBi5897lraSN9V8RTmFbcv4Nr6Ew6AU8wNo8KjTGZb4kaB3wAmMXcvx1bsbQZ2h4M15FAaTOpw1jvCgi2aubHDJQwczEWUCdW1Yhc0s8qAwg3kQ73M4DbINElDeZgVpzIO088OTOKjHsZKwEGbNiZs');
      expect(result, 'Locked description is too long, use at most 150 characters');
    });

    test('Valid Locked description test', () {
      result = validationHelper.validateLockedDescr('a wonderful place');
      expect(result, null);
    });
  });


  group('Unlocked Description Validator', () {
    test('Null Unlocked description Test', () {
      result = validationHelper.validateUnlockedDescr(null);
      expect(result, 'Unlocked description is required');
    });

    test('Empty Unlocked description Test 1', () {
      result = validationHelper.validateUnlockedDescr('');
      expect(result, 'Unlocked description is required');
    });

    test('Empty Unlocked description Test 2', () {
      result = validationHelper.validateUnlockedDescr('                     ');
      expect(result, 'Unlocked description is required');
    });

    test('Too Long Unlocked description Test', () {
      result = validationHelper.validateUnlockedDescr('xduCNP78JBQshjPewEEVQcAgJkXFnkKB1Ti2klwz4VI12INza5JFE7FnSL2MJSxorDrVsmRqEiSH0R5IWyhqo1yleJpe0ASN7bNfqYpphhNnimQeL1WRdMIDQYdSciouoDWUrrppd8RfWoF0XqcO5gcXDf9coLqE3LjNw4fiNOP3HCD1IT7HUf8wybMxb5LRPU4xr3PQdbVjkBuzdBnvV52JRLEd61tvmFlVBBcHYOGPEiVdTDxqdH7vCF1xwGRhtiUDr856eyuu9eSaumaXd41Vgsoe7o6smA1TjVARbzutMXa6MJ7B0iDk0ZVM9g9FUZKZRyqYwbq72JTTnlNbvFrIg5LUw6K6GkfOa6aaRhE34mPJAd1nBpWtCMKT7EjOwjwCxUmjA1ge7wSLB02IyV8CIX6OfzxMhFn9EPDCCMDhjUQUpMQkpH1HHIrnNpENUpfyVsZjQIIvMpBLLV0ZZA3cje5GmSBx61r9gxKpVgfYeKOQPkP50');
      expect(result, 'Unlocked description is too long, use at most 500 characters');
    });

    test('Valid Unlocked description test', () {
      result = validationHelper.validateUnlockedDescr('a wonderful place');
      expect(result, null);
    });
  });

}