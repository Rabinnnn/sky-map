/// Represents the device's orientation in 3D space
class DeviceOrientation {
  final double azimuth; // Compass heading (0-360 degrees)
  final double altitude; // Tilt up/down (-90 to 90 degrees)
  final double roll; // Device rotation around its axis

  DeviceOrientation({
    required this.azimuth,
    required this.altitude,
    required this.roll,
  });

  DeviceOrientation.zero()
      : azimuth = 0,
        altitude = 0,
        roll = 0;

  DeviceOrientation copyWith({
    double? azimuth,
    double? altitude,
    double? roll,
  }) {
    return DeviceOrientation(
      azimuth: azimuth ?? this.azimuth,
      altitude: altitude ?? this.altitude,
      roll: roll ?? this.roll,
    );
  }

  @override
  String toString() {
    return 'DeviceOrientation(azimuth: ${azimuth.toStringAsFixed(1)}°, '
           'altitude: ${altitude.toStringAsFixed(1)}°, '
           'roll: ${roll.toStringAsFixed(1)}°)';
  }
}

/// Represents geographic location
class GeoLocation {
  final double latitude;
  final double longitude;
  final double altitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
  });

  GeoLocation.zero()
      : latitude = 0,
        longitude = 0,
        altitude = 0;

  @override
  String toString() {
    return 'GeoLocation(lat: ${latitude.toStringAsFixed(4)}, '
           'lon: ${longitude.toStringAsFixed(4)}, '
           'alt: ${altitude.toStringAsFixed(0)}m)';
  }
}