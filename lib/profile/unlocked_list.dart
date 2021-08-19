
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/profile/profile.dart';

final db = FirebaseFirestore.instance;
final userId = FirebaseAuth.instance.currentUser!.uid;


class UnlockedList extends StatefulWidget {
  @override
  _UnlockedListState createState() => _UnlockedListState();
}

class _UnlockedListState extends State<UnlockedList> {
  late Stream<QuerySnapshot> _unlockedPlaces;
  late Stream<QuerySnapshot> _myUnlockedPlaces;

  @override
  void initState() {
    super.initState();

    _unlockedPlaces = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .snapshots();

    //TODO check if it works
    _myUnlockedPlaces = db
        .collection('places')
        .where(FieldPath.documentId, arrayContains: _unlockedPlaces)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            body: Container(
              margin: EdgeInsets.only(top: 65.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.grey,
                        size: 18.0,
                      ),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute<void>(builder: (context) => Profile())),
                    ),

                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15.0, top: 10.0),
                    child: RichText(
                        text: TextSpan(
                            text: "Unlocked",
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: "Places",
                                  style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold))
                            ])),
                  ),
                  Flexible(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: _unlockedPlaces,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var currListUser = snapshot.data!.docs[index];
                                    QueryDocumentSnapshot prevListUser;
                                    print(index);

                                    if(snapshot.data!.docs.isEmpty) {
                                      return Center(
                                        child: Text('You have not unlocked any place yet. Get to work!')
                                      );
                                    }
                                    else {
                                      return UnlockedListRow("ciao");
                                    }
                                  });
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }))
                ],
              ),
            )),
      ],
    );
  }
}

class UnlockedListRow extends StatelessWidget {
  final String imagePath;

  UnlockedListRow (
      this.imagePath,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.blueAccent,
                  width: 3.0,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(50.0)),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: getImage(imagePath),
                                        fit: BoxFit.fill)))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.centerLeft,
                            /*child: Text(
                              username,
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w500),
                              maxLines: 2,
                            )*/
                        )
                      ],
                    ),
                  ),
                  Flexible(child: Container()),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        /*child: Text(
                          score,
                          style: TextStyle(fontSize: 21),
                        ),*/
                      ),
                      Icon(Icons.vpn_key, color: Colors.amber)
                    ]),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider getImage(String url) {
    ImageProvider imageProvider = AssetImage('assets/images/open-lock.png');
    if (url != '') {
      imageProvider = NetworkImage(url);
    }
    return imageProvider;
  }

}