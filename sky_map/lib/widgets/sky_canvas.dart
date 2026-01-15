import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/celestial_object.dart';
import '../providers/sky_map_provider.dart';
import '../providers/sensor_provider.dart';

/// Widget that renders the sky map canvas with celestial objects
class SkyCanvas extends StatelessWidget {
  const SkyCanvas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<SkyMapProvider, SensorProvider>(
      builder: (context, skyMapProvider, sensorProvider, child) {
        return GestureDetector(
          onTapUp: (details) {
            _handleTap(
              context,
              details.localPosition,
              skyMapProvider,
              sensorProvider,
            );
          },
          child: CustomPaint(
            painter: SkyPainter(
              objects: skyMapProvider.visibleObjects,
              location: sensorProvider.location,
              orientation: sensorProvider.orientation,
              currentTime: skyMapProvider.currentTime,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  void _handleTap(
    BuildContext context,
    Offset tapPosition,
    SkyMapProvider skyMapProvider,
    SensorProvider sensorProvider,
  ) {
    final size = MediaQuery.of(context).size;
    
    // Check if tap is near any object
    for (final object in skyMapProvider.visibleObjects) {
      final objectPos = object.getScreenPosition(
        latitude: sensorProvider.location.latitude,
        longitude: sensorProvider.location.longitude,
        time: skyMapProvider.currentTime,
        deviceAzimuth: sensorProvider.orientation.azimuth,
        deviceAltitude: sensorProvider.orientation.altitude,
        screenSize: size,
        fieldOfView: 60.0,
      );

      final distance = (objectPos - tapPosition).distance;
      if (distance < 40) {
        // Tap is near this object
        skyMapProvider.selectObject(object);
        return;
      }
    }
  }
}

/// Custom painter for rendering celestial objects
class SkyPainter extends CustomPainter {
  final List<CelestialObject> objects;
  final dynamic location;
  final dynamic orientation;
  final DateTime currentTime;
  static const double fieldOfView = 60.0; // degrees

  SkyPainter({
    required this.objects,
    required this.location,
    required this.orientation,
    required this.currentTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw black background (space)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    // Draw stars background
    _drawStarField(canvas, size);

    // Draw each celestial object
    for (final object in objects) {
      _drawCelestialObject(canvas, size, object);
    }

    // Draw compass rose
    _drawCompass(canvas, size);
  }

  void _drawStarField(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw random stars for atmosphere
    for (int i = 0; i < 100; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 17.3) % size.height;
      final radius = (i % 3) * 0.5 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawCelestialObject(Canvas canvas, Size size, CelestialObject object) {
    final position = object.getScreenPosition(
      latitude: location.latitude,
      longitude: location.longitude,
      time: currentTime,
      deviceAzimuth: orientation.azimuth,
      deviceAltitude: orientation.altitude,
      screenSize: size,
      fieldOfView: fieldOfView,
    );

    // Only draw if within screen bounds (with margin)
    if (position.dx < -50 ||
        position.dx > size.width + 50 ||
        position.dy < -50 ||
        position.dy > size.height + 50) {
      return;
    }

    // Draw glow effect
    final glowPaint = Paint()
      ..color = object.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(position, object.size * 1.5, glowPaint);

    // Draw main object
    final paint = Paint()
      ..color = object.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, object.size, paint);

    // Draw label
    final textSpan = TextSpan(
      text: object.name,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy + object.size + 5,
      ),
    );

    // Draw type indicator for constellations
    if (object.type == CelestialType.constellation) {
      final iconPaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(position, object.size + 5, iconPaint);
    }
  }

  void _drawCompass(Canvas canvas, Size size) {
    final center = Offset(size.width - 50, 50);
    final radius = 30.0;

    // Draw compass circle
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw north indicator
    final northAngle = -orientation.azimuth * (3.14159 / 180);
    final northEnd = Offset(
      center.dx + radius * 0.8 * (0 * northAngle.cos() - 1 * northAngle.sin()),
      center.dy + radius * 0.8 * (0 * northAngle.sin() + 1 * northAngle.cos()),
    );

    final northPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, northEnd, northPaint);

    // Draw 'N' label
    final textSpan = TextSpan(
      text: 'N',
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        northEnd.dx - textPainter.width / 2,
        northEnd.dy - textPainter.height - 5,
      ),
    );
  }

  @override
  bool shouldRepaint(SkyPainter oldDelegate) {
    return true; // Always repaint for real-time updates
  }
}