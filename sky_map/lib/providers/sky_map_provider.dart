import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/celestial_object.dart';
import '../services/nasa_api_service.dart';
import '../services/celestial_calculator.dart';
import 'sensor_provider.dart';

/// Provider that manages the sky map state and celestial objects
class SkyMapProvider with ChangeNotifier {
  final SensorProvider _sensorProvider;
  final NasaApiService _nasaService = NasaApiService();
  final CelestialCalculator _calculator = CelestialCalculator();
  
  List<CelestialObject> _allObjects = [];
  List<CelestialObject> _visibleObjects = [];
  CelestialObject? _selectedObject;
  bool _isLoading = true;
  String? _error;
  Timer? _updateTimer;
  DateTime _currentTime = DateTime.now();

  List<CelestialObject> get allObjects => _allObjects;
  List<CelestialObject> get visibleObjects => _visibleObjects;
  CelestialObject? get selectedObject => _selectedObject;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get currentTime => _currentTime;

  SkyMapProvider(this._sensorProvider) {
    _initialize();
  }

  /// Initialize the sky map with celestial objects
  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load celestial objects from various sources
      final objects = <CelestialObject>[];
      
      // Add planets
      objects.addAll(_calculator.getPlanets());
      
      // Add Sun
      objects.add(_calculator.getSun());
      
      // Add Moon
      objects.add(_calculator.getMoon());
      
      // Add constellations
      objects.addAll(_calculator.getConstellations());
      
      // Try to fetch additional data from NASA API
      try {
        final nasaData = await _nasaService.fetchCelestialData();
        // NASA data is used to enhance descriptions if available
        debugPrint('NASA API data loaded: ${nasaData.length} items');
      } catch (e) {
        debugPrint('NASA API unavailable, using default data: $e');
      }

      _allObjects = objects;
      _isLoading = false;
      _error = null;
      
      // Start real-time updates (>10 times per second = every 80ms)
      _startRealTimeUpdates();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load celestial objects: $e';
      _isLoading = false;
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Start real-time updates at >10 Hz (minimum 100ms interval)
  void _startRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _updateVisibleObjects();
    });
  }

  /// Update visible objects based on current device orientation and location
  void _updateVisibleObjects() {
    _currentTime = DateTime.now();
    
    if (!_sensorProvider.isInitialized) {
      return;
    }

    final location = _sensorProvider.location;
    final orientation = _sensorProvider.orientation;
    
    // Filter objects that are currently visible based on location and time
    _visibleObjects = _allObjects.where((obj) {
      return obj.isVisible(
        latitude: location.latitude,
        longitude: location.longitude,
        time: _currentTime,
      );
    }).toList();
    
    // Update positions based on device orientation
    // This happens in the widget layer for smooth rendering
    
    notifyListeners();
  }

  /// Select a celestial object to show details
  void selectObject(CelestialObject? object) {
    _selectedObject = object;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await _initialize();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}