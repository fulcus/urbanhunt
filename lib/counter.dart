import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class GetData extends StatelessWidget {
  final String documentId = 'VXnmELXoSf8M4PkzHPRu';

  @override
  Widget build(BuildContext context) {
    CollectionReference places = db.collection('places');

    return FutureBuilder<DocumentSnapshot>(
      future: places.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data()!;
          return Text("Data: ${data['name']}");
        }

        return Text("loading");
      },
    );
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
        "Unlock Place",
      ),
    );
  }

  Future<void> _unlockPlace() async {
    var place = await db.collection('places').doc(placeId).get();
    var unlockedPlaces =
        await db.collection('users').doc(userId).collection('unlockedPlaces');
    Map<String, dynamic>? data = place.data();
    print("place unlocked");

    return unlockedPlaces.doc(placeId).set(data!);
  }
}

class LikePlace extends StatelessWidget {
  final String placeId = 'VXnmELXoSf8M4PkzHPRu'; //get from selected card
  final String userId = 'Kd5combpKoh1gLYyYUyftiAwcbP2'; //get from auth

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called users that references the firestore collection

    return TextButton(
      onPressed: _likePlace,
      child: Text(
        "Like Place",
      ),
    );
  }

  // see https://firebase.flutter.dev/docs/firestore/usage/#transactions
  Future<void> _likePlace() async {
    // Create a reference to the document the transaction will use
    var documentReference = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(placeId);

    return db
        .runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);

      if (!snapshot.exists) {
        throw Exception("Place does not exist!");
      }
      // TODO: should also update places collection
      int newLikesCount = snapshot.data()!['likes'] + 1 as int;

      var data = <String, dynamic>{'likes': newLikesCount};
      transaction.update(documentReference, data);

      return newLikesCount;
    })
        .then((value) => print("Likes count updated to $value"))
        .catchError(
            (Error error) => print('Failed to update likes: $error'));
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
            GetData(),
            UnlockPlace(),
            LikePlace(),
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
