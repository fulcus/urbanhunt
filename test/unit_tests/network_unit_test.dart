import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/utils/network.dart';

void main() {
  test('Given API request, When it is successful, Then return a String',
      () async {
    Network network = Network('http://ip-api.com/json');
    String? responseBody = await network.getData();
    expect(responseBody is String, true);
  });

  test('Given API request, When it fails, Then return a String', () async {
    Network network = Network('http://ip-api.com');
    String? responseBody = await network.getData();
    expect(responseBody, null);
  });

  test('Given API request for country, When it is successful, Then return IT',
      () async {
    String? country = await getCountry();
    expect(country, 'IT');
  });
}
