import 'dart:math';
import 'package:flutter/material.dart';

/// Represents a celestial object in the sky
class CelestialObject {
  final String id;
  final String name;
  final CelestialType type;
  final double rightAscension; // in hours (0-24)
  final double declination; // in degrees (-90 to 90)
  final double magnitude; // brightness
  final String description;
  final Color color;
  final double size; // visual size on screen

  CelestialObject({
    required this.id,
    required this.name,
    required this.type,
    required this.rightAscension,
    required this.declination,
    required this.magnitude,
    required this.description,
    required this.color,
    this.size = 5.0,
  });

  /// Calculate altitude and azimuth based on observer's location and time
  Map<String, double> getHorizontalCoordinates({
    required double latitude,
    required double longitude,
    required DateTime time,
  }) {
    // Calculate Local Sidereal Time
    final lst = _calculateLST(longitude, time);
    
    // Convert RA to degrees
    final raDegrees = rightAscension * 15.0;
    
    // Calculate Hour Angle
    final hourAngle = lst - raDegrees;
    
    // Convert to radians
    final latRad = latitude * pi / 180;
    final decRad = declination * pi / 180;
    final haRad = hourAngle * pi / 180;
    
    // Calculate altitude
    final sinAlt = sin(latRad) * sin(decRad) + 
                   cos(latRad) * cos(decRad) * cos(haRad);
    final altitude = asin(sinAlt) * 180 / pi;
    
    // Calculate azimuth
    final cosAz = (sin(decRad) - sin(latRad) * sinAlt) / 
                  (cos(latRad) * cos(asin(sinAlt)));
    var azimuth = acos(cosAz.clamp(-1.0, 1.0)) * 180 / pi;
    
    if (sin(haRad) > 0) {
      azimuth = 360 - azimuth;
    }
    
    return {
      'altitude': altitude,
      'azimuth': azimuth,
    };
  }

  /// Calculate Local Sidereal Time
  double _calculateLST(double longitude, DateTime time) {
    final jd = _calculateJulianDate(time);
    final t = (jd - 2451545.0) / 36525.0;
    
    var lst = 280.46061837 + 
              360.98564736629 * (jd - 2451545.0) + 
              0.000387933 * t * t - 
              t * t * t / 38710000.0;
    
    lst = lst % 360;
    lst = lst + longitude;
    
    if (lst < 0) lst += 360;
    if (lst > 360) lst -= 360;
    
    return lst;
  }

  /// Calculate Julian Date
  double _calculateJulianDate(DateTime time) {
    final y = time.year;
    final m = time.month;
    final d = time.day;
    final h = time.hour + time.minute / 60.0 + time.second / 3600.0;
    
    final a = (14 - m) ~/ 12;
    final y2 = y + 4800 - a;
    final m2 = m + 12 * a - 3;
    
    final jdn = d + (153 * m2 + 2) ~/ 5 + 365 * y2 + 
                y2 ~/ 4 - y2 ~/ 100 + y2 ~/ 400 - 32045;
    
    return jdn + (h - 12) / 24.0;
  }

  /// Check if object is visible (above horizon)
  bool isVisible({
    required double latitude,
    required double longitude,
    required DateTime time,
  }) {
    final coords = getHorizontalCoordinates(
      latitude: latitude,
      longitude: longitude,
      time: time,
    );
    return coords['altitude']! > 0;
  }

  /// Convert horizontal coordinates to screen position
  Offset getScreenPosition({
    required double latitude,
    required double longitude,
    required DateTime time,
    required double deviceAzimuth,
    required double deviceAltitude,
    required Size screenSize,
    required double fieldOfView, // in degrees
  }) {
    final coords = getHorizontalCoordinates(
      latitude: latitude,
      longitude: longitude,
      time: time,
    );
    
    final altitude = coords['altitude']!;
    final azimuth = coords['azimuth']!;
    
    // Calculate relative position to device orientation
    var deltaAzimuth = azimuth - deviceAzimuth;
    if (deltaAzimuth > 180) deltaAzimuth -= 360;
    if (deltaAzimuth < -180) deltaAzimuth += 360;
    
    final deltaAltitude = altitude - deviceAltitude;
    
    // Convert to screen coordinates
    final fovHalf = fieldOfView / 2;
    final x = screenSize.width / 2 + 
              (deltaAzimuth / fovHalf) * (screenSize.width / 2);
    final y = screenSize.height / 2 - 
              (deltaAltitude / fovHalf) * (screenSize.height / 2);
    
    return Offset(x, y);
  }
}

enum CelestialType {
  star,
  planet,
  moon,
  sun,
  constellation,
}

/// Extension to get display properties for celestial types
extension CelestialTypeExtension on CelestialType {
  String get displayName {
    switch (this) {
      case CelestialType.star:
        return 'Star';
      case CelestialType.planet:
        return 'Planet';
      case CelestialType.moon:
        return 'Moon';
      case CelestialType.sun:
        return 'Sun';
      case CelestialType.constellation:
        return 'Constellation';
    }
  }
}