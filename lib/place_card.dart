import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Map<String, Color> categoryColors = {};
final db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;
final userId = FirebaseAuth.instance.currentUser!.uid;

class PlacePage extends StatefulWidget {
  late DocumentSnapshot document;

  late String placeId;
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

  PlacePage(DocumentSnapshot document, {Key? key}) : super(key: key) {
    this.document = document;
    placeId = document.id;
    name = document['name'] as String;
    address = document['address'] as Map<String, dynamic>;
    categories = document['categories'] as List;
    descriptionLocked = document['lockedDescr'] as String;
    descriptionUnlocked = document['unlockedDescr'] as String;
    latitude = document['location'].latitude as double;
    longitude = document['location'].longitude as double;
    imagePathUnlocked = document['imgpath'] as String;
    imagePathLocked = 'PathLocked';
    likes = document['likes'] as int;
    dislikes = document['dislikes'] as int;
  }

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
                  Text((widget.dislikes + (_isDisliked ? 1 : 0)).toString(),
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
              MyButton(latitude: widget.latitude, longitude: widget.longitude),
              // Sep
              SizedBox(height: 4.0),
              // Address
              Text(widget.address['street'] as String,
                  style: TextStyle(fontSize: 14.0)),
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

  // todo check if db calls are successful

  void like() {
    setState(() {
      if (!_isLiked && !_isDisliked) {
        _dbUpdateLikes(1);
      } else if (_isLiked && !_isDisliked) {
        _dbUpdateLikes(-1);
      } else if (!_isLiked && _isDisliked) {
        __dbSwapLikeDislike(false);
      }

      _isLiked = !_isLiked;
      _isDisliked = false;
    });
  }

  void dislike() {
    setState(() {
      if (!_isLiked && !_isDisliked) {
        _dbUpdateDislikes(1);
      } else if (_isLiked && !_isDisliked) {
        __dbSwapLikeDislike(true);
      } else if (!_isLiked && _isDisliked) {
        _dbUpdateDislikes(-1);
      }

      _isDisliked = !_isDisliked;
      _isLiked = false;
    });
  }

  // see https://firebase.flutter.dev/docs/firestore/usage/#transactions
  // @param like, if true likes, false unlikes
  Future<void> _dbUpdateLikes(int likesIncrement) async {
    bool liked = likesIncrement > 0 ? true : false;

    var placeRef = db.collection('places').doc(widget.placeId);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(widget.placeId);

    return db
        .runTransaction((transaction) async {
          var placeSnapshot = await transaction.get(placeRef);
          var unlockedPlaceSnapshot = await transaction.get(unlockedPlaceRef);

          if (!placeSnapshot.exists || !unlockedPlaceSnapshot.exists) {
            throw Exception('Place does not exist!');
          }
          var newLikesCount =
              placeSnapshot.data()!['likes'] + likesIncrement as int;

          transaction
              .update(placeRef, <String, dynamic>{'likes': newLikesCount});
          transaction
              .update(unlockedPlaceRef, <String, dynamic>{'liked': liked});

          return newLikesCount;
        })
        .then((value) => print('Likes count updated to $value'))
        .catchError((Error error) => print('Failed to update likes: $error'));
  }

  Future<void> _dbUpdateDislikes(int dislikesIncrement) async {
    bool disliked = dislikesIncrement > 0 ? true : false;

    var placeRef = db.collection('places').doc(widget.placeId);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(widget.placeId);

    return db
        .runTransaction((transaction) async {
          var placeSnapshot = await transaction.get(placeRef);
          var unlockedPlaceSnapshot = await transaction.get(unlockedPlaceRef);

          if (!placeSnapshot.exists || !unlockedPlaceSnapshot.exists) {
            throw Exception('Place does not exist!');
          }
          var newDislikesCount =
              placeSnapshot.data()!['dislikes'] + dislikesIncrement as int;

          transaction.update(
              placeRef, <String, dynamic>{'dislikes': newDislikesCount});
          transaction.update(
              unlockedPlaceRef, <String, dynamic>{'disliked': disliked});

          return newDislikesCount;
        })
        .then((value) => print('Dislikes count updated to $value'))
        .catchError(
            (Error error) => print('Failed to update dislikes: $error'));
  }

  // @param fromLikeToDislike == true : add dislike and remove like and vice versa
  Future<void> __dbSwapLikeDislike(bool fromLikeToDislike) async {
    int likesUpdate = fromLikeToDislike ? -1 : 1;
    int dislikesUpdate = fromLikeToDislike ? 1 : -1;

    var placeRef = db.collection('places').doc(widget.placeId);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(widget.placeId);

    return db
        .runTransaction((transaction) async {
          var placeSnapshot = await transaction.get(placeRef);
          var unlockedPlaceSnapshot = await transaction.get(unlockedPlaceRef);

          if (!placeSnapshot.exists || !unlockedPlaceSnapshot.exists) {
            throw Exception('Place does not exist!');
          }
          var newLikesCount =
              placeSnapshot.data()!['likes'] + likesUpdate as int;
          var newDislikesCount =
              placeSnapshot.data()!['dislikes'] + dislikesUpdate as int;

          transaction
              .update(placeRef, <String, dynamic>{'likes': newLikesCount});
          transaction.update(
              unlockedPlaceRef, <String, dynamic>{'liked': !fromLikeToDislike});
          transaction.update(
              placeRef, <String, dynamic>{'dislikes': newDislikesCount});
          transaction.update(unlockedPlaceRef,
              <String, dynamic>{'disliked': fromLikeToDislike});

          return newLikesCount;
        })
        .then((value) => print('Dislikes count updated to $value'))
        .catchError(
            (Error error) => print('Failed to update dislikes: $error'));
  }

  Future<void> _dbUnlockPlace() async {
    /*
    All places have actually been already downloaded, so not need to get it again.
    Only need to update UI with new info and write "unlocking" to db.
     */
    var unlockedPlaces =
        db.collection('users').doc(userId).collection('unlockedPlaces');
    var data = <String, dynamic>{'liked': false, 'disliked': false};

    return await unlockedPlaces.doc(widget.placeId).set(data);
  }

  double distanceKm() {
    // userId = backend.getCurUserId();
    // var (userLat, userLong) = db.query("users", user.id, "curCoords");
    // return api.distance(userLat, userLong, latitude, longitude);
    return 1.425623; // to be rounded and string-formatted
  }
}

class MyButton extends StatelessWidget {

  const MyButton({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    // The GestureDetector wraps the button.
    return GestureDetector(
      // When the child is tapped, show a snackbar.
      onTap: () {
        openMap(latitude, longitude);
      },
      // The custom button
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text('Google Maps'),
      ),
    );
  }

  //Function to be called when the user wants to open the selected place in Google Maps.
  //Arguments -> latitude and longitude of the place
  static Future<void> openMap(double latitude, double longitude) async {
    var googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
