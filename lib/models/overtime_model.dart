// To parse this JSON data, do
//
//     final overtimeModel = overtimeModelFromJson(jsonString);

import 'dart:convert';

OvertimeModel overtimeModelFromJson(String str) =>
    OvertimeModel.fromJson(json.decode(str));

String overtimeModelToJson(OvertimeModel data) => json.encode(data.toJson());

/// Response of GET attendance/overtime — `{ data: [...], pagination: {...} }`
class OvertimeModel {
  final List<OvertimeDatum> data;
  final OvertimePagination pagination;

  OvertimeModel({required this.data, required this.pagination});

  factory OvertimeModel.fromJson(Map<String, dynamic> json) => OvertimeModel(
    data: List<OvertimeDatum>.from(
      (json["data"] ?? []).map(
        (x) => OvertimeDatum.fromJson(Map<String, dynamic>.from(x)),
      ),
    ),
    pagination: OvertimePagination.fromJson(
      Map<String, dynamic>.from(json["pagination"] ?? {}),
    ),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class OvertimePagination {
  final int limit;
  final int page;
  final int total;
  final int totalPages;

  OvertimePagination({
    required this.limit,
    required this.page,
    required this.total,
    required this.totalPages,
  });

  /// The API returns `limit` / `page` as strings, so coerce everything.
  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? "") ?? fallback;
  }

  factory OvertimePagination.fromJson(Map<String, dynamic> json) =>
      OvertimePagination(
        limit: _toInt(json["limit"], 20),
        page: _toInt(json["page"], 1),
        total: _toInt(json["total"]),
        totalPages: _toInt(json["totalPages"], 1),
      );

  Map<String, dynamic> toJson() => {
    "limit": limit,
    "page": page,
    "total": total,
    "totalPages": totalPages,
  };
}

class OvertimeDatum {
  final String id;
  final String employeeId;
  final DateTime? date;
  final int durationMinutes;
  final num overtimeHours;
  final num overtimeAmount;
  final num hourlyRate;
  final num overtimeRate;
  final String reason;
  final dynamic approvedBy;
  final dynamic approvedAt;
  final String status;
  final String employeeName;
  final String employeeCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  OvertimeDatum({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.durationMinutes,
    required this.overtimeHours,
    required this.overtimeAmount,
    required this.hourlyRate,
    required this.overtimeRate,
    required this.reason,
    required this.approvedBy,
    required this.approvedAt,
    required this.status,
    required this.employeeName,
    required this.employeeCode,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  /// Coerce any JSON number/string to num without throwing.
  static num _toNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? "") ?? 0;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory OvertimeDatum.fromJson(Map<String, dynamic> json) => OvertimeDatum(
    id: json["id"]?.toString() ?? "",
    employeeId: json["employee_id"]?.toString() ?? "",
    date: _toDate(json["date"]),
    durationMinutes: _toNum(json["duration_minutes"]).toInt(),
    overtimeHours: _toNum(json["overtime_hours"]),
    overtimeAmount: _toNum(json["overtime_amount"]),
    hourlyRate: _toNum(json["hourly_rate"]),
    overtimeRate: _toNum(json["overtime_rate"]),
    reason: json["reason"]?.toString() ?? "",
    approvedBy: json["approved_by"],
    approvedAt: json["approved_at"],
    status: json["status"]?.toString() ?? "",
    employeeName: json["employee_name"]?.toString() ?? "",
    employeeCode: json["employee_code"]?.toString() ?? "",
    createdAt: _toDate(json["created_at"]),
    updatedAt: _toDate(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "employee_id": employeeId,
    "date": date?.toIso8601String(),
    "duration_minutes": durationMinutes,
    "overtime_hours": overtimeHours,
    "overtime_amount": overtimeAmount,
    "hourly_rate": hourlyRate,
    "overtime_rate": overtimeRate,
    "reason": reason,
    "approved_by": approvedBy,
    "approved_at": approvedAt,
    "status": status,
    "employee_name": employeeName,
    "employee_code": employeeCode,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };

  /// "2h 30m" style label built from `duration_minutes`.
  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h > 0 && m > 0) return "${h}h ${m}m";
    if (h > 0) return "${h}h";
    return "${m}m";
  }
}
