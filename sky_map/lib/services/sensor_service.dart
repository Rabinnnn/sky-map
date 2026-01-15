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

  /// Request necessary permissions with detailed error handling
  Future<bool> requestPermissions() async {
    try {
      debugPrint('Requesting location permissions...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled. Please enable location services.');
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Current location permission: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('Requesting location permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('Permission result: $permission');
      }

      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied by user');
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        // Open app settings for user to manually enable
        await Geolocator.openLocationSettings();
        return false;
      }

      // Additional permission check using permission_handler as backup
      final status = await Permission.location.status;
      if (!status.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          debugPrint('Location permission not granted via permission_handler');
          return false;
        }
      }

      debugPrint('Location permissions granted successfully');
      return true;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  /// Get current location with detailed error handling
  Future<GeoLocation?> getCurrentLocation() async {
    try {
      debugPrint('Getting current location...');
      
      final hasPermission = await Geolocator.isLocationServiceEnabled();
      if (!hasPermission) {
        debugPrint('Location services disabled');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('Location obtained: ${position.latitude}, ${position.longitude}');

      return GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
      );
    } on TimeoutException catch (e) {
      debugPrint('Location timeout: $e');
      return null;
    } on LocationServiceDisabledException catch (e) {
      debugPrint('Location service disabled: $e');
      return null;
    } on PermissionDeniedException catch (e) {
      debugPrint('Location permission denied: $e');
      return null;
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Start listening to sensors
  void startListening() {
    debugPrint('Starting sensor listeners...');
    
    // Listen to accelerometer for device tilt
    _accelerometerSubscription = accelerometerEvents.listen(
      (event) {
        _updateOrientation(event);
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
    );

    // Listen to compass for heading
    final compassStream = FlutterCompass.events;
    if (compassStream != null) {
      _compassSubscription = compassStream.listen(
        (event) {
          if (event.heading != null) {
            _azimuth = event.heading!;
            _publishOrientation();
          }
        },
        onError: (error) {
          debugPrint('Compass error: $error');
        },
      );
    } else {
      debugPrint('Compass not available on this device');
      // Use a default north heading if compass not available
      _azimuth = 0.0;
      _publishOrientation();
    }

    // Listen to location changes
    _startLocationTracking();
    
    debugPrint('Sensor listeners started');
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
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          final location = GeoLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
          );
          
          debugPrint('Location updated: ${location.latitude}, ${location.longitude}');
          
          if (!_locationController.isClosed) {
            _locationController.add(location);
          }
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start location tracking: $e');
    }
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