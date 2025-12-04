// widgets/sky_canvas.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensors_provider.dart';
import '../providers/sky_provider.dart';
import '../models/celestial_object.dart';

typedef ObjectTapCallback = void Function(CelestialObject obj);

class SkyCanvas extends StatefulWidget {
  final ObjectTapCallback onObjectTap;

  const SkyCanvas({super.key, required this.onObjectTap});

  @override
  State<SkyCanvas> createState() => _SkyCanvasState();
}

class _SkyCanvasState extends State<SkyCanvas> {
  // maintain a simple map of drawn positions (id -> center)
  Map<String, Offset> _screenPositions = {};

  @override
  Widget build(BuildContext context) {
    final sensors = Provider.of<SensorsProvider>(context);
    final sky = Provider.of<SkyProvider>(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final pos = details.localPosition;
        String? hitId;
        double minDist = double.infinity;
        sky.objects.forEach((obj) {
          final center = _screenPositions[obj.id];
          if (center == null) return;
          final d = (center - pos).distance;
          if (d < minDist) {
            minDist = d;
            hitId = obj.id;
          }
        });
        if (hitId != null && minDist < 30.0) {
          final obj = sky.objects.firstWhere((o) => o.id == hitId);
          widget.onObjectTap(obj);
        }
      },
      child: CustomPaint(
        painter: _SkyPainter(
          sensorsAzimuth: sensors.azimuth,
          sensorsPitch: sensors.pitch,
          horCoords: sky.horCoords,
          objects: sky.objects,
          onPositionsCalculated: (map) {
            _screenPositions = map;
          },
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double sensorsAzimuth;
  final double sensorsPitch;
  final Map<String, Offset> horCoords; // id -> (az, alt) in degrees
  final List<CelestialObject> objects;
  final void Function(Map<String, Offset>) onPositionsCalculated;

  _SkyPainter({
    required this.sensorsAzimuth,
    required this.sensorsPitch,
    required this.horCoords,
    required this.objects,
    required this.onPositionsCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) * 0.48;
    final paint = Paint()..style = PaintingStyle.fill;
    // draw black background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint..color = Colors.black);

    // draw horizon circle
    paint.color = Colors.grey.shade800;
    canvas.drawCircle(center, radius, paint);

    // draw grid / cardinal points for orientation
    final textPainter = (String txt) {
      final tp = TextPainter(
        text: TextSpan(text: txt, style: TextStyle(color: Colors.white70, fontSize: 12)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      return tp;
    };

    // N,E,S,W positions (based on device azimuth)
    final headings = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    headings.forEach((label, az) {
      final relative = (az - sensorsAzimuth) * math.pi / 180.0;
      final dx = center.dx + radius * math.sin(relative);
      final dy = center.dy - radius * math.cos(relative);
      final tp = textPainter(label);
      tp.paint(canvas, Offset(dx - tp.width / 2, dy - tp.height / 2));
    });

    // draw each celestial object: project az/alt to screen
    Map<String, Offset> positions = {};
    for (final obj in objects) {
      final coords = horCoords[obj.id];
      if (coords == null) continue;
      final az = coords.dx; // degrees
      final alt = coords.dy; // degrees
      if (alt < -5.0) {
        // object below horizon: skip or dim
        continue;
      }
      // compute relative az to device heading
      double relAzDeg = _normalizeAngle(az - sensorsAzimuth); // -180..+180
      // map horizontal coordinates to screen:
      // x: relative az maps to [-radius, +radius] (full width ~ 180 deg)
      // y: altitude 0..90 maps to center..top
      final x = center.dx + (relAzDeg / 90.0) * radius; // 90 deg -> radius
      final y = center.dy - (alt / 90.0) * radius;
      final point = Offset(x, y);
      // draw dot size influenced by magnitude (smaller magnitude -> brighter -> larger)
      double size = _sizeFromMagnitude(obj.magnitude);
      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(point, size, dotPaint);
      // label small
      final tp = TextPainter(
        text: TextSpan(text: obj.name, style: TextStyle(color: Colors.white70, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(point.dx + size + 4, point.dy - tp.height / 2));
      positions[obj.id] = point;
    }

    onPositionsCalculated(positions);
  }

  double _sizeFromMagnitude(double mag) {
    // simplistic mapping: brighter -> larger
    if (mag <= -4) return 8.0;
    if (mag <= -1) return 6.0;
    if (mag <= 1) return 4.5;
    if (mag <= 4) return 3.0;
    return 2.0;
  }

  double _normalizeAngle(double a) {
    double v = a % 360.0;
    if (v > 180.0) v -= 360.0;
    if (v < -180.0) v += 360.0;
    return v;
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) {
    return old.sensorsAzimuth != sensorsAzimuth ||
        old.sensorsPitch != sensorsPitch ||
        old.horCoords != horCoords;
  }
}
