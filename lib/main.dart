import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //_portraitModeOnly();
    return MaterialApp(
      title: 'UrbanHunt',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        primarySwatch: Colors.indigo,
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

