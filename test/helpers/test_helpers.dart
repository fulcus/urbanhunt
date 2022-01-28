import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Firebase])
void main() {
  //var firebase = MockFirebase();
}

typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': <String, dynamic>{},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return [
        <String, dynamic>{
          'name': call.arguments['appName'],
          'options': call.arguments['options'],
          'pluginConstants': <String, dynamic>{},
        }
      ];
    }

    if (customHandlers != null) {
      customHandlers(call);
    }

    return null;
  });
}

Future<T> neverEndingFuture<T>() async {
  // ignore: literal_only_boolean_expressions
  while (true) {
    await Future<T>.delayed(const Duration(minutes: 5));
  }
}
