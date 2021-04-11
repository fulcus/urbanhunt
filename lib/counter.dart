import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class AddPlace extends StatelessWidget {
  final String placeId = 'VXnmELXoSf8M4PkzHPRu'; //get from selected card
  final String userId = 'Kd5combpKoh1gLYyYUyftiAwcbP2'; //get from auth

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _addPlace,
      child: Text(
        'Add Place',
      ),
    );
  }

  Future<void> _addPlace() async {
    int zip = 20100, dislikes = 0, likes = 0;
    double latitude = 45.485044, longitude = 9.202816;

    var city = 'Milan',
        state = 'Italy',
        street = 'Piazza Duca d\'Aosta, 1',
        imgpath = 'images/secret_door',
        lockedDescr = 'Some interesting facts',
        unlockedDescr = 'Less interesting facts',
        name = 'Secret Door',
        location = GeoPoint(latitude, longitude);
    var categories = ['culture'];

    var places = db.collection('places');
    var data = <String, dynamic>{
      'address': {'zip': zip, 'city': city, 'state': state, 'street': street},
      'categories': categories,
      'imgpath': imgpath,
      'lockedDescr': lockedDescr,
      'unlockedDescr': unlockedDescr,
      'name': name,
      'dislikes': dislikes,
      'location': location,
      'likes': likes
    };

    await places.add(data);
  }
}

class UnlockPlace extends StatelessWidget {
  final String placeId = 'VXnmELXoSf8M4PkzHPRu'; //get from selected card
  final String userId = 'Kd5combpKoh1gLYyYUyftiAwcbP2'; //get from auth

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _unlockPlace,
      child: Text(
        'Unlock Place',
      ),
    );
  }

  Future<void> _unlockPlace() async {
    /*
    All places have actually been already downloaded, so not need to get it again.
    Only need to update UI with new info and write "unlocking" to db.
     */
    var unlockedPlaces =
        db.collection('users').doc(userId).collection('unlockedPlaces');
    var data = <String, dynamic>{'liked': false, 'disliked': false};

    return await unlockedPlaces.doc(placeId).set(data);
  }
}

class LikePlace extends StatelessWidget {
  final String placeId = 'VXnmELXoSf8M4PkzHPRu'; //get from selected card
  final String userId = 'Kd5combpKoh1gLYyYUyftiAwcbP2'; //get from auth

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _like,
      child: Text(
        'Like Place',
      ),
    );
  }

/*  Future<void> _like() async {
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(placeId);

    var data = <String, dynamic>{'liked': true, 'disliked': false};

    return await unlockedPlaceRef.update(data);
  }*/

  //TODO: checks on like and dislike: like only if not already liked, if liked after disliked set dislike false ecc
  // see https://firebase.flutter.dev/docs/firestore/usage/#transactions
  Future<void> _like() async {
    var placeRef = db.collection('places').doc(placeId);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(placeId);

    return db
        .runTransaction((transaction) async {
          var placeSnapshot = await transaction.get(placeRef);
          var unlockedPlaceSnapshot = await transaction.get(unlockedPlaceRef);

          if (!placeSnapshot.exists || !unlockedPlaceSnapshot.exists) {
            throw Exception('Place does not exist!');
          }
          var newLikesCount = placeSnapshot.data()!['likes'] + 1 as int;

          transaction.update(
              placeRef, <String, dynamic>{'likes': newLikesCount}); //likes++
          transaction.update(unlockedPlaceRef,
              <String, dynamic>{'liked': true}); //liked == true

          return newLikesCount;
        })
        .then((value) => print('Likes count updated to $value'))
        .catchError((Error error) => print('Failed to update likes: $error'));
  }
}

class DislikePlace extends StatelessWidget {
  final String placeId = 'VXnmELXoSf8M4PkzHPRu'; //get from selected card
  final String userId = 'Kd5combpKoh1gLYyYUyftiAwcbP2'; //get from auth

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: _dislike,
        child: Text(
          'Dislike Place',
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.pressed)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.5);
              }
              return Colors.red.shade50; // Use the component's default.
            },
          ),
        ));
  }

  Future<void> _dislike() async {
    var placeRef = db.collection('places').doc(placeId);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(placeId);

    return db
        .runTransaction((transaction) async {
          var placeSnapshot = await transaction.get(placeRef);
          var unlockedPlaceSnapshot = await transaction.get(unlockedPlaceRef);

          if (!placeSnapshot.exists || !unlockedPlaceSnapshot.exists) {
            throw Exception('Place does not exist!');
          }
          var newLikesCount = placeSnapshot.data()!['dislikes'] + 1 as int;

          transaction.update(
              placeRef, <String, dynamic>{'dislikes': newLikesCount}); //likes++
          transaction.update(unlockedPlaceRef,
              <String, dynamic>{'disliked': true}); //liked == true

          return newLikesCount;
        })
        .then((value) => print('Dislikes count updated to $value'))
        .catchError(
            (Error error) => print('Failed to update dislikes: $error'));
  }
}

class GetData extends StatelessWidget {
  final String documentId = 'VXnmELXoSf8M4PkzHPRu';

  @override
  Widget build(BuildContext context) {
    var places = db.collection('places');

    return FutureBuilder<DocumentSnapshot>(
      future: places.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data()!;
          return Text("Data: ${data}");
        }
        return Text('loading...');
      },
    );
  }
}

class CounterHome extends StatefulWidget {
  CounterHome({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CounterHomeState createState() => _CounterHomeState();
}

class _CounterHomeState extends State<CounterHome> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //GetData(),
            AddPlace(),
            UnlockPlace(),
            LikePlace(),
            DislikePlace(),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
