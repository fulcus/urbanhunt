import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunt_app/place_card.dart';

import 'navbar.dart';

final db = FirebaseFirestore.instance;
final userId = FirebaseAuth.instance.currentUser!.uid;
bool loading = true;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage(),
      bottomNavigationBar: Nav(),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title = 'Hunt';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<QuerySnapshot> _places;
  late Stream<QuerySnapshot> _unlockedPlaces;
  final Completer<GoogleMapController> _mapController = Completer();

  double _initLat = 0.0;
  double _initLng = 0.0;

  @override
  void initState() {
    super.initState();

    //retrieve all the places
    _places = db.collection('places').orderBy('name').snapshots();

    //retrieve the user's unlocked places
    _unlockedPlaces = db
        .collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .snapshots();

    //retrieve the user's initial position
    _determinePosition().then((value) {
      setState(() {
        _initLat = value.latitude;
        _initLng = value.longitude;
        loading = false;
      });
    });
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
  Set<Marker> customMarkers = {};
  double _currentCameraBearing = 0.0;
  double _currentCameraTilt = 0.0;
  double _currentLat = 0.0;
  double _currentLng = 0.0;
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialPosition.latitude;
    _currentLng = widget.initialPosition.longitude;
    _setCustomMarkers();
  }

  @override
  Widget build(BuildContext context) {
    if (loading == false) {
      return Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: 12,
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
          //indoorViewEnabled: true, => we might need it
        ),
        Padding(
          padding: EdgeInsets.only(top: 680.0, left: 350.0),
          child: CircleAvatar(
            backgroundColor: Colors.amber,
            child: IconButton(
              icon: Icon(Icons.my_location),
              color: Colors.black,
              onPressed: _setCurrentLocation,
            ),
          ),
        ),
        if (_currentCameraBearing != 0.0)
          Padding(
            padding: EdgeInsets.only(top: 630.0, left: 350.0),
            child: CircleAvatar(
              backgroundColor: Colors.amber,
              child: IconButton(
                icon: Icon(Icons.explore),
                color: Colors.black,
                onPressed: _rotateNorth,
              ),
            ),
          )
      ]);
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void _updateCameraInfo(CameraPosition cameraPosition) {
    _currentCameraBearing = cameraPosition.bearing;
    _currentCameraTilt = cameraPosition.tilt;
    _currentLat = cameraPosition.target.latitude;
    _currentLng = cameraPosition.target.longitude;
    _currentZoom = cameraPosition.zoom;
    setState(() {});
  }

  Future<void> _setCurrentLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition();
    var cPosition = CameraPosition(
      zoom: 12,
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

  Future<void> _setCustomMarkers() async {
    var markers = <Marker>{};

    late BitmapDescriptor unlockedImg;
    late BitmapDescriptor lockedImg;

    unlockedImg =
        await _createMarkerImageFromAsset('assets/images/open-lock.png');
    lockedImg =
        await _createMarkerImageFromAsset('assets/images/locked-padlock.png');

    for (var document in widget.places) {
      if (widget.unlockedPlaces
          .where((element) => element.id == document.id)
          .isEmpty) {
        markers.add(Marker(
            markerId: MarkerId(document.id),
            icon: lockedImg,
            position: LatLng(
              document['location'].latitude as double,
              document['location'].longitude as double,
            ),
            onTap: () {
              // Update the state of the app
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => PlaceCard(document),
                ),
              );
            }));
      } else {
        markers.add(Marker(
            markerId: MarkerId(document.id),
            icon: unlockedImg,
            position: LatLng(
              document['location'].latitude as double,
              document['location'].longitude as double,
            ),
            onTap: () {
              // Update the state of the app
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => PlaceCard(document),
                ),
              );
            }));
      }
    }
    customMarkers = markers;
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String iconPath) async {
    return await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), iconPath);
  }
}
