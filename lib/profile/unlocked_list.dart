
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/explore/place_card.dart';
import 'package:hunt_app/utils/image_helper.dart';

final db = FirebaseFirestore.instance;


class UnlockedList extends StatefulWidget {
  @override
  _UnlockedListState createState() => _UnlockedListState();
}

class _UnlockedListState extends State<UnlockedList> {
  late Stream<QuerySnapshot> _unlockedPlaces;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    _unlockedPlaces = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My unlocked places')),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
            children: <Widget> [
              StreamBuilder<QuerySnapshot>(
                  stream: _unlockedPlaces,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if(snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: Text(
                            'You have not unlocked any place yet.\nGet to work!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        );
                      }
                      else {
                        var placeIds = <String>[];

                        for(var i in snapshot.data!.docs) {
                          placeIds.add(i.id);
                        }
                        return Helper(placeIds, snapshot.data!.docs);
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
            ]
        ),
      )
    );
  }
}


class Helper extends StatefulWidget {
  final List<String> list;
  final List<DocumentSnapshot> unlocked;

  Helper(
      this.list,
      this.unlocked,
      {Key? key}) : super(key: key);

  @override
  _HelperState createState() => _HelperState();
}

class _HelperState extends State<Helper> {
  late Stream<QuerySnapshot> _myUnlockedPlaces;

  @override
  void initState() {
    super.initState();

    _myUnlockedPlaces = db
        .collection('places')
        //.orderBy('address.city')
        .where(FieldPath.documentId, whereIn: widget.list)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: StreamBuilder<QuerySnapshot>(
          stream: _myUnlockedPlaces,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var currUlkPlace = snapshot.data!.docs[index];
                    return UnlockedListRow(
                        currUlkPlace,
                        widget.unlocked[index].get('liked') as bool,
                        widget.unlocked[index].get('disliked') as bool,
                        widget.unlocked[index].get('unlockDate') as Timestamp,
                        currUlkPlace.get('address.city').toString(),
                        currUlkPlace.get('address.country').toString(),
                        currUlkPlace.get('address.street').toString(),
                        currUlkPlace.get('imgpath').toString(),
                        currUlkPlace.get('name').toString()
                    );
                  }
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
    );
  }
}


class UnlockedListRow extends StatelessWidget {
  final DocumentSnapshot doc;
  final bool isLiked;
  final bool isDisliked;
  final Timestamp unlockDate;
  final String city;
  final String country;
  final String street;
  final String imgPath;
  final String name;

  UnlockedListRow (
      this.doc,
      this.isLiked,
      this.isDisliked,
      this.unlockDate,
      this.city,
      this.country,
      this.street,
      this.imgPath,
      this.name,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    void _onCardClose() {
      Navigator.pop(context,
          MaterialPageRoute<void>(builder: (context) => UnlockedList()));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.blue,
                  width: 3.0,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(50.0)),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: ImageHelper().showImage(imgPath, 'assets/images/open-lock.png'),
                                        fit: BoxFit.cover)))),
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
                            child: Text(
                              name,
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w500),
                              maxLines: 2,
                            )
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
                        child: Text(
                          city+' ('+country+')',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Icon(Icons.vpn_key, color: Colors.amber)
                    ]),
                  )
                ],
              ),
            ],
          ),
        ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (context) => PlaceCard(doc, false, isLiked, isDisliked, _onCardClose, unlockDate, fullscreen: true))),
      ),
    );
  }


}