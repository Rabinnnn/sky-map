import 'dart:math';
import 'package:flutter/material.dart';
import '../models/celestial_object.dart';

/// Service for calculating positions and providing data for celestial objects
class CelestialCalculator {
  
  /// Get all planets in the solar system
  List<CelestialObject> getPlanets() {
    final now = DateTime.now();
    return [
      _createMercury(now),
      _createVenus(now),
      _createMars(now),
      _createJupiter(now),
      _createSaturn(now),
      _createUranus(now),
      _createNeptune(now),
    ];
  }

  /// Get the Sun
  CelestialObject getSun() {
    return CelestialObject(
      id: 'sun',
      name: 'Sun',
      type: CelestialType.sun,
      rightAscension: _calculateSunRA(),
      declination: _calculateSunDec(),
      magnitude: -26.74,
      description: 'The Sun is the star at the center of our Solar System. '
          'It is a nearly perfect sphere of hot plasma, with internal convective '
          'motion that generates a magnetic field. It accounts for about 99.86% '
          'of the total mass of the Solar System.',
      color: Colors.yellow,
      size: 30.0,
    );
  }

  /// Get the Moon
  CelestialObject getMoon() {
    return CelestialObject(
      id: 'moon',
      name: 'Moon',
      type: CelestialType.moon,
      rightAscension: _calculateMoonRA(),
      declination: _calculateMoonDec(),
      magnitude: -12.74,
      description: 'Earth\'s only natural satellite. The Moon is the fifth largest '
          'satellite in the Solar System, and the largest relative to its parent planet. '
          'It influences our planet\'s tides and stabilizes Earth\'s axial tilt.',
      color: Colors.grey[300]!,
      size: 25.0,
    );
  }

  /// Get major constellations
  List<CelestialObject> getConstellations() {
    return [
      CelestialObject(
        id: 'orion',
        name: 'Orion',
        type: CelestialType.constellation,
        rightAscension: 5.5, // ~5h 30m
        declination: 5.0,
        magnitude: 0.0,
        description: 'Orion the Hunter is one of the most recognizable constellations '
            'in the night sky. It contains the bright stars Betelgeuse and Rigel, '
            'and the famous Orion\'s Belt asterism. The Orion Nebula (M42) is located '
            'in the "sword" hanging from the belt.',
        color: Colors.blue[200]!,
        size: 15.0,
      ),
      CelestialObject(
        id: 'ursa_major',
        name: 'Ursa Major',
        type: CelestialType.constellation,
        rightAscension: 11.0, // ~11h
        declination: 50.0,
        magnitude: 0.0,
        description: 'Ursa Major (the Great Bear) is a constellation visible throughout '
            'the year in most of the northern hemisphere. It contains the famous asterism '
            'known as the Big Dipper or Plough, which is often used to locate Polaris, '
            'the North Star.',
        color: Colors.blue[200]!,
        size: 15.0,
      ),
      CelestialObject(
        id: 'cassiopeia',
        name: 'Cassiopeia',
        type: CelestialType.constellation,
        rightAscension: 1.0, // ~1h
        declination: 60.0,
        magnitude: 0.0,
        description: 'Cassiopeia is a constellation in the northern sky, named after '
            'the vain queen Cassiopeia in Greek mythology. It is easily recognizable '
            'due to its distinctive W shape, formed by five bright stars.',
        color: Colors.blue[200]!,
        size: 15.0,
      ),
      CelestialObject(
        id: 'scorpius',
        name: 'Scorpius',
        type: CelestialType.constellation,
        rightAscension: 16.5, // ~16h 30m
        declination: -30.0,
        magnitude: 0.0,
        description: 'Scorpius (the Scorpion) is one of the constellations of the zodiac. '
            'Its brightest star is Antares, a red supergiant. The constellation lies between '
            'Libra to the west and Sagittarius to the east, and is best seen in the '
            'summer months in the northern hemisphere.',
        color: Colors.blue[200]!,
        size: 15.0,
      ),
    ];
  }

  // Planet creation methods with simplified orbital calculations
  
  CelestialObject _createMercury(DateTime time) {
    final pos = _calculatePlanetPosition(time, 0.387, 87.97, 48.3);
    return CelestialObject(
      id: 'mercury',
      name: 'Mercury',
      type: CelestialType.planet,
      rightAscension: pos['ra']!,
      declination: pos['dec']!,
      magnitude: -0.42,
      description: 'Mercury is the smallest and innermost planet in the Solar System. '
          'Named after the Roman deity Mercury, it has no atmosphere and its surface '
          'is covered with impact craters, similar to the Moon.',
      color: Colors.grey,
      size: 8.0,
    );
  }

  CelestialObject _createVenus(DateTime time) {
    final pos = _calculatePlanetPosition(time, 0.723, 224.7, 76.7);
    return CelestialObject(
      id: 'venus',
      name: 'Venus',
      type: CelestialType.planet,
      rightAscension: pos['ra']!,
      declination: pos['dec']!,
      magnitude: -4.6,
      description: 'Venus is the second planet from the Sun. Often called Earth\'s twin '
          'due to similar size and mass, it has a thick toxic atmosphere that creates '
          'a runaway greenhouse effect, making it the hottest planet in our Solar System.',
      color: Colors.yellowAccent,
      size: 12.0,
    );
  }

