import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/device_model.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../widgets/custom_button.dart';
import 'map_screen.dart';

class TrackerScreen extends StatefulWidget {
  final DeviceModel device;

  const TrackerScreen({super.key, required this.device});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final TextEditingController _tripNameController = TextEditingController();
  final LocationService _locationService = LocationService();
  
  bool _isTripActive = false;
  bool _isLoading = false;
  String? _activeTripId;
  StreamSubscription? _gpsSubscription;
  Timer? _gpsTimer;
  int _pointCount = 0;

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _gpsSubscription?.cancel();
    _locationService.dispose();
    _tripNameController.dispose();
    super.dispose();
  }

  Future<void> _toggleTrip() async {
    final supabaseService = context.read<SupabaseService>();

    if (!_isTripActive) {
      // Start Trip
      final name = _tripNameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a trip name')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Check permissions and get initial position first
      final currentPos = await _locationService.getCurrentPosition();
      if (currentPos == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get physical location. Please enable location services and grant permission.')),
          );
        }
        return;
      }

      final tripId = await supabaseService.startTrip(widget.device.id, name);

      if (tripId != null) {
        setState(() {
          _activeTripId = tripId;
          _isTripActive = true;
          _pointCount = 0;
        });

        // Send initial location
        _sendCoordinate(currentPos.latitude, currentPos.longitude, currentPos.speed);

        // Set up periodic timer to ping location updates every 30 seconds
        _gpsTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
          final pos = await _locationService.getCurrentPosition();
          if (pos != null) {
            _sendCoordinate(pos.latitude, pos.longitude, pos.speed);
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initialize trip via Supabase')),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      // End Trip
      if (_activeTripId == null) return;

      setState(() {
        _isLoading = true;
      });

      _gpsTimer?.cancel();
      _gpsTimer = null;
      _gpsSubscription?.cancel();

      final success = await supabaseService.endTrip(_activeTripId!);

      if (success) {
        setState(() {
          _isTripActive = false;
          _activeTripId = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip completed successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error terminating trip session')),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendCoordinate(double lat, double lng, double speed) {
    if (_activeTripId == null) return;
    
    context.read<SupabaseService>().sendLocation(
      tripId: _activeTripId!,
      deviceId: widget.device.id,
      latitude: lat,
      longitude: lng,
      speed: speed,
    );

    setState(() {
      _pointCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device status board
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryBgDark,
                        child: Icon(Icons.router, color: AppTheme.secondaryAccent, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.device.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _isTripActive ? AppTheme.successColor : AppTheme.secondaryAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTripActive ? 'TRANSMITTING' : 'IDLE / READY',
                            style: TextStyle(
                              color: _isTripActive ? AppTheme.successColor : AppTheme.secondaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Trip Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _tripNameController,
                enabled: !_isTripActive,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  hintText: 'e.g. Flight Route A',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_bike),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isTripActive ? 'End Tracking Trip' : 'Start Tracking Trip',
                icon: _isTripActive ? Icons.stop : Icons.play_arrow,
                color: _isTripActive ? AppTheme.errorColor : AppTheme.primaryAccent,
                isLoading: _isLoading,
                onPressed: _toggleTrip,
              ),
              if (_isTripActive) ...[
                const SizedBox(height: 20),
                Card(
                  color: AppTheme.cardBgDark,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Data Points Transmitted:'),
                            Text(
                              '$_pointCount',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryAccent),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        CustomButton(
                          text: 'View Live Map Tracking',
                          icon: Icons.map,
                          color: AppTheme.secondaryAccent,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  tripId: _activeTripId!,
                                  deviceName: widget.device.name,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
