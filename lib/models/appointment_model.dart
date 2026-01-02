// To parse this JSON data, do
//
//     final appointmentModel = appointmentModelFromJson(jsonString);

import 'dart:convert';

import 'package:supergithr/models/departmentModel.dart';

AppointmentModel appointmentModelFromJson(String str) =>
    AppointmentModel.fromJson(json.decode(str));

String appointmentModelToJson(AppointmentModel data) =>
    json.encode(data.toJson());

class AppointmentModel {
  final List<AppointmentDatum>? data;
  final FiltersApplied? filtersApplied;
  final String? message;
  final int? page;
  final String? patientId;
  final int? perPage;
  final int? totalPages;
  final int? totalRecords;

  AppointmentModel({
    this.data,
    this.filtersApplied,
    this.message,
    this.page,
    this.patientId,
    this.perPage,
    this.totalPages,
    this.totalRecords,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        data:
            json["data"] == null
                ? []
                : List<AppointmentDatum>.from(
                  json["data"]!.map((x) => AppointmentDatum.fromJson(x)),
                ),
        filtersApplied:
            json["filters_applied"] == null
                ? null
                : FiltersApplied.fromJson(json["filters_applied"]),
        message: json["message"],
        page: json["page"],
        patientId: json["patient_id"],
        perPage: json["per_page"],
        totalPages: json["total_pages"],
        totalRecords: json["total_records"],
      );

  Map<String, dynamic> toJson() => {
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "filters_applied": filtersApplied?.toJson(),
    "message": message,
    "page": page,
    "patient_id": patientId,
    "per_page": perPage,
    "total_pages": totalPages,
    "total_records": totalRecords,
  };
}

class AppointmentDatum {
  final String? appointmentId;
  final DateTime? appointmentDate;
  final String? startTime;
  final String? endTime;
  final String? day;
  final Department? department;
  final Speciality? speciality;
  final Patient? patient;
  final Practitioner? practitioner;
  final String? note;
  final String? orderNo;
  final String? status;
  final int? businessId;
  final int? branchId;
  final String? createdBy;
  final String? lastUpdatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppointmentDatum({
    this.appointmentId,
    this.appointmentDate,
    this.startTime,
    this.endTime,
    this.day,
    this.department,
    this.speciality,
    this.patient,
    this.practitioner,
    this.note,
    this.orderNo,
    this.status,
    this.businessId,
    this.branchId,
    this.createdBy,
    this.lastUpdatedBy,
    this.createdAt,
    this.updatedAt,
  });
  AppointmentDatum copyWith({
    String? appointmentId,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    String? day,
    Department? department,
    Speciality? speciality,
    Patient? patient,
    Practitioner? practitioner,
    String? note,
    String? orderNo,
    String? status,
    int? businessId,
    int? branchId,
    String? createdBy,
    String? lastUpdatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentDatum(
      appointmentId: appointmentId ?? this.appointmentId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      day: day ?? this.day,
      department: department ?? this.department,
      speciality: speciality ?? this.speciality,
      patient: patient ?? this.patient,
      practitioner: practitioner ?? this.practitioner,
      note: note ?? this.note,
      orderNo: orderNo ?? this.orderNo,
      status: status ?? this.status,
      businessId: businessId ?? this.businessId,
      branchId: branchId ?? this.branchId,
      createdBy: createdBy ?? this.createdBy,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppointmentDatum.fromJson(
    Map<String, dynamic> json,
  ) => AppointmentDatum(
    appointmentId: json["appointment_id"],
    appointmentDate:
        json["appointment_date"] == null
            ? null
            : DateTime.parse(json["appointment_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    day: json["day"],
    department:
        json["department"] == null
            ? null
            : Department.fromJson(json["department"]),
    speciality:
        json["speciality"] == null
            ? null
            : Speciality.fromJson(json["speciality"]),
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    practitioner:
        json["practitioner"] == null
            ? null
            : Practitioner.fromJson(json["practitioner"]),
    note: json["note"],
    orderNo: json["order_no"],
    status: json["status"],
    businessId: json["business_id"],
    branchId: json["branch_id"],
    createdBy: json["created_by"],
    lastUpdatedBy: json["last_updated_by"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "appointment_id": appointmentId,
    "appointment_date":
        "${appointmentDate!.year.toString().padLeft(4, '0')}-${appointmentDate!.month.toString().padLeft(2, '0')}-${appointmentDate!.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "day": day,
    "department": department?.toJson(),
    "speciality": speciality?.toJson(),
    "patient": patient?.toJson(),
    "practitioner": practitioner?.toJson(),
    "note": note,
    "order_no": orderNo,
    "status": status,
    "business_id": businessId,
    "branch_id": branchId,
    "created_by": createdBy,
    "last_updated_by": lastUpdatedBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Patient {
  final String? patientId;
  final String? fullName;
  final String? rcmRef;
  final String? erpRef;
  final int? userId;
  final String? maternity;
  final String? martialStatus;
  final String? gender;
  final String? documentId;
  final String? visaNo;
  final String? fileNo;
  final int? mrn;
  final String? beneficiaryType;
  final int? businessId;
  final int? branchId;
  final String? city;
  final String? residencyType;
  final dynamic insurancePlans;
  final dynamic guarantors;
  final dynamic emergencyContacts;
  final String? address;
  final String? visaType;
  final String? visaTitle;
  final String? documentType;
  final String? passportNo;
  final String? insuranceDuration;
  final String? borderNo;
  final String? dob;
  final String? contact;
  final String? nationality;
  final String? profession;
  final String? religion;
  final String? subscriberId;
  final String? subscriberRelationship;
  final dynamic subscriberInsurancePlan;
  final bool? isNewBorn;
  final String? password;
  final String? email;
  final bool? userLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    this.patientId,
    this.fullName,
    this.rcmRef,
    this.erpRef,
    this.userId,
    this.maternity,
    this.martialStatus,
    this.gender,
    this.documentId,
    this.visaNo,
    this.fileNo,
    this.mrn,
    this.beneficiaryType,
    this.businessId,
    this.branchId,
    this.city,
    this.residencyType,
    this.insurancePlans,
    this.guarantors,
    this.emergencyContacts,
    this.address,
    this.visaType,
    this.visaTitle,
    this.documentType,
    this.passportNo,
    this.insuranceDuration,
    this.borderNo,
    this.dob,
    this.contact,
    this.nationality,
    this.profession,
    this.religion,
    this.subscriberId,
    this.subscriberRelationship,
    this.subscriberInsurancePlan,
    this.isNewBorn,
    this.password,
    this.email,
    this.userLogin,
    this.createdAt,
    this.updatedAt,
  });

  /// Utility method to clean string values
  static String? _cleanString(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return value.toString().trim();
  }

  /// Utility method to clean int values
  static int? _cleanInt(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return null;
    return int.tryParse(value.toString());
  }

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    patientId: _cleanString(json["patient_id"]),
    fullName: _cleanString(json["full_name"]),
    rcmRef: _cleanString(json["rcm_ref"]),
    erpRef: _cleanString(json["erp_ref"]),
    userId: _cleanInt(json["user_id"]),
    maternity: _cleanString(json["maternity"]),
    martialStatus: _cleanString(json["martial_status"]),
    gender: _cleanString(json["gender"]),
    documentId: _cleanString(json["document_id"]),
    visaNo: _cleanString(json["visa_no"]),
    fileNo: _cleanString(json["file_no"]),
    mrn: _cleanInt(json["mrn"]),
    beneficiaryType: _cleanString(json["beneficiary_type"]),
    businessId: _cleanInt(json["business_id"]),
    branchId: _cleanInt(json["branch_id"]),
    city: _cleanString(json["city"]),
    residencyType: _cleanString(json["residency_type"]),
    insurancePlans: json["insurance_plans"],
    guarantors: json["guarantors"],
    emergencyContacts: json["emergency_contacts"],
    address: _cleanString(json["address"]),
    visaType: _cleanString(json["visa_type"]),
    visaTitle: _cleanString(json["visa_title"]),
    documentType: _cleanString(json["document_type"]),
    passportNo: _cleanString(json["passport_no"]),
    insuranceDuration: _cleanString(json["insurance_duration"]),
    borderNo: _cleanString(json["border_no"]),
    dob: _cleanString(json["dob"]),
    contact: _cleanString(json["contact"]),
    nationality: _cleanString(json["nationality"]),
    profession: _cleanString(json["profession"]),
    religion: _cleanString(json["religion"]),
    subscriberId: _cleanString(json["subscriber_id"]),
    subscriberRelationship: _cleanString(json["subscriber_relationship"]),
    subscriberInsurancePlan: json["subscriber_insurance_plan"],
    isNewBorn: json["is_new_born"] == true,
    password: _cleanString(json["password"]),
    email: _cleanString(json["email"]),
    userLogin: json["user_login"] == true,
    createdAt:
        (json["created_at"] != null && json["created_at"].toString().isNotEmpty)
            ? DateTime.tryParse(json["created_at"].toString())
            : null,
    updatedAt:
        (json["updated_at"] != null && json["updated_at"].toString().isNotEmpty)
            ? DateTime.tryParse(json["updated_at"].toString())
            : null,
  );

  Map<String, dynamic> toJson() => {
    "patient_id": patientId,
    "full_name": fullName,
    "rcm_ref": rcmRef,
    "erp_ref": erpRef,
    "user_id": userId,
    "maternity": maternity,
    "martial_status": martialStatus,
    "gender": gender,
    "document_id": documentId,
    "visa_no": visaNo,
    "file_no": fileNo,
    "mrn": mrn,
    "beneficiary_type": beneficiaryType,
    "business_id": businessId,
    "branch_id": branchId,
    "city": city,
    "residency_type": residencyType,
    "insurance_plans": insurancePlans,
    "guarantors": guarantors,
    "emergency_contacts": emergencyContacts,
    "address": address,
    "visa_type": visaType,
    "visa_title": visaTitle,
    "document_type": documentType,
    "passport_no": passportNo,
    "insurance_duration": insuranceDuration,
    "border_no": borderNo,
    "dob": dob,
    "contact": contact,
    "nationality": nationality,
    "profession": profession,
    "religion": religion,
    "subscriber_id": subscriberId,
    "subscriber_relationship": subscriberRelationship,
    "subscriber_insurance_plan": subscriberInsurancePlan,
    "is_new_born": isNewBorn,
    "password": password,
    "email": email,
    "user_login": userLogin,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Assigned {
  final bool? check;

  Assigned({this.check});

  factory Assigned.fromJson(Map<String, dynamic> json) =>
      Assigned(check: json["check"] ?? false);

  Map<String, dynamic> toJson() => {"check": check};
}

enum Status { ACTIVE }

final statusValues = EnumValues({"active": Status.ACTIVE});

class Timing {
  final StartTime? startTime;
  final EndTime? endTime;

  Timing({this.startTime, this.endTime});

  factory Timing.fromJson(Map<String, dynamic> json) => Timing(
    startTime: startTimeValues.map[json["start_time"] ?? ""]!,
    endTime: endTimeValues.map[json["end_time"] ?? ""]!,
  );

  Map<String, dynamic> toJson() => {
    "start_time": startTimeValues.reverse[startTime],
    "end_time": endTimeValues.reverse[endTime],
  };
}

enum EndTime { THE_1400, THE_2200 }

final endTimeValues = EnumValues({
  "14:00": EndTime.THE_1400,
  "22:00": EndTime.THE_2200,
});

enum StartTime { THE_0900, THE_1600 }

final startTimeValues = EnumValues({
  "09:00": StartTime.THE_0900,
  "16:00": StartTime.THE_1600,
});

enum Title { EVEING_SHIFT, MORNING_SIR }

final titleValues = EnumValues({
  "eveing shift": Title.EVEING_SHIFT,
  "morning Sir": Title.MORNING_SIR,
});

class FiltersApplied {
  final String endDate;
  final String practitionerId;
  final String query;
  final String sortBy;
  final String sortOrder;
  final String startDate;
  final String status;

  FiltersApplied({
    this.endDate = "",
    this.practitionerId = "",
    this.query = "",
    this.sortBy = "",
    this.sortOrder = "",
    this.startDate = "",
    this.status = "",
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) => FiltersApplied(
    endDate: (json["end_date"] ?? "").toString(),
    practitionerId: (json["practitioner_id"] ?? "").toString(),
    query: (json["query"] ?? "").toString(),
    sortBy: (json["sort_by"] ?? "").toString(),
    sortOrder: (json["sort_order"] ?? "").toString(),
    startDate: (json["start_date"] ?? "").toString(),
    status: (json["status"] ?? "").toString(),
  );

  Map<String, dynamic> toJson() => {
    "end_date": endDate.isNotEmpty ? endDate : null,
    "practitioner_id": practitionerId.isNotEmpty ? practitionerId : null,
    "query": query.isNotEmpty ? query : null,
    "sort_by": sortBy.isNotEmpty ? sortBy : null,
    "sort_order": sortOrder.isNotEmpty ? sortOrder : null,
    "start_date": startDate.isNotEmpty ? startDate : null,
    "status": status.isNotEmpty ? status : null,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class Practitioner {
  final int rcmRef;
  final int userId;
  final String practitionerId;
  final String documentId;
  final int businessId;
  final int branchId;
  final String license;
  final List<ScheduleDay> schedule;
  final String name;
  final String role;
  final String wardNo;
  final String roomNo;
  final String createdAt;
  final String updatedAt;
  final List<AssignedNurse> assignedNurses;

  Practitioner({
    required this.rcmRef,
    required this.userId,
    required this.practitionerId,
    required this.documentId,
    required this.businessId,
    required this.branchId,
    required this.license,
    required this.schedule,
    required this.name,
    required this.role,
    required this.wardNo,
    required this.roomNo,
    required this.createdAt,
    required this.updatedAt,
    required this.assignedNurses,
  });

  factory Practitioner.fromJson(Map<String, dynamic> json) {
    return Practitioner(
      rcmRef: json['rcm_ref'] ?? 0,
      userId: json['user_id'] ?? 0,
      practitionerId: json['practitioner_id'] ?? "",
      documentId: json['document_id'] ?? "",
      businessId: json['business_id'] ?? 0,
      branchId: json['branch_id'] ?? 0,
      license: json['license'] ?? "",
      schedule:
          (json['schedule'] as List<dynamic>?)
              ?.map((e) => ScheduleDay.fromJson(e))
              .toList() ??
          [],
      name: json['name'] ?? "",
      role: json['role'] ?? "",
      wardNo: json['ward_no'] ?? "",
      roomNo: json['room_no'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      assignedNurses:
          (json['assigned_nurses'] as List<dynamic>?)
              ?.map((e) => AssignedNurse.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rcm_ref': rcmRef,
      'user_id': userId,
      'practitioner_id': practitionerId,
      'document_id': documentId,
      'business_id': businessId,
      'branch_id': branchId,
      'license': license,
      'schedule': schedule.map((s) => s.toJson()).toList(),
      'name': name,
      'role': role,
      'ward_no': wardNo,
      'room_no': roomNo,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'assigned_nurses': assignedNurses.map((n) => n.toJson()).toList(),
    };
  }
}

class ScheduleDay {
  final String day;
  final List shifts;
  final String status;
  final int limit;
  final int interval;

  ScheduleDay({
    required this.day,
    required this.shifts,
    required this.status,
    required this.limit,
    required this.interval,
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    var shiftsList = [];
    if (json['shifts'] != null) {
      shiftsList =
          List<Map<String, dynamic>>.from(
            json['shifts'],
          ).map((e) => Shift.fromJson(e)).toList();
    }
    return ScheduleDay(
      day: json['day'],
      shifts: shiftsList,
      status: json['status'],
      limit: json['limit'],
      interval: json['interval'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'shifts': shifts.map((s) => s.toJson()).toList(),
      'status': status,
      'limit': limit,
      'interval': interval,
    };
  }
}

class AssignedNurse {
  final String name;
  final String role;
  final String nurseId;
  final String documentId;
  final int rcmRef;
  final int userId;
  final Map<String, dynamic> assigned; // you can model more strictly if needed
  final String wardNo;
  final String roomNo;
  final List schedule;
  final int branchId;
  final int businessId;
  final String createdAt;
  final String updatedAt;

  AssignedNurse({
    required this.name,
    required this.role,
    required this.nurseId,
    required this.documentId,
    required this.rcmRef,
    required this.userId,
    required this.assigned,
    required this.wardNo,
    required this.roomNo,
    required this.schedule,
    required this.branchId,
    required this.businessId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignedNurse.fromJson(Map<String, dynamic> json) {
    var schedList = [];
    if (json['schedule'] != null) {
      schedList =
          List<Map<String, dynamic>>.from(
            json['schedule'],
          ).map((e) => ScheduleDay.fromJson(e)).toList();
    }
    return AssignedNurse(
      name: json['name'],
      role: json['role'],
      nurseId: json['nurse_id'],
      documentId: json['document_id'],
      rcmRef: json['rcm_ref'],
      userId: json['user_id'],
      assigned: json['assigned'] ?? {},
      wardNo: json['ward_no'],
      roomNo: json['room_no'],
      schedule: schedList,
      branchId: json['branch_id'],
      businessId: json['business_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'nurse_id': nurseId,
      'document_id': documentId,
      'rcm_ref': rcmRef,
      'user_id': userId,
      'assigned': assigned,
      'ward_no': wardNo,
      'room_no': roomNo,
      'schedule': schedule.map((s) => s.toJson()).toList(),
      'branch_id': branchId,
      'business_id': businessId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
