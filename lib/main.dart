import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/explore/explore.dart';
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
      builder: OneContext().builder,
      title: 'Hunt Your Picture',
      home: Scaffold(
        //appBar: AppBar(),
        // body: BottomNavContainer(),
        body: LoginPage(),
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueAccent[50],
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String title = 'title';
  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }

}

