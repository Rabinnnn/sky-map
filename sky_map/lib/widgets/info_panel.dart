// widgets/info_panel.dart
import 'package:flutter/material.dart';
import '../models/celestial_object.dart';

class InfoPanel extends StatelessWidget {
  final CelestialObject object;
  const InfoPanel({super.key, required this.object});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(object.name, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(object.type.toUpperCase(), style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          Text(object.description, style: TextStyle(color: Colors.white70)),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          )
        ],
      ),
    );
  }
}
