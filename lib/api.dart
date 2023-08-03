import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getApi(String lat, String long) async {
  final response = await http.get(
    Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${long}&appid=19acf7f6b98a71a867bbda834dd3c725'),
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON
    return jsonDecode(response.body);
  } else {
    // If the server did not return a 200 OK response, throw an exception.
    throw Exception('Failed to load weather data');
  }
}