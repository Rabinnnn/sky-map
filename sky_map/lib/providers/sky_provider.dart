// providers/sky_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/celestial_object.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class SkyProvider extends ChangeNotifier {
  List<CelestialObject> objects = [];
  Position? _position;
  Timer? _timer;
  DateTime _now = DateTime.now().toUtc();

  /// Public getter so UI can access it
  Position? get position => _position;

  /// Computed horizontal coordinates for drawing
  /// map of id -> (azimuth, altitude)
  Map<String, Offset> horCoords = {};

  SkyProvider() {
    _loadObjects();
    _initLocation();
    _startTicker();
  }

  Future<void> _loadObjects() async {
    final data = await rootBundle.loadString('assets/data/objects.json');
    final list = json.decode(data) as List;
    objects = list.map((e) => CelestialObject.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> _initLocation() async {
    try {
      _position = await LocationService.getCurrentPosition();
    } catch (e) {
      // Fallback: Nairobi, Kenya
      _position = Position(
        latitude: -1.286389,
        longitude: 36.817223,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
        isMocked: false,
      );
    }
    notifyListeners();
  }

  void _startTicker() {
    // ~15 FPS (66ms)
    _timer = Timer.periodic(Duration(milliseconds: 66), (_) {
      _now = DateTime.now().toUtc();
      _computeHorizontalCoords();
      notifyListeners();
    });
  }

  void _computeHorizontalCoords() {
    if (_position == null) return;

    final latRad = _degToRad(_position!.latitude);
    final lon = _position!.longitude;

    final lst = _localSiderealTime(_now, lon); // hours

    Map<String, Offset> m = {};
    for (final obj in objects) {
      final raDeg = obj.ra * 15.0; // RA hours → degrees
      final decDeg = obj.dec;

      final haHours = (lst - obj.ra);
      final haDeg = _normDeg(haHours * 15.0); // degrees

      final ha = _degToRad(haDeg);
      final dec = _degToRad(decDeg);

      // altitude
      final sinAlt = math.sin(dec) * math.sin(latRad) +
          math.cos(dec) * math.cos(latRad) * math.cos(ha);

      final alt = math.asin(_clamp(sinAlt, -1.0, 1.0));

      // azimuth
      final cosAz = (math.sin(dec) - math.sin(alt) * math.sin(latRad)) /
          (math.cos(alt) * math.cos(latRad));

      double az = math.acos(_clamp(cosAz, -1, 1));
      if (math.sin(ha) > 0) {
        az = 2 * math.pi - az;
      }

      final altDeg = _radToDeg(alt);
      final azDeg = _radToDeg(az);

      m[obj.id] = Offset(azDeg, altDeg);
    }

    horCoords = m;
  }

  double _degToRad(double d) => d * math.pi / 180.0;
  double _radToDeg(double r) => r * 180.0 / math.pi;

  double _clamp(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  double _normDeg(double deg) {
    double d = deg % 360.0;
    if (d < 0) d += 360.0;
    return d;
  }

  double _localSiderealTime(DateTime utc, double longitude) {
    final jd = _julianDate(utc);
    final jd0 = _julianDay0(utc);
    final H = utc.hour + utc.minute / 60.0 + utc.second / 3600.0;

    final T = (jd - 2451545.0) / 36525.0;

    double GMST = 6.697374558 +
        0.06570982441908 * (jd - 2451545.0) +
        1.00273790935 * H +
        0.000026 * (T * T);

    GMST %= 24.0;
    if (GMST < 0) GMST += 24.0;

    double lst = GMST + longitude / 15.0;
    lst %= 24.0;
    if (lst < 0) lst += 24.0;

    return lst;
  }

  double _julianDate(DateTime utc) {
    final y = utc.year;
    final m = utc.month;
    final d = utc.day +
        (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;

    int yy = y;
    int mm = m;
    if (mm <= 2) {
      yy -= 1;
      mm += 12;
    }

    final A = (yy / 100).floor();
    final B = 2 - A + (A / 4).floor();

    return (365.25 * (yy + 4716)).floor() +
        (30.6001 * (mm + 1)).floor() +
        d +
        B -
        1524.5;
  }

  double _julianDay0(DateTime utc) {
    final dt = DateTime.utc(utc.year, utc.month, utc.day, 0, 0, 0);
    return _julianDate(dt);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
