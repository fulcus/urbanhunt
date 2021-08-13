import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:place_picker/entities/location_result.dart';

class PlaceData {
  late LocationResult? pickedLocation = null;
  late String city,
      country,
      street,
      imgPath,
      lockedDescription,
      unlockedDescription,
      name,
      imageURL;
  late GeoPoint location;
  late List<String> categories = [];

  Future<void> addPlace() async {
    var places = FirebaseFirestore.instance.collection('places');

    var data = <String, dynamic>{
      'address': {
        'city': city,
        'country': country,
        'street': street
      },
      'categories': categories,
      'imgpath': imageURL,
      'lockedDescr': lockedDescription,
      'unlockedDescr': unlockedDescription,
      'name': name,
      'dislikes': 0,
      'location': location,
      'likes': 0
    };

    await places.add(data);
  }

}
