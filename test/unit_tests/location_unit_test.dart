import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/explore/explore.dart';

import '../helpers/test_helpers.dart';


void main() {
  // TestWidgetsFlutterBinding.ensureInitialized(); Gets called in setupFirebaseAuthMocks()
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('if widget.someParam is empty, do something', () {
    var widget = Explore();
    final element = widget.createElement(); // this will set state.widget
    final state = element.state as ExploreState; // ExploreState is @visibleForTesting
    expect(state.determinePosition(), 0);
  });
}
