class LeaveRequestModel {
  final String? id;
  final String? employeeId;
  final String? leaveTypeId;
  final String? startDate;
  final String? endDate;
  final int? totalDays;
  final String? status;
  final String? approverId;
  final String? reason;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  LeaveRequestModel({
    this.id,
    this.employeeId,
    this.leaveTypeId,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.status,
    this.approverId,
    this.reason,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json["id"],
      employeeId: json["employee_id"],
      leaveTypeId: json["leave_type_id"],
      startDate: json["start_date"],
      endDate: json["end_date"],
      totalDays: json["total_days"],
      status: json["status"],
      approverId: json["approver_id"],
      reason: json["reason"],
      approvedAt: json["approved_at"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      deletedAt: json["deleted_at"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "employee_id": employeeId,
    "leave_type_id": leaveTypeId,
    "start_date": startDate,
    "end_date": endDate,
    "total_days": totalDays,
    "status": status,
    "approver_id": approverId,
    "reason": reason,
    "approved_at": approvedAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
  };
}
