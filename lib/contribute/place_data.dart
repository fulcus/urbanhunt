import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hunt_app/utils/misc.dart';
import 'package:place_picker/entities/location_result.dart';

class PlaceData {
  String lockedDescription, unlockedDescription, name, imageURL, creatorId;

  String city, country, street;
  double latitude, longitude;
  List<String> categories;

  String? id; // randomly assigned by firestore
  int likes = 0, dislikes = 0;

  PlaceData(this.name, this.lockedDescription, this.unlockedDescription,
      this.imageURL, this.creatorId, this.categories, LocationResult location)
      : latitude = location.latLng!.latitude,
        longitude = location.latLng!.longitude,
        street = location.name!,
        city = location.city!.name!,
        country = location.country!.name!;

  PlaceData.fromSnapshot(DocumentSnapshot document)
      : id = document.id,
        name = document['name'] as String,
        street = document['address']['street'] as String,
        city = document['address']['city'] as String,
        country = document['address']['country'] as String,
        creatorId = document['creatorId'] as String,
        categories = (document['categories'] as List)
            .map((dynamic e) => e.toString())
            .toList(),
        lockedDescription = document['lockedDescr'] as String,
        unlockedDescription = document['unlockedDescr'] as String,
        latitude = document['location'].latitude as double,
        longitude = document['location'].longitude as double,
        imageURL = document['imgpath'] as String,
        likes = document['likes'] as int,
        dislikes = document['dislikes'] as int;

  Future<void> upload() async {
    var places = db.collection('places');

    var jsonData = <String, dynamic>{
      'address': {'city': city, 'country': country, 'street': street},
      'categories': categories,
      'dislikes': 0,
      'imgpath': imageURL,
      'likes': 0,
      'location': GeoPoint(latitude, longitude),
      'lockedDescr': lockedDescription,
      'name': name,
      'unlockedDescr': unlockedDescription,
      'creatorId': creatorId,
    };

    await places.add(jsonData);
  }
}
