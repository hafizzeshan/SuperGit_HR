// To parse this JSON data, do
//
//     final SalaryStructureModel = SalaryStructureModelFromJson(jsonString);

import 'dart:convert';

SalaryStructureModel SalaryStructureModelFromJson(String str) =>
    SalaryStructureModel.fromJson(json.decode(str));

String SalaryStructureModelToJson(SalaryStructureModel data) =>
    json.encode(data.toJson());

class SalaryStructureModel {
  final List<SalaryDatum> data;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  SalaryStructureModel({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory SalaryStructureModel.fromJson(Map<String, dynamic> json) =>
      SalaryStructureModel(
        data: List<SalaryDatum>.from(
          json["data"].map((x) => SalaryDatum.fromJson(x)),
        ),
        page: json["page"],
        pageSize: json["page_size"],
        total: json["total"],
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "page": page,
    "page_size": pageSize,
    "total": total,
    "totalPages": totalPages,
  };
}

class SalaryDatum {
  final String id;
  final String employeeId;
  final int basicSalary;
  final int housingAllowance;
  final int transportAllowance;
  final int otherAllowances;
  final int deductions;
  final int gosiContribution;
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  SalaryDatum({
    required this.id,
    required this.employeeId,
    required this.basicSalary,
    required this.housingAllowance,
    required this.transportAllowance,
    required this.otherAllowances,
    required this.deductions,
    required this.gosiContribution,
    required this.isActive,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory SalaryDatum.fromJson(Map<String, dynamic> json) => SalaryDatum(
    id: json["id"],
    employeeId: json["employee_id"],
    basicSalary: json["basic_salary"],
    housingAllowance: json["housing_allowance"],
    transportAllowance: json["transport_allowance"],
    otherAllowances: json["other_allowances"],
    deductions: json["deductions"],
    gosiContribution: json["gosi_contribution"],
    isActive: json["is_active"],
    effectiveFrom: DateTime.parse(json["effective_from"]),
    effectiveTo: DateTime.parse(json["effective_to"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "employee_id": employeeId,
    "basic_salary": basicSalary,
    "housing_allowance": housingAllowance,
    "transport_allowance": transportAllowance,
    "other_allowances": otherAllowances,
    "deductions": deductions,
    "gosi_contribution": gosiContribution,
    "is_active": isActive,
    "effective_from":
        "${effectiveFrom.year.toString().padLeft(4, '0')}-${effectiveFrom.month.toString().padLeft(2, '0')}-${effectiveFrom.day.toString().padLeft(2, '0')}",
    "effective_to":
        "${effectiveTo.year.toString().padLeft(4, '0')}-${effectiveTo.month.toString().padLeft(2, '0')}-${effectiveTo.day.toString().padLeft(2, '0')}",
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
