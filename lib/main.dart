import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

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
      builder: OneContext().builder, // needed?
      title: 'UrbanHunt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: redirectHomeOrLogin(),
      // initialRoute: '/',
      // routes: {
      //   // When navigating to the "/" route, build the FirstScreen widget.
      //   '/first': (context) => Contribute(),
      //   // When navigating to the "/second" route, build the SecondScreen widget.
      //   '/second': (context) => LeaderBoard(),
      // },
    );
  }
}

