import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

class RouteService {
  /// Calculates the total distance along a path of coordinates in kilometers.
  double calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _distanceBetween(points[i], points[i + 1]);
    }
    return totalDistance;
  }

  /// Calculates the distance between two points in kilometers using the Haversine formula.
  double _distanceBetween(LatLng p1, LatLng p2) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(p2.latitude - p1.latitude);
    final double dLng = _toRadians(p2.longitude - p1.longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(p1.latitude)) *
            math.cos(_toRadians(p2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }
}
