// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sensors_provider.dart';
import 'providers/sky_provider.dart';
import 'widgets/sky_canvas.dart';
import 'widgets/info_panel.dart';
import 'models/celestial_object.dart';

void main() {
  runApp(const SkyMapApp());
}

class SkyMapApp extends StatelessWidget {
  const SkyMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorsProvider()),
        ChangeNotifierProvider(create: (_) => SkyProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sky Map',
        theme: ThemeData.dark(),
        home: const SkyHomePage(),
      ),
    );
  }
}

class SkyHomePage extends StatefulWidget {
  const SkyHomePage({super.key});

  @override
  State<SkyHomePage> createState() => _SkyHomePageState();
}

class _SkyHomePageState extends State<SkyHomePage> {
  CelestialObject? _selected;

  void _onTapObject(CelestialObject obj) {
    setState(() => _selected = obj);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => InfoPanel(object: obj),
    ).then((_) => setState(() => _selected = null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sky Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                title: Text('Notes'),
                content: Text('This demo calculates object positions from RA/Dec values in assets/data/objects.json. For real ephemeris, integrate an ephemeris API (e.g. JPL/HORIZONS or astronomy libraries).'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
              ));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SkyCanvas(onObjectTap: _onTapObject),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black54,
                child: Consumer2<SensorsProvider, SkyProvider>(
                  builder: (_, s, sky, __) {
                    final lat = sky.position?.latitude.toStringAsFixed(4) ?? 'N/A';
                    final lon = sky.position?.longitude.toStringAsFixed(4) ?? 'N/A';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Azimuth: ${s.azimuth.toStringAsFixed(1)}°', style: TextStyle(color: Colors.white)),
                        Text('Pitch: ${s.pitch.toStringAsFixed(1)}°', style: TextStyle(color: Colors.white)),
                        Text('Roll: ${s.roll.toStringAsFixed(1)}°', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 6),
                        Text('Lat: $lat', style: TextStyle(color: Colors.white)),
                        Text('Lon: $lon', style: TextStyle(color: Colors.white)),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
