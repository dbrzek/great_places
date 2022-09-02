import 'dart:convert';

import 'package:http/http.dart' as http;
import '../googleapikey.dart';



class LocationHelper {
  static String generateLocationPreviewImage(
      {double latitude, double longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String> getPlaceAddress(double lat, double lng) async {
    var _params;
    _params = {
      'latlng': '$lat,$lng',
      'key': '$GOOGLE_API_KEY',
    };
    final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', _params);
    print(url);
    try {
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
    } catch (error) {
      print(error);
      throw error;
      }
  }
}
