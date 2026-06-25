class DeviceModel {
  final String id;
  final String name;
  final String status;
  final DateTime createdAt;

  DeviceModel({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'offline',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
