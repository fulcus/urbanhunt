import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:place_picker/entities/location_result.dart';

class PlaceData {
  LocationResult? pickedLocation;
  late String city,
      country,
      street,
      imgPath,
      lockedDescription,
      unlockedDescription,
      name,
      imageURL;
  late GeoPoint location;
  late List<String> categories;

  Future<void> addPlace() async {
    var places = FirebaseFirestore.instance.collection('places');

    var data = <String, dynamic>{
      'address': {
        'city': city,
        'country': country,
        'street': street
      },
      'categories': categories,
      'dislikes': 0,
      'imgpath': imageURL,
      'likes': 0,
      'location': location,
      'lockedDescr': lockedDescription,
      'name': name,
      'unlockedDescr': unlockedDescription,
    };

    await places.add(data);
  }

}
