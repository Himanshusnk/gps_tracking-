import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/app_theme.dart';

class MapWidget extends StatefulWidget {
  final List<LatLng> routePoints;
  final LatLng? currentPosition;
  final MapController? mapController;

  const MapWidget({
    super.key,
    required this.routePoints,
    this.currentPosition,
    this.mapController,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
  }

  LatLng _getCenter() {
    if (widget.currentPosition != null) {
      return widget.currentPosition!;
    }
    if (widget.routePoints.isNotEmpty) {
      return widget.routePoints.last;
    }
    // Default fallback to Central Park, NYC
    return const LatLng(40.785091, -73.968285);
  }

  @override
  Widget build(BuildContext context) {
    final center = _getCenter();
    final List<Marker> markers = [];

    // Add Start Marker
    if (widget.routePoints.isNotEmpty) {
      markers.add(
        Marker(
          point: widget.routePoints.first,
          width: 30.0,
          height: 30.0,
          child: const Icon(
            Icons.play_circle_fill,
            color: AppTheme.successColor,
            size: 28,
          ),
        ),
      );
    }

    // Add Current Position Tracker Marker
    if (widget.currentPosition != null) {
      markers.add(
        Marker(
          point: widget.currentPosition!,
          width: 45.0,
          height: 45.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect simulation
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryAccent.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.gps.tracker',
        ),
        if (widget.routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints,
                strokeWidth: 4.5,
                color: AppTheme.primaryAccent,
                borderColor: Colors.white.withOpacity(0.7),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
