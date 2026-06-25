import 'package:intl/intl.dart';

class Helpers {
  // Format speed from meters per second to kilometers per hour
  static String formatSpeed(double speedMps) {
    double speedKmh = speedMps * 3.6;
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }

  // Format distance into readable meter/kilometer notation
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      double meters = distanceKm * 1000;
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  // Format DateTime to user readable string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  // Format Duration into readable hours/minutes/seconds
  static String formatDuration(DateTime start, DateTime? end) {
    final finalEnd = end ?? DateTime.now();
    final duration = finalEnd.difference(start);
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    }
    return '${duration.inSeconds}s';
  }
}
