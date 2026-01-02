import 'dart:convert';

class AttendanceLog {
  final String id;
  final String employeeId;
  final String clockType;
  final DateTime clockTime;
  final String method;
  final String sourceDevice;
  final Location location;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deletedAt;

  AttendanceLog({
    required this.id,
    required this.employeeId,
    required this.clockType,
    required this.clockTime,
    required this.method,
    required this.sourceDevice,
    required this.location,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AttendanceLog.fromMap(Map<String, dynamic> map) {
    return AttendanceLog(
      id: map['id'] ?? '',
      employeeId: map['employee_id'] ?? '',
      clockType: map['clock_type'] ?? '',
      clockTime: DateTime.parse(map['clock_time']),
      method: map['method'] ?? '',
      sourceDevice: map['source_device'] ?? '',
      location: Location.fromMap(map['location'] ?? {}),
      remarks: map['remarks'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      deletedAt: map['deleted_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'clock_type': clockType,
      'clock_time': clockTime.toIso8601String(),
      'method': method,
      'source_device': sourceDevice,
      'location': location.toMap(),
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt,
    };
  }

  static List<AttendanceLog> listFromJson(List<dynamic> list) =>
      list.map((e) => AttendanceLog.fromMap(e)).toList();
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}
