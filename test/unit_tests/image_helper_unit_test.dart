
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/utils/image_helper.dart';


void main() {

  final asset = 'assets/images/default_profile.png';
  final url = 'https://upload.wikimedia.org/wikipedia/en/7/7d/Lenna_%28test_image%29.png';
  final ImageHelper imageHelper = ImageHelper();

  ImageProvider result;
  var networkImage = CachedNetworkImageProvider(url);
  var assetImage = AssetImage(asset);

  group('Given image URL, Show image', () {
    test('Provided URL', () {
      result = imageHelper.showImage(url, asset);
      expect(result, networkImage);
    });

    test('Not provided URL, Load asset', () {
      result = imageHelper.showImage('', asset);
      expect(result, assetImage);
    });
  });

}