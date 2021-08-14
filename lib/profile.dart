import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;
final userId = FirebaseAuth.instance.currentUser!.uid;

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Profile';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Image.asset('assets/images/open-lock.png', height: 30),
              title: Text('Unlocked Places'),
              onTap: () {_showUnlockedPlaces();},
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              title: Text('Album'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showUnlockedPlaces() {
    Stream<QuerySnapshot> _places = db.collection('places').orderBy('name').snapshots();
    Stream<QuerySnapshot> _unlockedPlaces = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .snapshots();

    var tiles = <Widget>[];


    return ListView(
      children: tiles
    );
  }
}