import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:hunt_app/explore/unlocked_popup.dart';
import 'package:hunt_app/login_page.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'explore.dart';

// Unlock distance threshold
const double UNLOCK_RANGE_METERS = 15.0;

//TODO probably they need to be local variable for testing purposes
// Firebase db instance
final db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;

// Map category tag to its color
final Map<String, Color> categoryColors = {
  'Art': Colors.blue[300]!,
  'Nature': Colors.green[300]!,
  'Culture': Colors.orangeAccent,
  'Food': Color.fromARGB(255,235,82,105),
};

class PlaceCard extends StatefulWidget with ClusterItem {
  // new card should be created for each place
  // isLocked, isLiked, isDisliked are actually part of state

  PlaceData place;
  bool fullscreen, isLocked, isLiked, isDisliked;
  Timestamp unlockDate;
  late void Function() onCardClose;

  PlaceCard(this.place, this.isLocked, this.isLiked, this.isDisliked,
      this.onCardClose, this.unlockDate,
      {this.fullscreen = false, Key? key})
      : super(key: key);

  @override
  PlaceCardState createState() => PlaceCardState();

  @override
  LatLng get location {
    return LatLng(
      place.latitude,
      place.longitude,
    );
  }
}

class PlaceCardState extends State<PlaceCard> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final User _myUser = FirebaseAuth.instance.currentUser!;
  String _displayDistance = '';
  bool _isGPSon = false;
  bool _isEmailAuth = true;

  PlaceCardState();

  @override
  void initState() {
    super.initState();

    _checkGPS().then((isGPSon) {
      if (isGPSon) {
        _displayDist();
      }
    });

    _isEmailAuthProvider();
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

    var likeOn = widget.isLiked ? Colors.green[300] : Colors.grey[400];
    var dislikeOn = widget.isDisliked ? Color.fromARGB(255,235,82,105) : Colors.grey[400];

    var likeIcon = Icon(Icons.thumb_up_alt, size: 20.0, color: likeOn);
    var dislikeIcon = Icon(Icons.thumb_down_alt, size: 20.0, color: dislikeOn);

    // Content
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height*0.8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Image
              imageBanner,
              // scroll hint and close button
              if(!widget.fullscreen)
              Positioned(child: topBar(), right: 0, left: 0, top: 1),
              // Below Image: Place info
              Positioned(
                right: 0,
                left: 0,
                top: isMobile ? 162 : 348,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(8),
                    ),
                  ),
                  padding: isMobile ? EdgeInsets.only(top: 10.0, left: 32.0, right: 32.0)
                  : EdgeInsets.only(top: 10.0, left: 70.0, right: 70.0),
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
                            (widget.place.likes).toString(),
                            style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[300]),
                          ),
                          SizedBox(width: 16.0),
                          GestureDetector(onTap: dislike, child: dislikeIcon),
                          SizedBox(width: 4.0),
                          Text(
                            (widget.place.dislikes)
                                .toString(),
                            style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255,235,82,105)),
                          ),
                          // Sep
                          Spacer(),
                          // Category tags
                          Row(children: categoriesTags()),
                        ],
                      ),
                      // Sep
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child:  Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  Text(
                                    widget.place.name,
                                    style: TextStyle(
                                      color: Colors.indigo,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  // Sep
                                  SizedBox(height: 4.0),
                                  // Address
                                  Text(
                                    widget.place.street+'\n'+ widget.place.city+' ('+ widget.place.country+')',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey
                                    ),
                                  ),
                                  // Sep
                                  SizedBox(height: 10.0),
                                  // Distance
                                  if (_isGPSon)
                                    Text(
                                      _displayDistance,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  SizedBox(height: 10.0),
                                  // Unlock date
                                  if(!widget.isLocked)
                                    Text(
                                      'Unlocked on '+ DateFormat.yMMMMd('en_US').format(widget.unlockDate.toDate()).toString(),
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.grey
                                      ),
                                    )
                                ],
                              ),
                          ),
                          Column(
                            children: [
                              // Open directions in Google Maps
                              GmapButton(
                                latitude: widget.place.latitude,
                                longitude: widget.place.longitude,
                              ),
                              SizedBox(height: 12.0),
                              // Share GPS position with a friend
                              ShareButton(
                                latitude: widget.place.latitude,
                                longitude: widget.place.longitude,
                              )
                            ],
                          )
                        ],
                      ),
                      // Sep
                      SizedBox(height: 10.0),
                      Divider(height: 8),
                      // Description
                      Text('Description:', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4.0),
                      Text(description, style: TextStyle(fontSize: 12.0)),
                      // Sep
                      SizedBox(height: 900.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.fullscreen) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.place.name),
          elevation: 0.0,
          bottomOpacity: 0.0,
        ),
        body: Material(
          elevation: 10,
          color: Colors.indigo,
          child: content,
        ),
      );
    } else {
      if(isMobile) {
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
      else {
        return Align(
          alignment: Alignment.bottomRight,
          child: SingleChildScrollView(
            child: SizedBox(
                width: MediaQuery.of(context).size.width*0.4,
                height: MediaQuery.of(context).size.height,
                child: Material(
                  elevation: 10,
                  shadowColor: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0)),
                  child: content,
                )
            ),
          ),
        );
      }
    }
  }


  void _isEmailAuthProvider() {
    var providerId = _myUser.providerData[0].providerId;

    if (providerId != 'password') {
      _isEmailAuth = false;
    }
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
    if(_isEmailAuth && !_myUser.emailVerified) {
      _showInFlushBar('Please verify your email first.');
    }
    else {
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((pos) {
        setState(() {
          var posDistance = Geolocator.distanceBetween(pos.latitude,
              pos.longitude, widget.place.latitude, widget.place.longitude);

          if (widget.isLocked && posDistance < UNLOCK_RANGE_METERS) {
            widget.isLocked = false;
            _dbUnlockPlace();

            // somehow trigger update for marker icon with unlocked icon => replace Explore page
            Navigator.of(context)
                .pushReplacement(
              MaterialPageRoute<void>(builder: (context) => Explore(),
              ),
            );

            showDialog<dynamic>(
                barrierColor: Colors.black26,
                context: context,
                builder: (context) {
                  return UnlockedPopup();
                });
          } else {
            _showInFlushBar("You are too far.");
          }
        });
      }).catchError((Object error, StackTrace stacktrace) {
        //if location is off use don't display anything
        print('location is off, to unlock turn it on');
      });
    }
  }

  void like() {
    if (!widget.isLocked) {
      setState(() {
        if (!widget.isLiked && !widget.isDisliked) {
          _dbUpdateLikes(1);
          widget.place.likes = widget.place.likes+1;
        } else if (widget.isLiked && !widget.isDisliked) {
          widget.place.likes = widget.place.likes-1;
          _dbUpdateLikes(-1);
        } else if (!widget.isLiked && widget.isDisliked) {
          _dbSwapLikeDislike(false);
          widget.place.likes = widget.place.likes+1;
          widget.place.dislikes = widget.place.dislikes-1;
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
          widget.place.dislikes = widget.place.dislikes+1;
        } else if (widget.isLiked && !widget.isDisliked) {
          _dbSwapLikeDislike(true);
          widget.place.likes = widget.place.likes-1;
          widget.place.dislikes = widget.place.dislikes+1;
        } else if (!widget.isLiked && widget.isDisliked) {
          _dbUpdateDislikes(-1);
          widget.place.dislikes = widget.place.dislikes-1;
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
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 300),
      padding: EdgeInsets.only(bottom: 60),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(14),
        topLeft: Radius.circular(14),
      ),
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
        .catchError((Object error, StackTrace stacktrace) => print('Failed to update likes: $error'));
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
            (Object error, StackTrace stacktrace) => print('Failed to update dislikes: $error'));
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
            (Object error, StackTrace stacktrace) => print('Failed to update dislikes: $error'));
  }

  Future<void> _dbUnlockPlace() async {
    // All places have actually been already downloaded, so not need to get it again.
    // Only need to update UI with new info and write 'unlocking' to db.
    var unlockedPlaces =
        db.collection('users').doc(userId).collection('unlockedPlaces');
    var data = <String, dynamic>{'liked': false, 'disliked': false, 'unlockDate': Timestamp.now()};

    return await unlockedPlaces.doc(widget.place.id).set(data);
  }

  // Frontend
  Widget topBar() {
    Widget scrollHint = Container(
      width: 28.0,
      height: 4.0,
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.all(Radius.circular(14.0)),
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
          Expanded(child: Container(color: Colors.transparent)),
          Expanded(
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: scrollHint,
          )),
          Expanded(
              child: Container(
                color: Colors.transparent,
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
          height: isMobile? 180.0 : 350.0,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: isMobile || widget.fullscreen ? Radius.circular(14) : Radius.circular(0),
                        topLeft: Radius.circular(14),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.place.imageURL,
                        height: isMobile? 180.0 : 350.0,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, dynamic error) => Icon(Icons.error),
                      ),
                    ),
                )
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: isMobile || widget.fullscreen ? Radius.circular(14) : Radius.circular(0),
                  topLeft: Radius.circular(14),
                ),
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
        Positioned(
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
      height: isMobile? 180.0 : 350.0,
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: isMobile || widget.fullscreen ? Radius.circular(14) : Radius.circular(0),
          topLeft: Radius.circular(14),
        ),
        child:  ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.transparent],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: CachedNetworkImage(
            imageUrl: widget.place.imageURL,
            height: isMobile? 180.0 : 350.0,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            errorWidget: (context, url, dynamic error) => Icon(Icons.error),
          ),
        ),
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
          color: categoryColors[widget.place.categories[i]],
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
    var color = Colors.indigo;

    return GestureDetector(
      child: Container(
        width: 72.0,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color),
            borderRadius: BorderRadius.all(Radius.circular(16))),
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
    var color = Colors.indigo;

    return GestureDetector(
      child: Container(
      width: 72.0,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color),
          borderRadius: BorderRadius.all(Radius.circular(16))),
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
