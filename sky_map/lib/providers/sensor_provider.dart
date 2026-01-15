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
      // Request permissions and initialize sensors
      final hasPermissions = await _sensorService.requestPermissions();
      
      if (!hasPermissions) {
        _error = 'Location or sensor permissions denied';
        notifyListeners();
        return;
      }

      // Get initial location
      final location = await _sensorService.getCurrentLocation();
      if (location != null) {
        _location = location;
      }

      // Start listening to sensor streams
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
      final location = await _sensorService.getCurrentLocation();
      if (location != null) {
        _location = location;
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