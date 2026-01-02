class DepartmentResponse {
  final List<Department> data;
  final String message;
  final int page;
  final int perPage;
  final int totalPages;
  final int totalRecords;

  DepartmentResponse({
    required this.data,
    required this.message,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalRecords,
  });

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] ?? '',
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      totalRecords: json['total_records'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data.map((e) => e.toJson()).toList(),
      "message": message,
      "page": page,
      "per_page": perPage,
      "total_pages": totalPages,
      "total_records": totalRecords,
    };
  }
}

class Department {
  final String? id;
  final int? branchId;
  final int? businessId;
  final String? nameAr;
  final String? nameEn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Department({
    this.id,
    this.branchId,
    this.businessId,
    this.nameAr,
    this.nameEn,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to parse JSON safely
  factory Department.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Department();
    return Department(
      id: json["id"] as String?,
      branchId: json["branch_id"] is int ? json["branch_id"] : null,
      businessId: json["business_id"] is int ? json["business_id"] : null,
      nameAr: json["name_ar"] as String?,
      nameEn: json["name_en"] as String?,
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"].toString())
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"].toString())
          : null,
    );
  }

  /// Convert to JSON (payload for API) safely
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "branch_id": branchId,
      "business_id": businessId,
      "name_ar": nameAr,
      "name_en": nameEn,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }
}

class Doctor {
  final String id;
  final String name;
  final String practitionerId;
  final String role;
  final String roomNo;
  final String wardNo;
  final String license;
  final String documentId;
  final int userId;
  final int rcmRef;
  final String lastUpdatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Department? department;
  final Speciality? speciality;
  final List<Nurse> assignedNurses;
  final List<DoctorSchedule> schedule;

  Doctor({
    required this.id,
    required this.name,
    required this.practitionerId,
    required this.role,
    required this.roomNo,
    required this.wardNo,
    required this.license,
    required this.documentId,
    required this.userId,
    required this.rcmRef,
    required this.lastUpdatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.department,
    this.speciality,
    required this.assignedNurses,
    required this.schedule,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["_id"] ?? "",
      name: json["name"] ?? "Doctor Name",
      practitionerId: json["practitioner_id"] ?? "",
      role: json["role"] ?? "",
      roomNo: json["room_no"] ?? "",
      wardNo: json["ward_no"] ?? "",
      license: json["license"] ?? "",
      documentId: json["document_id"] ?? "",
      userId: json["user_id"] ?? 0,
      rcmRef: json["rcm_ref"] ?? 0,
      lastUpdatedBy: json["last_updated_by"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),
      department: json["department"] != null
          ? Department.fromJson(json["department"])
          : null,
      speciality: json["speciality"] != null
          ? Speciality.fromJson(json["speciality"])
          : null,
      assignedNurses: (json["assigned_nurses"] as List<dynamic>? ?? [])
          .map((e) => Nurse.fromJson(e))
          .toList(),
      schedule: (json["schedule"] as List<dynamic>? ?? [])
          .map((e) => DoctorSchedule.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "practitioner_id": practitionerId,
      "role": role,
      "room_no": roomNo,
      "ward_no": wardNo,
      "license": license,
      "document_id": documentId,
      "user_id": userId,
      "rcm_ref": rcmRef,
      "last_updated_by": lastUpdatedBy,
      "createdAt": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "department": department?.toJson(),
      "speciality": speciality?.toJson(),
      "assigned_nurses": assignedNurses.map((e) => e.toJson()).toList(),
      "schedule": schedule.map((e) => e.toJson()).toList(),
    };
  }
}

class DoctorSchedule {
  final String day;
  final int interval;
  final int limit;
  final String status;
  final List<Shift> shifts;

  DoctorSchedule({
    required this.day,
    required this.interval,
    required this.limit,
    required this.status,
    required this.shifts,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      day: json["day"] ?? "",
      interval: json["interval"] ?? 0,
      limit: json["limit"] ?? 0,
      status: json["status"] ?? "",
      shifts: (json["shifts"] as List<dynamic>? ?? [])
          .map((e) => Shift.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "day": day,
      "interval": interval,
      "limit": limit,
      "status": status,
      "shifts": shifts.map((e) => e.toJson()).toList(),
    };
  }
}

class Shift {
  final String id;
  final String title;
  final String status;
  final String startTime;
  final String endTime;

  Shift({
    required this.id,
    required this.title,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json["_id"] ?? "",
      title: json["title"] ?? "",
      status: json["status"] ?? "",
      startTime: json["timing"]?["start_time"] ?? "",
      endTime: json["timing"]?["end_time"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "status": status,
      "timing": {"start_time": startTime, "end_time": endTime},
    };
  }
}

class Nurse {
  final String name;
  final String nurseId;
  final String role;
  final String roomNo;
  final String wardNo;

  Nurse({
    required this.name,
    required this.nurseId,
    required this.role,
    required this.roomNo,
    required this.wardNo,
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      name: json["name"] ?? "",
      nurseId: json["nurse_id"] ?? "",
      role: json["role"] ?? "",
      roomNo: json["room_no"] ?? "",
      wardNo: json["ward_no"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "nurse_id": nurseId,
      "role": role,
      "room_no": roomNo,
      "ward_no": wardNo,
    };
  }
}

class Speciality {
  final String? id;
  final int? branchId;
  final int? businessId;
  final String? departmentId;
  final String? description;
  final String? nameAr;
  final String? nameEn;
  final int? rcmRef;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Speciality({
    this.id,
    this.branchId,
    this.businessId,
    this.departmentId,
    this.description,
    this.nameAr,
    this.nameEn,
    this.rcmRef,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create from JSON
  factory Speciality.fromJson(Map<String, dynamic> json) {
    return Speciality(
      id: json["_id"] as String?,
      branchId: json["branch_id"] as int?,
      businessId: json["business_id"] as int?,
      departmentId: json["department_id"] as String?,
      description: json["description"] as String?,
      nameAr: json["name_ar"] as String?,
      nameEn: json["name_en"] as String?,
      rcmRef: json["rcm_ref"] as int?,
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"])
          : null,
    );
  }

  /// Convert to JSON (payload for API)
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "branch_id": branchId,
      "business_id": businessId,
      "department_id": departmentId,
      "description": description,
      "name_ar": nameAr,
      "name_en": nameEn,
      "rcm_ref": rcmRef,
      "updated_at": updatedAt!.toIso8601String(),
    };
  }
}
