import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class LocationService {
  final _positionController = StreamController<Position>.broadcast();
  Timer? _simulationTimer;
  int _simulatedIndex = 0;

  // Predefined realistic walking/driving route coordinates in Central Park, NY
  static final List<Map<String, double>> _simulationPath = [
    {'latitude': 40.785091, 'longitude': -73.968285, 'speed': 1.2},
    {'latitude': 40.784550, 'longitude': -73.967520, 'speed': 1.5},
    {'latitude': 40.783920, 'longitude': -73.966950, 'speed': 1.4},
    {'latitude': 40.783450, 'longitude': -73.966450, 'speed': 1.3},
    {'latitude': 40.782800, 'longitude': -73.965800, 'speed': 1.6},
    {'latitude': 40.782100, 'longitude': -73.965100, 'speed': 1.1},
    {'latitude': 40.781500, 'longitude': -73.964500, 'speed': 1.4},
    {'latitude': 40.780900, 'longitude': -73.963900, 'speed': 1.3},
    {'latitude': 40.780300, 'longitude': -73.964300, 'speed': 1.5},
    {'latitude': 40.780000, 'longitude': -73.964900, 'speed': 1.2},
    {'latitude': 40.780500, 'longitude': -73.965600, 'speed': 1.6},
    {'latitude': 40.781200, 'longitude': -73.966300, 'speed': 1.4},
    {'latitude': 40.781900, 'longitude': -73.967000, 'speed': 1.5},
    {'latitude': 40.782600, 'longitude': -73.967700, 'speed': 1.3},
    {'latitude': 40.783300, 'longitude': -73.968400, 'speed': 1.6},
    {'latitude': 40.784000, 'longitude': -73.969100, 'speed': 1.4},
    {'latitude': 40.784600, 'longitude': -73.968900, 'speed': 1.2},
  ];

  /// Stream of location updates (emits simulated positions when simulation is active).
  Stream<Position> get positionStream => _positionController.stream;

  /// Retrieves the current physical location after validating and requesting permissions.
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Starts the simulated coordinates stream.
  void startSimulation({int intervalSeconds = 30}) {
    stopSimulation();
    _simulatedIndex = 0;

    // Immediately trigger a point
    _positionController.add(_getNextSimulatedPoint());

    _simulationTimer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      _positionController.add(_getNextSimulatedPoint());
    });
  }

  /// Stops the simulated coordinates stream.
  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  Position _getNextSimulatedPoint() {
    double lat, lng, speed;

    if (_simulatedIndex < _simulationPath.length) {
      final point = _simulationPath[_simulatedIndex];
      lat = point['latitude']!;
      lng = point['longitude']!;
      speed = point['speed']!;
      _simulatedIndex++;
    } else {
      // Loop the simulation back to the start with minor random noise to keep it running
      final baseIndex = _simulatedIndex % _simulationPath.length;
      final point = _simulationPath[baseIndex];
      final random = math.Random();
      final double latNoise = (random.nextDouble() - 0.5) * 0.0001;
      final double lngNoise = (random.nextDouble() - 0.5) * 0.0001;

      lat = point['latitude']! + latNoise;
      lng = point['longitude']! + lngNoise;
      speed = point['speed']! + (random.nextDouble() - 0.5) * 0.3;
      if (speed < 0.2) speed = 0.2;

      _simulatedIndex++;
    }

    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 10.0,
      heading: 0.0,
      speed: speed,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  /// Cleans up timers and controllers.
  void dispose() {
    stopSimulation();
    _positionController.close();
  }
}
