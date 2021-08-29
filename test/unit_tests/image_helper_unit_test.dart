
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/utils/image_helper.dart';

ImageHelper imageHelper = ImageHelper();

void main() {

  final asset = 'assets/images/as.png';
  final url = 'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67';;
  ImageProvider result;
  var networkImage = NetworkImage(url);
  var assetImage = AssetImage(asset);

  /*group('Show Image', () {
    test('Provided URL', () {
      result = imageHelper.showImage(url, asset);
      expect(result, networkImage);
    });

    test('Not provided URL', () {
      result = imageHelper.showImage('', asset);
      expect(result, assetImage);
    });
  });*/

}