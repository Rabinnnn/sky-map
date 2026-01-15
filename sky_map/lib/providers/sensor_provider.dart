import 'package:flutter/foundation.dart';
import '../models/device_orientation.dart';
import '../services/sensor_service.dart';

/// Provider that manages sensor data and device orientation
class SensorProvider with ChangeNotifier {
  final SensorService _sensorService = SensorService();
  
  DeviceOrientation _orientation = DeviceOrientation.zero();
  GeoLocation _location = GeoLocation.zero();
  bool _isInitialized = false;
  String? _error;

  DeviceOrientation get orientation => _orientation;
  GeoLocation get location => _location;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  SensorProvider() {
    _initialize();
  }

  /// Initialize sensors and start listening
  Future<void> _initialize() async {
    try {
      debugPrint('Initializing sensor provider...');
      
      // Request permissions and initialize sensors
      final hasPermissions = await _sensorService.requestPermissions();
      
      if (!hasPermissions) {
        _error = 'Location permissions are required. Please enable location access in your device settings.';
        debugPrint(_error);
        notifyListeners();
        return;
      }

      debugPrint('Permissions granted, getting initial location...');

      // Get initial location
      final location = await _sensorService.getCurrentLocation();
      if (location != null) {
        _location = location;
        debugPrint('Initial location set: ${location.latitude}, ${location.longitude}');
      } else {
        // Use default location if can't get current location
        _location = GeoLocation(latitude: 0.0, longitude: 0.0);
        debugPrint('Using default location');
      }

      // Start listening to sensor streams
      debugPrint('Starting sensor streams...');
      _sensorService.startListening();
      
      _sensorService.orientationStream.listen((orientation) {
        _orientation = orientation;
        notifyListeners();
      }, onError: (error) {
        debugPrint('Orientation error: $error');
      });

      _sensorService.locationStream.listen((location) {
        _location = location;
        notifyListeners();
      }, onError: (error) {
        debugPrint('Location error: $error');
      });

      _isInitialized = true;
      _error = null;
      debugPrint('Sensor provider initialized successfully');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize sensors: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Manually refresh location
  Future<void> refreshLocation() async {
    try {
      debugPrint('Refreshing location...');
      final location = await _sensorService.getCurrentLocation();
      if (location != null) {
        _location = location;
        debugPrint('Location refreshed: ${location.latitude}, ${location.longitude}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to refresh location: $e');
    }
  }

  @override
  void dispose() {
    _sensorService.dispose();
    super.dispose();
  }
}