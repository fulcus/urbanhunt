import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hunt_app/explore/place_card.dart';
import 'package:hunt_app/navbar.dart';

final db = FirebaseFirestore.instance;
final userId = FirebaseAuth.instance.currentUser!.uid;
bool loading = true;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Explore(),
      bottomNavigationBar: Nav(),
    );
  }
}

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  late Stream<QuerySnapshot> _places;
  late Stream<QuerySnapshot> _unlockedPlaces;
  final Completer<GoogleMapController> _mapController = Completer();

  double _initLat = 0.0;
  double _initLng = 0.0;

  @override
  void initState() {
    super.initState();

    //retrieve the user's initial position
    _determinePosition().then((value) {
      setState(() {
        _initLat = value.latitude;
        _initLng = value.longitude;
        loading = false;
      });
    }).catchError((Object error, StackTrace stacktrace) async {
      //if location is off use the latest cached location
      await SharedPreferences.getInstance().then((prefs) => setState(() {
            _initLat = (prefs.getDouble('_initLat') ?? 0.1);
            _initLng = (prefs.getDouble('_initLng') ?? 0.1);
            loading = false;
          }));
      print('initializing locations: $_initLat $_initLng');
      print(stacktrace.toString());
      return null;
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

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      loading = false;
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
                return StoreMap(
                  places: snapshot.data!.docs,
                  unlockedPlaces: snapshot2.data!.docs,
                  initialPosition: LatLng(_initLat, _initLng),
                  mapController: _mapController,
                );
              });
        },
      ),
    );
  }
}

class StoreMap extends StatefulWidget {
  StoreMap({
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
  _StoreMapState createState() => _StoreMapState();

}

class _StoreMapState extends State<StoreMap> {
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

  //cache latest location
  Future<void> _cacheLocation() async {
    //print('storing location: $_currentLat $_currentLng');
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('_initLat', _currentLat);
      prefs.setDouble('_initLng', _currentLng);
    });
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

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

  void _updateCameraInfo(CameraPosition cameraPosition) {
    _currentCameraBearing = cameraPosition.bearing;
    _currentCameraTilt = cameraPosition.tilt;
    _currentLat = cameraPosition.target.latitude;
    _currentLng = cameraPosition.target.longitude;
    _cacheLocation();
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

      _placeCard =
          PlaceCard(document, isLocked, isLiked, isDisliked, _onCardClose);
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
