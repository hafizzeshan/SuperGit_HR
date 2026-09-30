import 'package:flutter/material.dart';

/// Where a remote session sits in the two-tier approval chain.
enum RemoteStatus { pendingTeamLead, pendingAdmin, approved, rejected }

class RemoteWorkEnums {
  /// The service spells statuses several ways (`PENDING_TEAM_LEAD`, `pending`,
  /// `processed`, `inAdminQueue`…), so match loosely on the lower-cased value.
  static RemoteStatus statusFrom(String? raw) {
    final key = (raw ?? '').toLowerCase();
    if (key.contains('reject')) return RemoteStatus.rejected;
    if (key.contains('approved') || key.contains('processed')) {
      return RemoteStatus.approved;
    }
    if (key.contains('admin')) return RemoteStatus.pendingAdmin;
    return RemoteStatus.pendingTeamLead;
  }

  static Color statusColor(RemoteStatus s) => switch (s) {
    RemoteStatus.pendingTeamLead => const Color(0xffE08B00),
    RemoteStatus.pendingAdmin => const Color(0xff0076CE),
    RemoteStatus.approved => const Color(0xff2E9E5B),
    RemoteStatus.rejected => const Color(0xffE05260),
  };

  static IconData statusIcon(RemoteStatus s) => switch (s) {
    RemoteStatus.pendingTeamLead => Icons.hourglass_top_rounded,
    RemoteStatus.pendingAdmin => Icons.fact_check_outlined,
    RemoteStatus.approved => Icons.check_circle_rounded,
    RemoteStatus.rejected => Icons.cancel_rounded,
  };
}

class RemoteLocation {
  final double latitude;
  final double longitude;

  const RemoteLocation({required this.latitude, required this.longitude});

  static RemoteLocation? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final lat = double.tryParse('${raw['latitude']}');
    final lng = double.tryParse('${raw['longitude']}');
    if (lat == null || lng == null) return null;
    return RemoteLocation(latitude: lat, longitude: lng);
  }

  String get short =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}

class RemoteWorkSession {
  final String id;
  final String employeeId;
  final String employeeName;
  final String teamLeadName;
  final DateTime? teamLeadApprovedAt;
  final DateTime? adminApprovedAt;
  final String attendanceLogId;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final RemoteLocation? clockInLocation;
  final RemoteLocation? clockOutLocation;
  final RemoteStatus status;
  final bool autoClockedOut;
  final String remarks;
  final String locationName;

  const RemoteWorkSession({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.teamLeadName,
    required this.attendanceLogId,
    required this.status,
    required this.autoClockedOut,
    required this.remarks,
    required this.locationName,
    this.teamLeadApprovedAt,
    this.adminApprovedAt,
    this.clockInTime,
    this.clockOutTime,
    this.clockInLocation,
    this.clockOutLocation,
  });

  /// A session with no clock-out is the one still running.
  bool get isActive => clockOutTime == null && status != RemoteStatus.rejected;

  Duration? get duration {
    final start = clockInTime, end = clockOutTime;
    if (start == null || end == null) return null;
    final diff = end.difference(start);
    return diff.isNegative ? null : diff;
  }

  bool get isPending =>
      status == RemoteStatus.pendingTeamLead ||
      status == RemoteStatus.pendingAdmin;

  factory RemoteWorkSession.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) => DateTime.tryParse('$v')?.toLocal();

    return RemoteWorkSession(
      id: '${json['id'] ?? ''}',
      employeeId: '${json['employee_id'] ?? ''}',
      employeeName: '${json['employee_name'] ?? ''}',
      teamLeadName: '${json['team_lead_name'] ?? ''}',
      teamLeadApprovedAt: parse(json['team_lead_approved_at']),
      adminApprovedAt: parse(json['admin_approved_at']),
      attendanceLogId: '${json['attendance_log_id'] ?? ''}',
      clockInTime: parse(json['clock_in_time']),
      clockOutTime: parse(json['clock_out_time']),
      clockInLocation: RemoteLocation.fromJson(json['clock_in_location']),
      clockOutLocation: RemoteLocation.fromJson(json['clock_out_location']),
      // `approval_status` mirrors `status`; prefer whichever is present.
      status: RemoteWorkEnums.statusFrom(
        '${json['status'] ?? json['approval_status'] ?? ''}',
      ),
      autoClockedOut: json['auto_clocked_out'] == true,
      remarks: '${json['remarks'] ?? ''}',
      locationName: '${json['location_name'] ?? ''}',
    );
  }
}

/// Which queue an approvals screen is showing.
enum ApprovalMode { teamLead, admin }
