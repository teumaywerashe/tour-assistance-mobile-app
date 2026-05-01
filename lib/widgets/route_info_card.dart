import 'package:flutter/material.dart';
import '../core/constants.dart';

class RouteInfoCard extends StatelessWidget {
  final double distanceMeters;
  final VoidCallback onClear;

  const RouteInfoCard({
    super.key,
    required this.distanceMeters,
    required this.onClear,
  });

  String get _distance {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }

  String get _walkTime {
    final minutes = (distanceMeters / 80).ceil(); // ~80m/min walking
    if (minutes < 1) return '< 1 min';
    return '$minutes min walk';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, color: AppConstants.accent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_distance, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(_walkTime, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClear,
            tooltip: 'Clear route',
          ),
        ],
      ),
    );
  }
}
