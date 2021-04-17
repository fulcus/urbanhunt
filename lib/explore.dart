
import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'counter.dart';


// Hue used by the Google Map Markers to match the theme
const _pinkHue = 350.0;
final db = FirebaseFirestore.instance;
bool loading = true;


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<QuerySnapshot> _places;
  final Completer<GoogleMapController> _mapController = Completer();

  double _initLat = 0.0;
  double _initLng = 0.0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _places = FirebaseFirestore.instance
        .collection('places')
        .orderBy('name')
        .snapshots();

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
        return Future.error(
            'Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _places,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: const Text('Loading...'));
          }

          return Stack(
            children: [
              StoreMap(
                documents: snapshot.data!.docs,
                initialPosition: LatLng(_initLat, _initLng),
                mapController: _mapController,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.explore),
             label: 'Map',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Contribute',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Social'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class StoreMap extends StatelessWidget {
  final String userId = 'Kd5combpKoh1gLYyYUyftiAwcbP2'; //get from auth (look for the right method to get id)

  const StoreMap({
    Key? key,
    required this.documents,
    required this.initialPosition,
    required this.mapController,
  }) : super(key: key);

  final List<DocumentSnapshot> documents;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    if(loading == false) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 12,
        ),
        markers: documents
            .map((document) => Marker(
          markerId: MarkerId(document.id),
          icon:  BitmapDescriptor.defaultMarkerWithHue(_pinkHue), //_assignIcon(document),
          position: LatLng(
            document['location'].latitude as double,
            document['location'].longitude as double,
          ),
        ))
            .toSet(),
        onMapCreated: (mapController) {
          this.mapController.complete(mapController);
        },
        myLocationEnabled: true,
        padding: EdgeInsets.only(top: 680.0),
        myLocationButtonEnabled: true,
        compassEnabled: true,

        mapToolbarEnabled: false,
        //zoomControlsEnabled: false,
      );
    }
    else {
      return CircularProgressIndicator(
        
      );
    }
  }

  Future<BitmapDescriptor> _assignIcon(DocumentSnapshot document) async {
    var currentPlace = document.id;
    late Future<BitmapDescriptor> icon;

    //prendi tutti i posti e vedi se il current document è sbloccato o bloccato

    await db.collection('users')
        .doc(userId)
        .collection('unlockedPlaces')
        .doc(currentPlace)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        icon = BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)), 'assets/images/open-lock.png');
      }
      else {
        icon = BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)), 'assets/images/locked-padlock.png');
      }
    });

    return icon;
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



