import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunt_app/auth/login_page.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:hunt_app/explore/place_card.dart';
import 'package:hunt_app/utils/image_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Explore extends StatefulWidget {
  final User loggedUser;
  final FirebaseFirestore db;

  Explore(this.loggedUser, this.db);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  late Stream<QuerySnapshot> _places;
  late Stream<QuerySnapshot> _unlockedPlaces;
  final Completer<GoogleMapController> _mapController = Completer();
  late String userId;
  LatLng? initPosition;

  @override
  void initState() {
    super.initState();
    userId = widget.loggedUser.uid;

    // first initialize initPosition using last known because it's faster
    getLastKnown().then((pos) async {
      // if location is off then init in Milan
      if (pos == null) {
        initPosition = LatLng(45.464664, 9.188540);
        print('pos was null');
      }

      // then determine exact position,
      // if location is off (or other errors) it uses the last known previously set
      await determinePosition().then((value) {
        if (mounted) {
          setState(() {
            initPosition = LatLng(value.latitude, value.longitude);
          });
        }
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
      setState(() {});
      print('getLastKnown failed\n' + error.toString() + stacktrace.toString());
    });

    //retrieve all the places
    _places = widget.db.collection('places').orderBy('name').snapshots();

    //retrieve the user's unlocked places
    _unlockedPlaces = widget.db
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
                  loggedUser: widget.loggedUser,
                  db: widget.db,
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      permission = await Geolocator.checkPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      else {
        return await Geolocator.getCurrentPosition();
      }
    }
    else {
      return await Geolocator.getCurrentPosition();
    }
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
    required this.loggedUser,
    required this.db,
    required this.places,
    required this.unlockedPlaces,
    required this.initialPosition,
    required this.mapController,
  }) : super(key: key);

  final User loggedUser;
  final FirebaseFirestore db;
  final List<DocumentSnapshot> places;
  final List<DocumentSnapshot> unlockedPlaces;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  _PlaceMapState createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  late BitmapDescriptor _markerIconUnlocked;
  late BitmapDescriptor _markerIconLocked;
  late ui.Image _clusterIcon;
  late ClusterManager _clusterManager;
  double _currentCameraBearing = 0.0;
  double _currentCameraTilt = 0.0;
  double _currentLat = 0.0;
  double _currentLng = 0.0;
  double _currentZoom = 14.0;
  Set<Marker> customMarkers = {};
  PlaceCard? _placeCard;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialPosition.latitude;
    _currentLng = widget.initialPosition.longitude;

    _loadCustomIcon();

    List<String> unlockedIds = [];
    for(DocumentSnapshot doc in widget.unlockedPlaces) {
      unlockedIds.add(doc.id);
    }

    List<PlaceCard> _placeItems = [];

    for(DocumentSnapshot place in widget.places) {
      var current = widget.unlockedPlaces
          .where((element) => element.id == place.id)
          .toList();

      if(unlockedIds.contains(place.id)) {
        _placeItems.add(PlaceCard(widget.loggedUser, widget.db, PlaceData.fromSnapshot(place), false, current[0]['liked'] as bool, current[0]['disliked'] as bool, _onCardClose, unlockDate: current[0]['unlockDate'] as Timestamp));
      }
      else {
        _placeItems.add(PlaceCard(widget.loggedUser, widget.db, PlaceData.fromSnapshot(place), true, false, false, _onCardClose));
      }
    }

    _clusterManager = ClusterManager<PlaceCard>(
        _placeItems, // Your items to be clustered on the map (of Place type for this example)
        _updateMarkers, // Method to be called when markers are updated
        markerBuilder: _markerBuilder, // Optional : Method to implement if you want to customize markers
        levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0], // Optional : Configure this if you want to change zoom levels at which the clustering precision change
        extraPercent: 0.2, // Optional : This number represents the percentage (0.2 for 20%) of latitude and longitude (in each direction) to be considered on top of the visible map bounds to render clusters. This way, clusters don't "pop out" when you cross the map.
        stopClusteringZoom: 16.0 // Optional : The zoom level to stop clustering, so it's only rendering single item "clusters"
    );
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
        _clusterManager.setMapId(mapController.mapId);
        mapController.setMapStyle('[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
        setState(() {});
      },
      onCameraMove: _updateCameraInfo,
      onCameraIdle: _clusterManager.updateMap,
      myLocationEnabled: true,

      compassEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      //indoorViewEnabled: true,  // we might need it
    );

    Widget locate = Container(
      alignment: Alignment.bottomRight,
      padding: isMobile ? EdgeInsets.only(bottom: 130, right: 25) : EdgeInsets.only(bottom: 100, right: 100),
      child:  GestureDetector(
        onTap: _setCurrentLocation,
        child: CircleAvatar(
          backgroundColor: Colors.indigo,
          radius: 18.0,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 17.0,
            child: Icon(
              Icons.my_location,
              color: Colors.indigo,
              size: 25.0,
            ),
          ),
        ),
      )
    );

    Widget rotate = Container(
      alignment: Alignment.bottomRight,
      padding: isMobile ? EdgeInsets.only(bottom: 180, right: 25) : EdgeInsets.only(bottom: 150, right: 100),
      child: GestureDetector(
        onTap: _rotateNorth,
        child: CircleAvatar(
          backgroundColor: Colors.indigo,
          radius: 18.0,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 17.0,
            child: Icon(
              Icons.explore,
              color: Colors.indigo,
              size: 25.0,
            ),
          ),
        ),
      )
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

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String iconPath) async {
    return await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), iconPath);
  }

  void _updateCameraInfo(CameraPosition cameraPosition) {
    _clusterManager.onCameraMove(cameraPosition);
    _currentCameraBearing = cameraPosition.bearing;
    _currentCameraTilt = cameraPosition.tilt;
    _currentLat = cameraPosition.target.latitude;
    _currentLng = cameraPosition.target.longitude;
    // cacheLocation();
    _currentZoom = cameraPosition.zoom;
    setState(() {});
  }

  void _onCardClose() {
    setState(() {
      _placeCard = null;
    });
  }

  Future<Marker> Function(Cluster<PlaceCard>) get _markerBuilder =>
          (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            if(cluster.isMultiple) {
              _placeCard = null;
              _zoomIn();
              print(cluster);
            } else {
              _placeCard = cluster.items.first;
            }
          },
          icon: await _setCustomIcon(cluster)
        );
      };

  Future<void> _loadCustomIcon() async {
    _markerIconUnlocked =
    await _createMarkerImageFromAsset('assets/images/unlocked-green.png');
    _markerIconLocked =
    await _createMarkerImageFromAsset('assets/images/locked-red.png');

    _clusterIcon = await ImageHelper().loadUiImage('assets/images/cluster-blue-v5.png');

  }

  Future<BitmapDescriptor> _setCustomIcon(Cluster<PlaceCard> cluster) async {
    if(cluster.isMultiple) {
      return await _getMarkerBitmap(125, text: cluster.count.toString());
    }
    else {
      bool isLocked = cluster.items.first.isLocked;

      return isLocked ? _markerIconLocked : _markerIconUnlocked;
    }
  }

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.indigo;

    canvas.drawImage(_clusterIcon, Offset.zero, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.indigo,
            fontWeight: FontWeight.bold),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2.7 - painter.width / 2, size / 2.5 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    if(mounted) {
      setState(() {
      customMarkers = markers;
    });
    }
  }

  Future<void> _zoomIn() async {
    final controller = await widget.mapController.future;
    await controller
        .animateCamera(CameraUpdate.zoomIn())
        .then((value) {
      setState(() {});
    });
  }


  Future<void> _setCurrentLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition().catchError((Object error) async {
      if(error is LocationServiceDisabledException) {
        await Geolocator.requestPermission();
      }
    });
    var cPosition = CameraPosition(
      zoom: 16,
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
