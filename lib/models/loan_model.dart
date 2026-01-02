// To parse this JSON data, do
//
//     final loanModel = loanModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LoanModel loanModelFromJson(String str) => LoanModel.fromJson(json.decode(str));

String loanModelToJson(LoanModel data) => json.encode(data.toJson());

class LoanModel {
  final List<LoanDatum> data;
  final int page;
  final int pageSize;
  final int total;
  final int totalPage;

  LoanModel({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPage,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
    data: List<LoanDatum>.from(json["data"].map((x) => LoanDatum.fromJson(x))),
    page: json["page"],
    pageSize: json["page_size"],
    total: json["total"],
    totalPage: json["total_page"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "page": page,
    "page_size": pageSize,
    "total": total,
    "total_page": totalPage,
  };
}

class LoanDatum {
  final String id;
  final String employeeId;
  final int amount;
  final String purpose;
  final int installments;
  final int monthlyInstallment;
  final int remainingAmount;
  final String startMonth;
  final String status;
  final dynamic approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  LoanDatum({
    required this.id,
    required this.employeeId,
    required this.amount,
    required this.purpose,
    required this.installments,
    required this.monthlyInstallment,
    required this.remainingAmount,
    required this.startMonth,
    required this.status,
    required this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory LoanDatum.fromJson(Map<String, dynamic> json) => LoanDatum(
    id: json["id"],
    employeeId: json["employee_id"],
    amount: json["amount"],
    purpose: json["purpose"],
    installments: json["installments"],
    monthlyInstallment:
        (json["monthly_installment"] is int)
            ? json["monthly_installment"]
            : (json["monthly_installment"] as double).toInt(),
    remainingAmount: json["remaining_amount"],
    startMonth: json["start_month"],
    status: json["status"],
    approvedAt: json["approved_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "employee_id": employeeId,
    "amount": amount,
    "purpose": purpose,
    "installments": installments,
    "monthly_installment": monthlyInstallment,
    "remaining_amount": remainingAmount,
    "start_month": startMonth,
    "status": status,
    "approved_at": approvedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
