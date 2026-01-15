import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../models/celestial_object.dart';

class SkyProvider with ChangeNotifier {
  double heading = 0; // Azimuth
  double pitch = 0;   // Altitude
  List<CelestialObject> objects = [];

  SkyProvider() {
    _initSensors();
    _loadInitialData();
  }

  void _initSensors() {
    // Accelerometer & Magnetometer stream for orientation
    magnetometerEvents.listen((MagnetometerEvent event) {
      heading = event.x; // Simplified for this example
      notifyListeners(); // High frequency update (>10fps)
    });
  }

  void _loadInitialData() {
    objects = [
      CelestialObject(id: 'sun', name: 'Sun', azimuth: 100, altitude: 30, description: 'The star at the center of our Solar System.', isPlanet: true),
      CelestialObject(id: 'mars', name: 'Mars', azimuth: 220, altitude: 45, description: 'The Red Planet.', isPlanet: true),
      CelestialObject(id: 'orion', name: 'Orion', azimuth: 50, altitude: 60, description: 'The Hunter constellation.', isPlanet: false),
    ];
    notifyListeners();
  }
}