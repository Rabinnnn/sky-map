# Sky Map Flutter App

A real-time sky map application that displays celestial objects based on your location and device orientation.

## Features

- **Real-time celestial object tracking** - Updates at >10 FPS (80ms intervals)
- **Sensor integration** - Uses GPS, accelerometer, magnetometer, and compass
- **Interactive sky view** - Tap objects to see detailed information
- **Comprehensive catalog** - All planets, Sun, Moon, and major constellations
- **NASA API integration** - Fetches additional celestial data
- **Provider pattern** - Clean state management architecture

## Celestial Objects Included

### Planets
- Mercury
- Venus
- Mars
- Jupiter
- Saturn
- Uranus
- Neptune

### Stars
- Sun

### Satellites
- Moon

### Constellations
- Orion (The Hunter)
- Ursa Major (The Great Bear)
- Cassiopeia
- Scorpius (The Scorpion)

## Technical Implementation

### State Management
The app uses the **Provider pattern** for state management with two main providers:

1. **SensorProvider** - Manages device sensors and orientation
2. **SkyMapProvider** - Manages celestial objects and sky map state

### Sensors Used
- **GPS (Geolocator)** - Determines user's geographic location
- **Accelerometer** - Calculates device tilt (pitch and roll)
- **Magnetometer/Compass** - Determines device heading (azimuth)

### Real-time Updates
- Screen updates occur every 80ms (12.5 times per second)
- Smooth rendering using Flutter's CustomPainter
- Efficient object visibility calculations

### NASA API Integration
The app integrates with multiple NASA APIs:
- Astronomy Picture of the Day (APOD)
- Near Earth Objects (NEO)
- Mars Rover Photos

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio / Xcode for mobile development
- Physical device (recommended for sensor accuracy)

### Installation

1. Clone the repository:
```bash
git clone 
cd sky_map
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml



```

**iOS** (`ios/Runner/Info.plist`):
```xml
NSLocationWhenInUseUsageDescription
This app needs location access to show celestial objects at your location
NSLocationAlwaysUsageDescription
This app needs location access to show celestial objects at your location
```

4. Run the app:
```bash
flutter run
```

## Usage

1. **Grant Permissions** - Allow location access when prompted
2. **Point Your Device** - Hold your device up and point it at the sky
3. **Explore Objects** - The screen will show celestial objects in that direction
4. **Tap for Details** - Tap any object to see detailed information
5. **Navigate** - Move your device around to explore different parts of the sky

### Controls
- **Refresh Button** - Reload celestial data
- **Location Button** - Update your current location
- **Info Button** - Toggle detailed sensor information
- **Visible Counter** - Shows number of currently visible objects

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   ├── celestial_object.dart          # Celestial object model with position calculations
│   └── device_orientation.dart        # Device orientation and location models
├── providers/
│   ├── sky_map_provider.dart          # Sky map state management
│   └── sensor_provider.dart           # Sensor data management
├── services/
│   ├── nasa_api_service.dart          # NASA API integration
│   ├── sensor_service.dart            # Device sensor handling
│   └── celestial_calculator.dart      # Celestial mechanics calculations
├── screens/
│   └── sky_map_screen.dart            # Main screen
└── widgets/
    ├── sky_canvas.dart                # Custom painter for sky rendering
    └── object_detail_dialog.dart      # Object information dialog
```

## Celestial Calculations

The app performs several astronomical calculations:

### Coordinate Systems
- **Equatorial Coordinates** - Right Ascension (RA) and Declination (Dec)
- **Horizontal Coordinates** - Altitude and Azimuth
- **Screen Coordinates** - X and Y positions on device screen

### Key Algorithms
1. **Local Sidereal Time** - Converts observer time to celestial time
2. **Coordinate Transformation** - Converts RA/Dec to Alt/Az based on location
3. **Planetary Positions** - Simplified orbital mechanics for planet positions
4. **Field of View Mapping** - Projects sky coordinates to screen space

## Dependencies

- `provider: ^6.1.1` - State management
- `sensors_plus: ^4.0.2` - Accelerometer access
- `geolocator: ^11.0.0` - GPS location
- `permission_handler: ^11.2.0` - Permission management
- `http: ^1.2.0` - API requests
- `flutter_compass: ^0.8.0` - Compass/magnetometer

## Known Limitations

1. **Planetary Positions** - Uses simplified orbital calculations; not suitable for precise astronomy
2. **NASA API Rate Limits** - Using DEMO_KEY limits requests to 30/hour
3. **Sensor Accuracy** - Accuracy varies by device hardware
4. **Indoor Use** - GPS and compass may be less accurate indoors

## Future Enhancements

- [ ] Add more constellations with star patterns
- [ ] Implement AR camera overlay
- [ ] Add satellite tracking (ISS, etc.)
- [ ] Include meteor shower predictions
- [ ] Add time travel feature (view sky at different times)
- [ ] Implement constellation line drawings
- [ ] Add night mode with red tint
- [ ] Include educational content and tours

## Troubleshooting

### Location not updating
- Ensure location permissions are granted
- Check that location services are enabled on device
- Try the "Location" button to manually refresh

### Objects not appearing
- Make sure device is pointed at sky (altitude > 0°)
- Check that you're outdoors with clear sky view
- Verify internet connection for NASA API data

### Compass inaccurate
- Calibrate device compass by moving in figure-8 pattern
- Keep device away from magnetic interference
- Some devices have less accurate magnetometers

## License

This project is for educational purposes.

## Credits

- NASA API for celestial data
- Flutter team for excellent framework
- Astronomical algorithms based on Jean Meeus' work

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

**Note**: This app requires a physical device with GPS, accelerometer, and magnetometer sensors. Emulators will have limited functionality.