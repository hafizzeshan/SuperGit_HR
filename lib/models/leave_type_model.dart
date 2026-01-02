class LeaveTypeModel {
  final String? id;
  final String? nameEn;
  final String? nameAr;
  final String? description;
  final bool? isPaid;
  final int? annualDays;
  final int? maxPerYear;
  final bool? carryForward;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  LeaveTypeModel({
    this.id,
    this.nameEn,
    this.nameAr,
    this.description,
    this.isPaid,
    this.annualDays,
    this.maxPerYear,
    this.carryForward,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json["id"],
      nameEn: json["name_en"],
      nameAr: json["name_ar"],
      description: json["description"],
      isPaid: json["is_paid"],
      annualDays: json["annual_days"],
      maxPerYear: json["max_per_year"],
      carryForward: json["carry_forward"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      deletedAt: json["deleted_at"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_en": nameEn,
    "name_ar": nameAr,
    "description": description,
    "is_paid": isPaid,
    "annual_days": annualDays,
    "max_per_year": maxPerYear,
    "carry_forward": carryForward,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
  };
}
