import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Network {
  final String url;

  Network(this.url);

  Future<String> apiRequest(Map jsonMap) async {
    var httpClient = HttpClient();
    var request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.add(utf8.encode(json.encode(jsonMap)));
    var response = await request.close();
    // todo - you should check the response.statusCode
    var reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  Future<String> sendData(Map data) async {
    var response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return (response.body);
    } else {
      return 'No Data';
    }
  }

  Future<String> getData() async {
    var response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'});
    if (response.statusCode == 200) {
      return (response.body);
    } else {
      return 'No Data';
    }
  }
}

Future<String> getCountry() async {
  var n = Network('http://ip-api.com/json');
  var locationSTR = (await n.getData());
  dynamic locationx = jsonDecode(locationSTR);
  return locationx['countryCode'] as String;
}

