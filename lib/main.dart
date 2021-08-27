import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/contribute/form.dart';
import 'package:hunt_app/leaderboard.dart';
import 'package:hunt_app/profile/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'explore/explore.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanHunt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: redirectHomeOrLogin(),
      initialRoute: '/',
      routes: {
        //todo capire che sono ste cose e se servono
        // When navigating to the "/" route, build the FirstScreen widget.
        '/first': (context) => Contribute(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => LeaderBoard(),
      },
    );
  }
}

