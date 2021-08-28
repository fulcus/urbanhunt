import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunt_app/explore/place_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

final db = FirebaseFirestore.instance;
final userId = FirebaseAuth.instance.currentUser!.uid;

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  late Stream<QuerySnapshot> _places;
  late Stream<QuerySnapshot> _unlockedPlaces;
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? initPosition;

  @override
  void initState() {
    super.initState();

    // first initialize initPosition using last known because it's faster
    getLastKnown().then((pos) async {
      // if location is off then
      if (pos == null) {
        throw Exception('pos was null');
      }

      // then determine exact position,
      // if location is off (or other errors) it uses the last known previously set
      await determinePosition().then((value) {
        setState(() {
          initPosition = LatLng(value.latitude, value.longitude);
        });
        cacheLocation();
      }).catchError((Object error, StackTrace stacktrace) {
        //if location is off and
        print('determine pos failed\n' +
            error.toString() +
            stacktrace.toString());
      });
    }).catchError((Object error, StackTrace stacktrace) async {
      //if location is off
      print('last known == null');
      initPosition = await getCachedPosition();
      setState(() {
      });
      print('getLastKnown failed\n' + error.toString() + stacktrace.toString());
    });
    
    //retrieve all the places
    _places = db.collection('places').orderBy('name').snapshots();

    //retrieve the user's unlocked places
    _unlockedPlaces = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _places,
        builder: (context, snapshot) {
          return StreamBuilder<QuerySnapshot>(
              stream: _unlockedPlaces,
              builder: (context, snapshot2) {
                if (snapshot.hasError || snapshot2.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot2.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (initPosition == null) {
                  return Center(child: CircularProgressIndicator());
                }
                return PlaceMap(
                  places: snapshot.data!.docs,
                  unlockedPlaces: snapshot2.data!.docs,
                  initialPosition: initPosition!,
                  mapController: _mapController,
                );
              });
        },
      ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<Position?> getLastKnown() async {
    try {
      var position = await Geolocator.getLastKnownPosition();
      print('lastKnown:' + position.toString());
      return position;
    } on Error catch (error) {
      print('getLastKnownPos stacktrace: ' + error.stackTrace.toString());
    }
  }

  Future<LatLng> getCachedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    var lat = (prefs.getDouble('lat') ?? 0.1);
    var lng = (prefs.getDouble('lng') ?? 0.1);
    return LatLng(lat, lng);
  }

  //cache latest location
  Future<void> cacheLocation() async {
    //print('storing location: $_currentLat $_currentLng');
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('lat', (initPosition?.latitude) ?? 0.2);
    prefs.setDouble('lng', (initPosition?.longitude) ?? 0.2);
  }

}

class PlaceMap extends StatefulWidget {
  PlaceMap({
    Key? key,
    required this.places,
    required this.unlockedPlaces,
    required this.initialPosition,
    required this.mapController,
  }) : super(key: key);

