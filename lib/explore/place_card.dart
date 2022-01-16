import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Unlock distance threshold
const double UNLOCK_RANGE_METERS = 15.0;

//TODO probably they need to be local variable for testing purposes
// Firebase db instance
final db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;

// Map category tag to its color
final Map<String, Color> categoryColors = {};

class PlaceCard extends StatefulWidget {
  // new card should be created for each place
  // isLocked, isLiked, isDisliked are actually part of state

  DocumentSnapshot document;
  PlaceData place;
  bool fullscreen, isLocked, isLiked, isDisliked;
  late void Function() onCardClose;

  PlaceCard(this.document, this.isLocked, this.isLiked, this.isDisliked,
      this.onCardClose,
      {this.fullscreen = false, Key? key})
      : place = PlaceData.fromSnapshot(document),
        super(key: key);

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String _displayDistance = '';
  bool _isGPSon = false;

  _PlaceCardState();

  @override
  void initState() {
    super.initState();
    _checkGPS().then((isGPSon) {
      if (isGPSon) {
        _displayDist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String description;
    Widget imageBanner;

    if (_isGPSon) {
      _displayDist();
    } else {
      print('GPS off');
    }

    if (widget.isLocked) {
      description = widget.place.lockedDescription;
      imageBanner = imageBannerLocked();
    } else {
      description = widget.place.unlockedDescription;
      imageBanner = imageBannerUnlocked();
    }

    var likeOn = widget.isLiked ? Colors.green[600] : Colors.grey[400];
    var dislikeOn = widget.isDisliked ? Colors.red[600] : Colors.grey[400];

    var likeIcon = Icon(Icons.thumb_up_alt, size: 20.0, color: likeOn);
    var dislikeIcon = Icon(Icons.thumb_down_alt, size: 20.0, color: dislikeOn);

    // Content
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // scroll hint and close button
        topBar(),
        // Image
        imageBanner,
        // Below Image: Place info
        Padding(
          padding: EdgeInsets.only(top: 8.0, left: 32.0, right: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Like/Dislike and Category tags
              Row(
                children: <Widget>[
                  // Like Dislike stats
                  GestureDetector(onTap: like, child: likeIcon),
                  SizedBox(width: 4.0),
                  Text(
                    (widget.place.likes + (widget.isLiked ? 1 : 0)).toString(),
                    style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600]),
                  ),
                  SizedBox(width: 16.0),
                  GestureDetector(onTap: dislike, child: dislikeIcon),
                  SizedBox(width: 4.0),
                  Text(
                    (widget.place.dislikes + (widget.isDisliked ? 1 : 0))
                        .toString(),
                    style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600]),
                  ),
                  // Sep
                  Spacer(),
                  // Category tags
                  Row(children: categoriesTags()),
                ],
              ),
              // Sep
              SizedBox(height: 6.0),
              Row(
                children: [
                  Column(children: [
                    // Open directions in Google Maps
                    GmapButton(
                      latitude: widget.place.latitude,
                      longitude: widget.place.longitude,
                    )
                  ]),
                  SizedBox(width: 30.0),
                  Column(children: [
                    // Share GPS position with a friend
                    ShareButton(
                      latitude: widget.place.latitude,
                      longitude: widget.place.longitude,
                    )
                  ])
                ],
              ),
              // Sep
              SizedBox(height: 6.0),
              // Name
              Text(
                widget.place.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              // Sep
              SizedBox(height: 4.0),
              // Address
              Text(
                widget.place.street+' - '+ widget.place.city+' ('+ widget.place.country+')',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              // Sep
              SizedBox(height: 4.0),
              // Distance
              if (_isGPSon)
                Text(
                  _displayDistance,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.black45,
                  ),
                ),
              SizedBox(height: 4.0),
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

    if (widget.fullscreen) {
      return Scaffold(
        appBar: AppBar(title: Text('Unlocked Place')),
        body: Material(
          elevation: 10,
          shadowColor: Colors.black,
          child: content,
        ),
      );
    } else {
      return DraggableScrollableSheet(
        minChildSize: 0.44,
        initialChildSize: 0.44,
        builder: (context, scrollController) {
          return Material(
            elevation: 10,
            shadowColor: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            child: SingleChildScrollView(
              controller: scrollController,
              child: content,
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _checkGPS() async {
    _isGPSon = await Geolocator.isLocationServiceEnabled();
    return _isGPSon;
  }

  Future<void> _displayDist() async {
    _displayDistance = await _updateDistance();
    if(mounted) {
      setState(() {});
    }
  }

  Future<String> _updateDistance() async {
    var distanceString = '';

    return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best)
        .then((pos) {
      distanceString = _computeDistance(pos.latitude, pos.longitude);
      print('in location on $distanceString');
      return distanceString;
    }).catchError((Object error, StackTrace stacktrace) async {
      //if location is off use don't display anything
      print('permission denied');
      return '';
    });
  }

  String _computeDistance(double startLatitude, double startLongitude) {
    var _distance = 0.0;
    var _distanceUnit = ' km';

    var _meterDistance = Geolocator.distanceBetween(startLatitude,
        startLongitude, widget.place.latitude, widget.place.longitude);

    if (_meterDistance > 999.0) {
      _distance = _meterDistance / 1000.0;
      _distanceUnit = ' km';
    } else {
      _distance = _meterDistance;
      _distanceUnit = ' m';
    }
    return _distance.toInt().toString() + _distanceUnit;
  }

  // Interactions
  void tryUnlock() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((pos) {
      setState(() {
        var posDistance = Geolocator.distanceBetween(pos.latitude,
            pos.longitude, widget.place.latitude, widget.place.longitude);

        if (widget.isLocked && posDistance < UNLOCK_RANGE_METERS) {
          widget.isLocked = false;
          _dbUnlockPlace();
          //TODO changeNotifier when unlocked rebuild lock
          // somehow trigger update for marker icon with unlocked icon (for marker with id document.id)
        } else {
          _showInFlushBar("You are too far.");
        }
      });
    }).catchError((Object error, StackTrace stacktrace) {
      //if location is off use don't display anything
      print('location is off, to unlock turn it on');
    });
  }

  void like() {
    if (!widget.isLocked) {
      setState(() {
        if (!widget.isLiked && !widget.isDisliked) {
          _dbUpdateLikes(1);
        } else if (widget.isLiked && !widget.isDisliked) {
          _dbUpdateLikes(-1);
        } else if (!widget.isLiked && widget.isDisliked) {
          _dbSwapLikeDislike(false);
        }

        widget.isLiked = !widget.isLiked;
        widget.isDisliked = false;
      });
    } else {
      _showInFlushBar("You first need to unlock this place.");
    }
  }

  void dislike() {
    if (!widget.isLocked) {
      setState(() {
        if (!widget.isLiked && !widget.isDisliked) {
          _dbUpdateDislikes(1);
        } else if (widget.isLiked && !widget.isDisliked) {
          _dbSwapLikeDislike(true);
        } else if (!widget.isLiked && widget.isDisliked) {
          _dbUpdateDislikes(-1);
        }

        widget.isDisliked = !widget.isDisliked;
        widget.isLiked = false;
      });
    } else {
      _showInFlushBar("You first need to unlock this place.");
    }
  }

  void _showInFlushBar(String message) {
    Flushbar<dynamic>(
      title: "",
      message: message,
      duration: Duration(seconds: 5),
      padding: EdgeInsets.only(bottom: 65),
      icon: Icon(Icons.error_outline, color: Colors.transparent),
    ).show(context);
  }

  // see https://firebase.flutter.dev/docs/firestore/usage/#transactions
  // @param like, if true likes, false unlikes
  Future<void> _dbUpdateLikes(int likesIncrement) async {
    var liked = likesIncrement > 0 ? true : false;

    var placeRef = db.collection('places').doc(widget.place.id);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(widget.place.id);

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
    var disliked = dislikesIncrement > 0 ? true : false;

    var placeRef = db.collection('places').doc(widget.place.id);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(widget.place.id);

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
            (Object error) => print('Failed to update dislikes: $error'));
  }

  // @param fromLikeToDislike == true : add dislike and remove like and vice versa
  Future<void> _dbSwapLikeDislike(bool fromLikeToDislike) async {
    var likesUpdate = fromLikeToDislike ? -1 : 1;
    var dislikesUpdate = fromLikeToDislike ? 1 : -1;

    var placeRef = db.collection('places').doc(widget.place.id);
    var unlockedPlaceRef = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(widget.place.id);

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
    // All places have actually been already downloaded, so not need to get it again.
    // Only need to update UI with new info and write 'unlocking' to db.
    var unlockedPlaces =
        db.collection('users').doc(userId).collection('unlockedPlaces');
    var data = <String, dynamic>{'liked': false, 'disliked': false};

    return await unlockedPlaces.doc(widget.place.id).set(data);
  }

  // Frontend
  Widget topBar() {
    Widget scrollHint = Container(
      width: 28.0,
      height: 4.0,
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    );

    Widget closeIcon = IconButton(
      icon: Icon(
        Icons.close_rounded,
        color: Colors.grey,
        size: 18.0,
      ),
      onPressed: widget.onCardClose,
    );

    return Container(
      width: double.infinity,
      height: 24.0,
      child: Row(
        children: <Widget>[
          Expanded(child: Container()),
          Expanded(
              child: Container(
            alignment: Alignment.center,
            child: scrollHint,
          )),
          Expanded(
              child: Container(
            alignment: Alignment.centerRight,
            child: closeIcon,
          )),
        ],
      ),
    );
  }

  Widget imageBannerLocked() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 150.0,
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(rect),
                blendMode: BlendMode.darken,
                child: Center(
                    child: Image.network(widget.place.imageURL, height: 150.0)),
              ),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.grey.withOpacity(0.1),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: Icon(Icons.lock, color: Colors.black),
              onPressed: tryUnlock,
            ),
          ),
        ),
      ],
    );
  }

  Widget imageBannerUnlocked() {
    return Container(
      width: double.infinity,
      height: 150.0,
      alignment: Alignment.center,
      child: ShaderMask(
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.center,
          colors: [Colors.black, Colors.transparent],
        ).createShader(rect),
        blendMode: BlendMode.darken,
        child: Image.network(widget.place.imageURL, height: 150.0),
      ),
    );
  }

  List<Widget> categoriesTags() {
    var tags = <Widget>[];

    var textStyle = TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    for (var i = 0; i < widget.place.categories.length; i++) {
      tags.add(Container(
        margin: EdgeInsets.only(right: 6.0),
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
        child: Text(widget.place.categories[i], style: textStyle),
        decoration: BoxDecoration(
          color: categoryColors[widget.place.categories[i]] ?? Colors.blue[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
      ));
    }

    return tags;
  }
}

class GmapButton extends StatelessWidget {
  const GmapButton({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    var color = Colors.blue[600] ?? Colors.blue;

    return GestureDetector(
      child: Container(
        width: 72.0,
        decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        //child: Flexible(
          child: Column(
            children: [
              SizedBox(width: 3.0),
              Icon(Icons.navigation, color: color),
              SizedBox(width: 2.0),
              Text(
                'Start',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w400,
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        //)
      ),
      onTap: () {
        openMap(latitude, longitude);
      },
    );
  }

  //Function to be called when the user wants to open the selected place in Google Maps.
  //Arguments -> latitude and longitude of the place
  static Future<void> openMap(double lat, double lng) async {
    var googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    //if (await canLaunch(googleUrl)) { //the canLaunch method doesn't work with API 30 Android11
    await launch(googleUrl);
    /*} else {
      throw 'Could not open the map.';
    }*/
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    var color = Colors.blue[600] ?? Colors.blue;

    return GestureDetector(
      child: Container(
      width: 72.0,
      decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      //child: Flexible(
      child: Column(
        children: [
          SizedBox(width: 3.0),
          Icon(Icons.share, color: color),
          SizedBox(width: 2.0),
          Text(
            'Share',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w400,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
      //)
    ),
      onTap: () {
        Share.share(
            'Join me here! https://maps.google.com/?q=$latitude,$longitude');
      },
    );
  }
}
