class LocationModel {
  final String id;
  final String tripId;
  final String deviceId;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime createdAt;

  LocationModel({
    required this.id,
    required this.tripId,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.createdAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      deviceId: json['device_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] as num? ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'device_id': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
