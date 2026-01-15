class CelestialObject {
  final String id;
  final String name;
  final double azimuth;
  final double altitude;
  final String description;
  final bool isPlanet;

  CelestialObject({
    required this.id,
    required this.name,
    required this.azimuth,
    required this.altitude,
    required this.description,
    this.isPlanet = false,
  });

  factory CelestialObject.fromJson(String name, Map<String, dynamic> json) {
    // NASA API parsing logic for Azimuth/Elevation
    return CelestialObject(
      id: name.toLowerCase(),
      name: name,
      azimuth: 180.0, // Default placeholders
      altitude: 45.0,
      description: "A celestial body in our solar system.",
      isPlanet: true,
    );
  }
}