  CelestialObject _createMars(DateTime time) {
    final pos = _calculatePlanetPosition(time, 1.524, 687.0, 49.6);
    return CelestialObject(
      id: 'mars',
      name: 'Mars',
      type: CelestialType.planet,
      rightAscension: pos['ra']!,
      declination: pos['dec']!,
      magnitude: -2.94,
      description: 'Mars is the fourth planet from the Sun, often called the Red Planet '
          'due to iron oxide on its surface. It has two small moons, Phobos and Deimos, '
          'and is a prime target for human exploration.',
      color: Colors.red[700]!,
      size: 10.0,
    );
  }

  CelestialObject _createJupiter(DateTime time) {
    final pos = _calculatePlanetPosition(time, 5.203, 4332.6, 100.5);
    return CelestialObject(
      id: 'jupiter',
      name: 'Jupiter',
      type: CelestialType.planet,
      rightAscension: pos['ra']!,
      declination: pos['dec']!,
      magnitude: -2.94,
      description: 'Jupiter is the largest planet in the Solar System, a gas giant '
          'with a mass more than twice that of all other planets combined. It has '
          '79 known moons including the four large Galilean moons.',
      color: Colors.orange[300]!,
      size: 20.0,
    );
  }

  CelestialObject _createSaturn(DateTime time) {
    final pos = _calculatePlanetPosition(time, 9.537, 10759.2, 113.7);
    return CelestialObject(
      id: 'saturn',
      name: 'Saturn',
      type: CelestialType.planet,
      rightAscension: pos['ra']!,
      declination: pos['dec']!,
      magnitude: 0.46,
      description: 'Saturn is the sixth planet from the Sun and famous for its '
          'spectacular ring system. It is the second-largest planet and has 82 known '
          'moons, with Titan being the largest.',
      color: Colors.amber[200]!,
      size: 18.0,
    );
  }

  CelestialObject _createUranus(DateTime time) {
    final pos = _calculatePlanetPosition(time, 19.19, 30688.5, 74.0);
    return CelestialObject(
      id: 'uranus',
      name: 'Uranus',
      type: CelestialType.planet,
      rightAscension: pos['ra']!,
      declination: pos['dec']!,
      magnitude: 5.68,
      description: 'Uranus is the seventh planet from the Sun and has a unique '
          'sideways rotation. It is an ice giant with a blue-green color due to '
          'methane in its atmosphere.',
      color: Colors.lightBlue[200]!,
      size: 14.0,
    );
  }

  CelestialObject _createNeptune(DateTime time) {
    final pos = _calculatePlanetPosition(time, 30.07, 60182.0, 131.8);
    return CelestialObject(
      id: 'neptune',
      name: 'Neptune',
      type: CelestialType.planet,
      rightAscension: pos['ra']!,
      declination: pos['dec']!,
      magnitude: 7.78,
      description: 'Neptune is the eighth and farthest known planet from the Sun. '
          'It is a dark, cold ice giant with the strongest winds in the Solar System, '
          'reaching speeds of 2,100 km/h.',
      color: Colors.blue[800]!,
      size: 14.0,
    );
  }

  // Simplified celestial mechanics calculations
  
  Map<String, double> _calculatePlanetPosition(
    DateTime time,
    double semiMajorAxis,
    double orbitalPeriod,
    double longitudeOfAscendingNode,
  ) {
    // This is a simplified calculation for demonstration
    // Real planetary positions require complex ephemeris calculations
    
    final daysSinceEpoch = time.difference(DateTime(2000, 1, 1)).inDays.toDouble();
    final meanAnomaly = (360.0 / orbitalPeriod * daysSinceEpoch) % 360.0;
    final meanAnomalyRad = meanAnomaly * pi / 180.0;
    
    // Simplified ecliptic longitude
    final eclipticLongitude = (meanAnomaly + longitudeOfAscendingNode) % 360.0;
    final eclipticLongitudeRad = eclipticLongitude * pi / 180.0;
    
    // Convert to equatorial coordinates (simplified)
    final obliquity = 23.44 * pi / 180.0; // Earth's axial tilt
    
    final ra = atan2(
      sin(eclipticLongitudeRad) * cos(obliquity),
      cos(eclipticLongitudeRad),
    ) * 180 / pi;
    
    final dec = asin(sin(eclipticLongitudeRad) * sin(obliquity)) * 180 / pi;
    
    return {
      'ra': ((ra / 15.0) + 24) % 24, // Convert to hours
      'dec': dec,
    };
  }

  double _calculateSunRA() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    // Simplified calculation
    final angle = (280.0 + dayOfYear * 0.9856) % 360.0;
    return (angle / 15.0) % 24.0;
  }

  double _calculateSunDec() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    // Simplified solar declination
    return -23.44 * cos((360.0 / 365.0) * (dayOfYear + 10) * pi / 180.0);
  }

  double _calculateMoonRA() {
    final now = DateTime.now();
    final daysSinceEpoch = now.difference(DateTime(2000, 1, 1)).inDays;
    // Simplified lunar position (27.3 day orbit)
    final angle = (daysSinceEpoch * 13.176) % 360.0;
    return (angle / 15.0) % 24.0;
  }

  double _calculateMoonDec() {
    final now = DateTime.now();
    final daysSinceEpoch = now.difference(DateTime(2000, 1, 1)).inDays;
    // Simplified lunar declination
    final angle = (daysSinceEpoch * 13.176) % 360.0;
    return 28.5 * sin(angle * pi / 180.0);
  }
}