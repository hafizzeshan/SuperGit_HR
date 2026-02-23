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
  final String? documentUrl;
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
    this.documentUrl,
    this.updatedAt,
    this.deletedAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json["id"]?.toString(),
      employeeId: json["employee_id"]?.toString(),
      leaveTypeId: json["leave_type_id"]?.toString(),
      startDate: json["start_date"]?.toString(),
      endDate: json["end_date"]?.toString(),
      totalDays: json["total_days"] is int
          ? json["total_days"]
          : int.tryParse(json["total_days"]?.toString() ?? ""),
      status: json["status"]?.toString(),
      approverId: json["approver_id"]?.toString(),
      reason: json["reason"]?.toString(),
      approvedAt: json["approved_at"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      documentUrl: json["document_url"]?.toString(),
      updatedAt: json["updated_at"]?.toString(),
      deletedAt: json["deleted_at"]?.toString(),
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
    "document_url": documentUrl,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
  };
}