  final List<DocumentSnapshot> places;
  final List<DocumentSnapshot> unlockedPlaces;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  _PlaceMapState createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  late Set<Marker> customMarkers;
  late BitmapDescriptor _markerIconUnlocked;
  late BitmapDescriptor _markerIconLocked;
  double _currentCameraBearing = 0.0;
  double _currentCameraTilt = 0.0;
  double _currentLat = 0.0;
  double _currentLng = 0.0;
  double _currentZoom = 14.0;
  PlaceCard? _placeCard;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialPosition.latitude;
    _currentLng = widget.initialPosition.longitude;
    _setupCustomMarkers();
  }

  @override
  Widget build(BuildContext context) {

    Widget gmap = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: 14,
      ),
      markers: customMarkers,
      onMapCreated: (mapController) {
        widget.mapController.complete(mapController);
        setState(() {});
      },
      onCameraMove: _updateCameraInfo,
      myLocationEnabled: true,

      compassEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      //indoorViewEnabled: true,  // we might need it
    );

    Widget locate = Padding(
      padding: EdgeInsets.only(top: 680.0, left: 330.0),
      child: CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        child: IconButton(
          icon: Icon(Icons.my_location),
          color: Colors.black,
          onPressed: _setCurrentLocation,
        ),
      ),
    );

    Widget rotate = Padding(
      padding: EdgeInsets.only(top: 630.0, left: 330.0),
      child: CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        child: IconButton(
          icon: Icon(Icons.explore),
          color: Colors.black,
          onPressed: _rotateNorth,
        ),
      ),
    );

    var children = <Widget>[gmap, locate];
    if (_currentCameraBearing != 0.0) {
      children.add(rotate);
    }
    if (_placeCard != null) {
      children.add(_placeCard as PlaceCard);
    }

    return Stack(children: children);
  }

  Future<void> _setupCustomMarkers() async {
    // create all markers with the correct starting icon (locked / unlocked)
    customMarkers = {};

    _markerIconUnlocked =
        await _createMarkerImageFromAsset('assets/images/open-lock.png');
    _markerIconLocked =
        await _createMarkerImageFromAsset('assets/images/locked-padlock.png');

    for (var document in widget.places) {
      // retrieve the place from the unlockedPlaces collection, if present
      var current = widget.unlockedPlaces
          .where((element) => element.id == document.id)
          .toList();

      var isLocked = current.isEmpty;

      customMarkers.add(Marker(
        markerId: MarkerId(document.id),
        icon: isLocked ? _markerIconLocked : _markerIconUnlocked,
        position: LatLng(
          document['location'].latitude as double,
          document['location'].longitude as double,
        ),
        onTap: () {
          _onMarkerTap(document);
        },
      ));
    }
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String iconPath) async {
    return await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), iconPath);
  }
  
  void _updateCameraInfo(CameraPosition cameraPosition) {
    _currentCameraBearing = cameraPosition.bearing;
    _currentCameraTilt = cameraPosition.tilt;
    _currentLat = cameraPosition.target.latitude;
    _currentLng = cameraPosition.target.longitude;
    // cacheLocation();
    _currentZoom = cameraPosition.zoom;
    setState(() {});
  }

  void _onMarkerTap(DocumentSnapshot document) {
    setState(() {
      // if not present among unlocked -> locked
      var current = widget.unlockedPlaces
          .where((element) => element.id == document.id)
          .toList();
      var isLocked = current.isEmpty;

      // update markerIcon to match place locked/unlocked and set place card
      var isLiked = false;
      var isDisliked = false;

      if (!isLocked) {
        isLiked = current[0]['liked'] as bool;
        isDisliked = current[0]['disliked'] as bool;
      }

      customMarkers.add(Marker(
        markerId: MarkerId(document.id),
        icon: isLocked ? _markerIconLocked : _markerIconUnlocked,
        position: LatLng(
          document['location'].latitude as double,
          document['location'].longitude as double,
        ),
        onTap: () {
          _onMarkerTap(document);
        },
      ));

      _placeCard = PlaceCard(
          document, false, isLocked, isLiked, isDisliked, _onCardClose);
    });
  }

  void _onCardClose() {
    setState(() {
      _placeCard = null;
    });
  }

  Future<void> _setCurrentLocation() async {
    // todo handle exception location is disabled
    var currentLocation = await Geolocator.getCurrentPosition();
    var cPosition = CameraPosition(
      zoom: 14,
      bearing: _currentCameraBearing,
      tilt: _currentCameraTilt,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final controller = await widget.mapController.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(cPosition))
        .then((value) {
      setState(() {});
    });
  }

  Future<void> _rotateNorth() async {
    var cPosition = CameraPosition(
      zoom: _currentZoom,
      bearing: 0.0,
      target: LatLng(_currentLat, _currentLng),
    );
    final controller = await widget.mapController.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(cPosition))
        .then((value) {
      setState(() {});
    });
  }
}
