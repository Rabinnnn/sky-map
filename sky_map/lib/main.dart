import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/sky_map_provider.dart';
import 'providers/sensor_provider.dart';
import 'screens/sky_map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations and UI overlays
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const SkyMapApp());
}

class SkyMapApp extends StatelessWidget {
  const SkyMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProxyProvider<SensorProvider, SkyMapProvider>(
          create: (context) => SkyMapProvider(
            Provider.of<SensorProvider>(context, listen: false),
          ),
          update: (context, sensorProvider, previous) =>
              previous ?? SkyMapProvider(sensorProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Sky Map',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Colors.blue,
            secondary: Colors.lightBlue,
          ),
        ),
        home: const SkyMapScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}