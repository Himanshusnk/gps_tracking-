import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/route_service.dart';
import '../utils/helpers.dart';
import '../widgets/map_widget.dart';

class MapScreen extends StatefulWidget {
  final String tripId;
  final String deviceName;

  const MapScreen({
    super.key,
    required this.tripId,
    required this.deviceName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final RouteService _routeService = RouteService();
  
  final List<LatLng> _points = [];
  LatLng? _currentPosition;
  double _currentSpeed = 0.0;
  double _totalDistance = 0.0;
  
  StreamSubscription? _realtimeSubscription;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    final supabaseService = context.read<SupabaseService>();
    
    // 1. Fetch any existing points first (if mapping an ongoing trip)
    _loadExistingLocations();

    // 2. Subscribe to realtime coordinates updates
    supabaseService.subscribeToLiveTrip(widget.tripId);
    _realtimeSubscription = supabaseService.locationStream.listen((location) {
      final newPoint = LatLng(location.latitude, location.longitude);
      
      setState(() {
        _points.add(newPoint);
        _currentSpeed = location.speed;
        _totalDistance = _routeService.calculateTotalDistance(_points);
      });

      // Move map view smoothly to follow the new live point
      _animatedMapMove(newPoint, _mapController.camera.zoom);
    });
  }

  Future<void> _loadExistingLocations() async {
    final list = await context.read<SupabaseService>().fetchTripLocations(widget.tripId);
    if (list.isNotEmpty) {
      setState(() {
        _points.addAll(list.map((loc) => LatLng(loc.latitude, loc.longitude)));
        _currentPosition = _points.last;
        _currentSpeed = list.last.speed;
        _totalDistance = _routeService.calculateTotalDistance(_points);
      });
      _mapController.move(_currentPosition!, 15.0);
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    _animationController?.dispose(); // Stop any active animation

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final startLat = _currentPosition?.latitude ?? destLocation.latitude;
    final startLng = _currentPosition?.longitude ?? destLocation.longitude;
    final startZoom = _mapController.camera.zoom;

    final latTween = Tween<double>(begin: startLat, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: startLng, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: startZoom, end: destZoom);

    final animation = CurvedAnimation(parent: _animationController!, curve: Curves.fastOutSlowIn);

    _animationController!.addListener(() {
      final currentPoint = LatLng(
        latTween.evaluate(animation),
        lngTween.evaluate(animation),
      );
      setState(() {
        _currentPosition = currentPoint;
      });
      _mapController.move(currentPoint, zoomTween.evaluate(animation));
    });

    _animationController!.forward();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    context.read<SupabaseService>().unsubscribeFromLiveTrip();
    _animationController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking: ${widget.deviceName}'),
      ),
      body: Stack(
        children: [
          // Base OSM Map
          MapWidget(
            routePoints: _points,
            currentPosition: _currentPosition,
            mapController: _mapController,
          ),
          
          // Telemetry Floating Panel
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              color: AppTheme.primaryBgDark.withOpacity(0.95),
              elevation: 8,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.secondaryAccent.withOpacity(0.3), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTelemetryColumn(
                      icon: Icons.speed,
                      label: 'LIVE SPEED',
                      value: Helpers.formatSpeed(_currentSpeed),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white12,
                    ),
                    _buildTelemetryColumn(
                      icon: Icons.navigation_outlined,
                      label: 'DISTANCE',
                      value: Helpers.formatDistance(_totalDistance),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white12,
                    ),
                    _buildTelemetryColumn(
                      icon: Icons.pin_drop,
                      label: 'PING SENSORS',
                      value: '${_points.length}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.secondaryAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondaryDark,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
