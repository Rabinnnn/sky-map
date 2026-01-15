import 'package:flutter/material.dart';
import '../models/celestial_object.dart';

class InfoPanel extends StatelessWidget {
  final CelestialObject object;
  const InfoPanel({super.key, required this.object});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(object.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(object.description, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}