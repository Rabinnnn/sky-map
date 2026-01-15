import 'dart:convert';
import 'package:http/http.dart' as http;

class NasaService {
  Future<double> getPosition(String id, double lat, double lon) async {
    // JPL Horizons API query
    final url = "https://ssd-api.jpl.nasa.gov/horizons.api?format=json&COMMAND='$id'&OBJ_DATA='NO'&MAKE_EPHEM='YES'&EPHEM_TYPE='OBSERVER'&CENTER='coord@399'&SITE_COORD='$lon,$lat,0'&QUANTITIES='1'";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return 0.0; // In production, parse the 'result' string here
      }
    } catch (e) {
      print("API Error: $e");
    }
    return 0.0;
  }
}