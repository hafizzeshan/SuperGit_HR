class TeamLeaveRequest {
  final String id;
  final String? employeeId;
  final String? employeeName;
  final String? employeeCode;
  final String? leaveTypeId;
  final String? leaveTypeName;
  final String? startDate;
  final String? endDate;
  final int? totalDays;
  final String? reason;
  final String? status;
  final String? currentApproverId;
  final String? currentApproverName;
  final String? createdAt;

  TeamLeaveRequest({
    required this.id,
    this.employeeId,
    this.employeeName,
    this.employeeCode,
    this.leaveTypeId,
    this.leaveTypeName,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.reason,
    this.status,
    this.currentApproverId,
    this.currentApproverName,
    this.createdAt,
  });

  factory TeamLeaveRequest.fromMap(Map<String, dynamic> map) {
    return TeamLeaveRequest(
      id: map['id']?.toString() ?? '',
      employeeId: map['employee_id']?.toString(),
      employeeName: map['employee_name']?.toString(),
      employeeCode: map['employee_code']?.toString(),
      leaveTypeId: map['leave_type_id']?.toString(),
      leaveTypeName: map['leave_type_name']?.toString(),
      startDate: map['start_date']?.toString(),
      endDate: map['end_date']?.toString(),
      totalDays: (map['total_days'] is num)
          ? (map['total_days'] as num).toInt()
          : int.tryParse('${map['total_days']}'),
      reason: map['reason']?.toString(),
      status: map['status']?.toString(),
      currentApproverId: map['current_approver_id']?.toString(),
      currentApproverName: map['current_approver_name']?.toString(),
      createdAt: map['created_at']?.toString(),
    );
  }

  String get displayName {
    final n = employeeName?.trim() ?? '';
    return n.isEmpty ? "Employee" : n;
  }

  String get initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}
