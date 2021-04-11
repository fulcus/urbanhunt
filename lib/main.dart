import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './auth.dart';
import './counter.dart';
import './home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hunt Your Picture',
      //home: CounterHome(title: 'Counter'),
      //home: const HomePage(title: 'Hunt App'),
      home: Scaffold(
        body: AuthTypeSelector(),
      ),
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.greenAccent[50],
      ),
    );
  }
}
