// models/celestial_object.dart
import 'package:flutter/foundation.dart';

class CelestialObject {
  final String id;
  final String name;
  final String type; // planet, sun, moon, constellation
  final double ra; // Right Ascension in hours (0..24)
  final double dec; // Declination in degrees (-90..+90)
  final String description;
  final double magnitude; // optional for drawing size

  CelestialObject({
    required this.id,
    required this.name,
    required this.type,
    required this.ra,
    required this.dec,
    required this.description,
    this.magnitude = 1.0,
  });

  factory CelestialObject.fromJson(Map<String, dynamic> j) {
    return CelestialObject(
      id: j['id'] as String,
      name: j['name'] as String,
      type: j['type'] as String,
      ra: (j['ra'] as num).toDouble(),
      dec: (j['dec'] as num).toDouble(),
      description: j['description'] as String,
      magnitude: (j['magnitude'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
