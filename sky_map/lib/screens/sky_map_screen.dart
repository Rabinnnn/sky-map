import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sky_map_provider.dart';
import '../providers/sensor_provider.dart';
import '../widgets/sky_canvas.dart';
import '../widgets/object_detail_dialog.dart';

/// Main screen displaying the sky map
class SkyMapScreen extends StatefulWidget {
  const SkyMapScreen({Key? key}) : super(key: key);

  @override
  State<SkyMapScreen> createState() => _SkyMapScreenState();
}

class _SkyMapScreenState extends State<SkyMapScreen> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Sky canvas with celestial objects
            Consumer2<SkyMapProvider, SensorProvider>(
              builder: (context, skyMapProvider, sensorProvider, child) {
                if (skyMapProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading celestial objects...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }

                if (skyMapProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            skyMapProvider.error!,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => skyMapProvider.refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!sensorProvider.isInitialized) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          sensorProvider.error ?? 'Initializing sensors...',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return const SkyCanvas();
              },
            ),

            // Top info bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Consumer<SensorProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sky Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showInfo ? Icons.info : Icons.info_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showInfo = !_showInfo;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_showInfo) ...[
                          const SizedBox(height: 8),
                          _buildInfoText(
                            'Location: ${provider.location.latitude.toStringAsFixed(2)}°, '
                            '${provider.location.longitude.toStringAsFixed(2)}°',
                          ),
                          _buildInfoText(
                            'Azimuth: ${provider.orientation.azimuth.toStringAsFixed(0)}°',
                          ),
                          _buildInfoText(
                            'Altitude: ${provider.orientation.altitude.toStringAsFixed(0)}°',
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Point your device at the sky to see celestial objects',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Consumer<SkyMapProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.refresh,
                          label: 'Refresh',
                          onPressed: () => provider.refresh(),
                        ),
                        _buildControlButton(
                          icon: Icons.my_location,
                          label: 'Location',
                          onPressed: () {
                            context.read<SensorProvider>().refreshLocation();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Updating location...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        _buildObjectCounter(provider.visibleObjects.length),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Selected object detail
            Consumer<SkyMapProvider>(
              builder: (context, provider, child) {
                if (provider.selectedObject != null) {
                  return ObjectDetailDialog(
                    object: provider.selectedObject!,
                    onClose: () => provider.selectObject(null),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
          iconSize: 28,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildObjectCounter(int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Visible',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}