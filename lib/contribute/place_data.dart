import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:place_picker/entities/location_result.dart';

class PlaceData {
  LocationResult pickedLocation;
  String lockedDescription, unlockedDescription, name, imageURL;

  String city, country, street;
  GeoPoint location;
  List<String> categories;

  PlaceData(this.name, this.lockedDescription, this.unlockedDescription,
      this.pickedLocation, this.imageURL, this.categories)
      : location = GeoPoint(
      pickedLocation.latLng!.latitude, pickedLocation.latLng!.longitude),
        street = pickedLocation.name!,
        city = pickedLocation.city!.name!,
        country = pickedLocation.country!.name!;

  Future<void> upload() async {
    var places = FirebaseFirestore.instance.collection('places');

    var jsonData = <String, dynamic>{
      'address': {'city': city, 'country': country, 'street': street},
      'categories': categories,
      'dislikes': 0,
      'imgpath': imageURL,
      'likes': 0,
      'location': location,
      'lockedDescr': lockedDescription,
      'name': name,
      'unlockedDescr': unlockedDescription,
    };

    await places.add(jsonData);
  }
}
