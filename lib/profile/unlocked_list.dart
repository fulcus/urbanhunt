
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:hunt_app/explore/place_card.dart';
import 'package:hunt_app/utils/image_helper.dart';
import 'package:rxdart/rxdart.dart';

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
        child: StreamBuilder<QuerySnapshot>(
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
          ),
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
  late Stream<List<PlaceData>> _myUnlockedPlaces;

  @override
  void initState() {
    super.initState();
    _myUnlockedPlaces = filteredList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaceData>>(
        stream: _myUnlockedPlaces,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              height: 660,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var currUlkPlace = snapshot.data![index];
                    return UnlockedListRow(
                        currUlkPlace,
                        widget.unlocked[index].get('liked') as bool,
                        widget.unlocked[index].get('disliked') as bool,
                        widget.unlocked[index].get('unlockDate') as Timestamp,
                        currUlkPlace.city,
                        currUlkPlace.country,
                        currUlkPlace.street,
                        currUlkPlace.imageURL,
                        currUlkPlace.name,
                    );
                  }
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
    );
  }

  List<List<String>> _getChunks() {
    var len = widget.list.length;
    var size = 10;
    var chunks = <List<String>>[];

    for(var i = 0; i< len; i+= size)
    {
      var end = (i+size<len)?i+size:len;
      chunks.add(widget.list.sublist(i, end));
    }
    return chunks;
  }

  Stream<List<PlaceData>> filteredList() {
    var chunks = _getChunks();

    List<Stream<QuerySnapshot>> combineList = [];
    for (var i = 0; i < chunks.length; i++) {
      combineList.add(db.collection('places').where(FieldPath.documentId, whereIn: chunks[i]).snapshots());
    } //get a list of the streams, which will have 10 each.

    CombineLatestStream<QuerySnapshot, List<QuerySnapshot>> mergedQuerySnapshot = CombineLatestStream.list(combineList);
    //now we combine all the streams....but it'll be a list of QuerySnapshots.

    //and you'll want to look closely at the map, as it iterates, consolidates and returns as a single stream of List<AttendeeData>
    return mergedQuerySnapshot.map(listFromDocumentSnapshot);
  }

  List<PlaceData> listFromDocumentSnapshot(List<QuerySnapshot> snapshot) {
    List<PlaceData> listToReturn = [];
    for (var element in snapshot) {
      listToReturn.addAll(element.docs.map((doc) {
        return PlaceData.fromSnapshot(doc);
      }));
    }
    return listToReturn;
  }

}


class UnlockedListRow extends StatelessWidget {
  final PlaceData place;
  final bool isLiked;
  final bool isDisliked;
  final Timestamp unlockDate;
  final String city;
  final String country;
  final String street;
  final String imgPath;
  final String name;

  UnlockedListRow (
      this.place,
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
                  color: Colors.indigo[200]!,
                  width: 2.0,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16.0)),
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
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
            MaterialPageRoute<void>(builder: (context) => PlaceCard(place, false, isLiked, isDisliked, _onCardClose, unlockDate, fullscreen: true))),
      ),
    );
  }


}