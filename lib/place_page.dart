import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Map<String, Color> categoryColors = {};

/*
class PlaceData {
  late String id;
  late String name;
  late List<String> categories;  // tags

  late String descriptionUnlocked;
  late String descriptionLocked;

  late String imagePathUnlocked;
  //late String imagePathLocked;

  late String address;
  late double latitude;
  late double longitude;
  late int likes;
  late int dislikes;
  /*
  const PlaceData({
    required this.id,
    required this.name,
    required this.categories,
    required this.descriptionLocked,
    required this.descriptionUnlocked,
    required this.imagePathLocked,
    required this.imagePathUnlocked,
    required this.address,
    required this.latitude,
    required this.longitude
  });*/

  //final DocumentSnapshot document;

  PlaceData(DocumentSnapshot document) {
    this.id = document.id;
    this.name = document['name'] as String;
    this.categories = document['categories'] as List<String>;
    this.descriptionLocked = document['lockedDescr'] as String;
    this.descriptionUnlocked = document['unlockedDescr'] as String;
    this.latitude = document['location'].latitude as double;
    this.longitude = document['location'].longitude as double;
    this.imagePathUnlocked = document['imgpath'] as String;
    this.likes = document['likes'] as int;
    this.dislikes = document['dislikes'] as int;
  }

  // Proof of Concept:
  // non-const attributes fetch their value every time.
  // As a result, they are always up-to-date (eventually some cache management if costly).

  int likes() {
    // return db.query("places", this.id, "numLikes");
    return 4;
  }

  int dislikes() {
    return 1;
  }


}*/

class PlacePage extends StatefulWidget {
  //final DocumentSnapshot document;

  late String id;
  late String name;
  late List categories; // tags

  late String descriptionUnlocked;
  late String descriptionLocked;

  late String imagePathUnlocked;
  late String imagePathLocked;

  late Map<String, dynamic> address;
  late double latitude;
  late double longitude;
  late int likes;
  late int dislikes;

  PlacePage(DocumentSnapshot document, {Key? key}) {
    this.id = document.id;
    this.name = document['name'] as String;
    this.address = document['address'] as Map<String, dynamic>;
    this.categories = document['categories'] as List;
    this.descriptionLocked = document['lockedDescr'] as String;
    this.descriptionUnlocked = document['unlockedDescr'] as String;
    this.latitude = document['location'].latitude as double;
    this.longitude = document['location'].longitude as double;
    this.imagePathUnlocked = document['imgpath'] as String;
    this.imagePathLocked = 'PathLocked';
    this.likes = document['likes'] as int;
    this.dislikes = document['dislikes'] as int;
  }

  /*
  const PlacePage({
    Key? key,
    required this.placeData,
  }): super(key: key);*/

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  bool _isLocked = true;
  bool _isLiked = false;
  bool _isDisliked = false;


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    //PlaceData placeData = widget.placeData;

    String imagePath;
    String description;

    if (_isLocked) {
      imagePath = widget.imagePathLocked;
      description = widget.descriptionLocked;
    } else {
      imagePath = widget.imagePathUnlocked;
      description = widget.descriptionUnlocked;
    }

    Icon likeIcon = Icon(Icons.arrow_drop_up,
        color: _isLiked ? Colors.green[600] : Colors.grey[400]);
    Icon dislikeIcon = Icon(Icons.arrow_drop_down,
        color: _isDisliked ? Colors.red[600] : Colors.grey[400]);

    // Tags boxes
    List<Widget> tags = [];
    for (int i = 0; i < widget.categories.length; i++) {
      tags.add(Container(
        margin: EdgeInsets.only(right: 6.0),
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
        child: Text(widget.categories[i] as String,
            style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        decoration: BoxDecoration(
          color: categoryColors[widget.categories[i]] ?? Colors.blue[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
      ));
    }

    // Topbar (arrow back to prev page)
    Widget topbar = Container(
      margin: EdgeInsets.only(top: 20.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 56.0,
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          Spacer(),
          // other icons...
        ],
      ),
    );

    // Content
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Sep
        SizedBox(height: 8.0),
        // Image
        Stack(
          children: <Widget>[
            ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black, Colors.transparent],
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Image.asset(imagePath, fit: BoxFit.cover),
              // child: Container(
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage(imagePath),
              //       fit: BoxFit.cover,
              //       colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              //     ),
              //   ),
              // ),
            ),
            topbar,
          ],
        ),
        // Pad
        Padding(
          padding: EdgeInsets.only(top: 4.0, left: 32.0, right: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Below Image: Like/Dislike and Category tags
              Row(
                children: <Widget>[
                  // Like Dislike stats
                  GestureDetector(onTap: like, child: likeIcon),
                  Text((widget.likes + (_isLiked ? 1 : 0)).toString(),
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.green[600])),
                  SizedBox(width: 4.0),
                  GestureDetector(onTap: dislike, child: dislikeIcon),
                  Text(
                      (widget.dislikes + (_isDisliked ? 1 : 0)).toString(),
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.red[600])),
                  // Sep
                  Spacer(),
                  // Category tags
                  Row(children: tags),
                ],
              ),
              // Sep
              SizedBox(height: 12.0),
              // Name
              Text(widget.name,
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900)),
              // Sep
              SizedBox(height: 4.0),
              // Address
              Text(widget.address['street'] as String, style: TextStyle(fontSize: 14.0)),
              // Sep
              SizedBox(height: 4.0),
              // Distance
              Text(distanceKm().toStringAsFixed(2) + ' km',
                  style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black45)),
              // Sep
              SizedBox(height: 8.0),
              // Description
              Text(description, style: TextStyle(fontSize: 12.0)),
              // Sep
              SizedBox(height: 32.0),
            ],
          ),
        ),
      ],
    );

    return Scaffold(body: SingleChildScrollView(child: content));
  }

  void unlock() {
    setState(() {
      _isLocked = false;
    });
  }

  void like() {
    setState(() {
      _isLiked = !_isLiked;
      _isDisliked = false;
      // backend num likes/dislikes update
      // ...
    });
  }

  void dislike() {
    setState(() {
      _isDisliked = !_isDisliked;
      _isLiked = false;
      // backend num likes/dislikes update
      // ...
    });
  }

  double distanceKm() {
    // userId = backend.getCurUserId();
    // var (userLat, userLong) = db.query("users", user.id, "curCoords");
    // return api.distance(userLat, userLong, latitude, longitude);
    return 1.425623;  // to be rounded and string-formatted
  }


}
