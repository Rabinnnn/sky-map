import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for fetching data from NASA APIs
class NasaApiService {
  // NASA API key - DEMO_KEY for development (limited to 30 requests per hour)
  static const String _apiKey = 'DEMO_KEY';
  static const String _baseUrl = 'https://api.nasa.gov';

  /// Fetch celestial data from NASA APIs
  /// This uses multiple NASA endpoints to gather information
  Future<List<Map<String, dynamic>>> fetchCelestialData() async {
    final results = <Map<String, dynamic>>[];

    try {
      // Fetch Astronomy Picture of the Day (APOD) for descriptions
      final apod = await _fetchAPOD();
      if (apod != null) {
        results.add(apod);
      }

      // Fetch Near Earth Objects (includes some celestial mechanics)
      final neo = await _fetchNEO();
      results.addAll(neo);

      // Fetch Mars Rover Photos (for Mars data)
      final mars = await _fetchMarsData();
      if (mars != null) {
        results.add(mars);
      }

      return results;
    } catch (e) {
      debugPrint('NASA API error: $e');
      return results;
    }
  }

  /// Fetch Astronomy Picture of the Day
  Future<Map<String, dynamic>?> _fetchAPOD() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/planetary/apod?api_key=$_apiKey'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('APOD fetch error: $e');
    }
    return null;
  }

  /// Fetch Near Earth Objects data
  Future<List<Map<String, dynamic>>> _fetchNEO() async {
    final results = <Map<String, dynamic>>[];
    try {
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse('$_baseUrl/neo/rest/v1/feed?start_date=$today&end_date=$today&api_key=$_apiKey'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final neoData = data['near_earth_objects'] as Map<String, dynamic>?;
        
        if (neoData != null && neoData.containsKey(today)) {
          final objects = neoData[today] as List<dynamic>;
          for (var obj in objects) {
            results.add(obj as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      debugPrint('NEO fetch error: $e');
    }
    return results;
  }

  /// Fetch Mars Rover data
  Future<Map<String, dynamic>?> _fetchMarsData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mars-photos/api/v1/rovers/curiosity/latest_photos?api_key=$_apiKey'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Mars data fetch error: $e');
    }
    return null;
  }

  /// Fetch planet information
  Future<Map<String, dynamic>?> fetchPlanetInfo(String planetName) async {
    try {
      // NASA doesn't have a direct planet info API, but we can use APOD
      // with search functionality or use the HORIZONS system
      // For this implementation, we'll use local data enhanced by NASA APIs
      return null;
    } catch (e) {
      debugPrint('Planet info fetch error: $e');
      return null;
    }
  }

  /// Fetch constellation information
  Future<List<Map<String, dynamic>>> fetchConstellationData() async {
    // NASA APIs don't directly provide constellation data
    // We'll use local data for constellations
    return [];
  }
}