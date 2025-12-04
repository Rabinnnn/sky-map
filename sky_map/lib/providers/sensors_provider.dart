// providers/sensors_provider.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

class SensorsProvider extends ChangeNotifier {
  double azimuth = 0.0; // degrees: 0 = north
  double pitch = 0.0; // device tilt forward/backwards in degrees
  double roll = 0.0; // tilt left/right
  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  SensorsProvider() {
    _start();
  }

  void _start() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        azimuth = event.heading!;
        notifyListeners();
      }
    });

    _accelSub = accelerometerEvents.listen((acc) {
      // compute pitch and roll from accel vector
      final ax = acc.x;
      final ay = acc.y;
      final az = acc.z;
      // pitch: rotation around X axis
      pitch = (math.atan2(-ax, math.sqrt(ay * ay + az * az)) * 180 / math.pi);
      // roll: rotation around Y axis
      roll = (math.atan2(ay, az) * 180 / math.pi);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }
}
