// To parse this JSON data, do
//
//     final holidayModel = holidayModelFromJson(jsonString);

import 'dart:convert';

HolidayModel holidayModelFromJson(String str) =>
    HolidayModel.fromJson(json.decode(str));

String holidayModelToJson(HolidayModel data) => json.encode(data.toJson());

class HolidayModel {
  final String? message;
  final List<HolidaDatum>? data;
  final int? page;
  final int? pageSize;
  final int? total;
  final int? totalPages;

  HolidayModel({
    this.message,
    this.data,
    this.page,
    this.pageSize,
    this.total,
    this.totalPages,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) => HolidayModel(
    message: json["message"],
    data:
        json["data"] == null
            ? []
            : List<HolidaDatum>.from(
              json["data"]!.map((x) => HolidaDatum.fromJson(x)),
            ),
    page: json["page"],
    pageSize: json["page_size"],
    total: json["total"],
    totalPages: json["total_pages"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "page": page,
    "page_size": pageSize,
    "total": total,
    "total_pages": totalPages,
  };
}

class HolidaDatum {
  final String? id;
  final String? nameEn;
  final String? nameAr;
  final DateTime? date;
  final bool? isRecurring;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  HolidaDatum({
    this.id,
    this.nameEn,
    this.nameAr,
    this.date,
    this.isRecurring,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory HolidaDatum.fromJson(Map<String, dynamic> json) => HolidaDatum(
    id: json["id"],
    nameEn: json["name_en"],
    nameAr: json["name_ar"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    isRecurring: json["is_recurring"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_en": nameEn,
    "name_ar": nameAr,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "is_recurring": isRecurring,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
