import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/device_orientation.dart';

/// Service that handles device sensors (GPS, accelerometer, magnetometer)
class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;

  final _orientationController = StreamController<DeviceOrientation>.broadcast();
  final _locationController = StreamController<GeoLocation>.broadcast();

  Stream<DeviceOrientation> get orientationStream => _orientationController.stream;
  Stream<GeoLocation> get locationStream => _locationController.stream;

  double _pitch = 0.0; // Device tilt forward/backward
  double _roll = 0.0;  // Device tilt left/right
  double _azimuth = 0.0; // Compass heading

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    try {
      // Request location permission
      final locationPermission = await Permission.location.request();
      
      if (!locationPermission.isGranted) {
        debugPrint('Location permission denied');
        return false;
      }

      // Sensor permissions are usually granted by default on mobile
      return true;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  /// Get current location
  Future<GeoLocation?> getCurrentLocation() async {
    try {
      final hasPermission = await Geolocator.isLocationServiceEnabled();
      if (!hasPermission) {
        debugPrint('Location services disabled');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
      );
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Start listening to sensors
  void startListening() {
    // Listen to accelerometer for device tilt
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _updateOrientation(event);
    });

    // Listen to compass for heading
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _azimuth = event.heading!;
        _publishOrientation();
      }
    });

    // Listen to location changes
    _startLocationTracking();
  }

  /// Update device orientation from accelerometer data
  void _updateOrientation(AccelerometerEvent event) {
    // Calculate pitch (tilt forward/backward)
    _pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) * 180 / pi;
    
    // Calculate roll (tilt left/right)
    _roll = atan2(event.x, sqrt(event.y * event.y + event.z * event.z)) * 180 / pi;
    
    _publishOrientation();
  }

  /// Publish current orientation
  void _publishOrientation() {
    // Convert pitch to altitude (looking up is positive)
    final altitude = -_pitch;
    
    final orientation = DeviceOrientation(
      azimuth: _azimuth,
      altitude: altitude,
      roll: _roll,
    );
    
    if (!_orientationController.isClosed) {
      _orientationController.add(orientation);
    }
  }

  /// Start tracking location continuously
  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final location = GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
      );
      
      if (!_locationController.isClosed) {
        _locationController.add(location);
      }
    }, onError: (error) {
      debugPrint('Location stream error: $error');
    });
  }

  /// Dispose resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    _orientationController.close();
    _locationController.close();
  }
}