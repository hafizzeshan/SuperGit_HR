import 'dart:convert';

class TenantModel {
  final String id;
  final String name;
  final String companyNameEn;
  final String companyNameAr;
  final String slug;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String? logo;
  final String? status;
  final String? planType;
  final String employeeCodePrefix;

  TenantModel({
    required this.id,
    required this.name,
    required this.companyNameEn,
    required this.companyNameAr,
    required this.slug,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    this.logo,
    this.status,
    this.planType,
    required this.employeeCodePrefix,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      companyNameEn: map['company_name_en'] ?? '',
      companyNameAr: map['company_name_ar'] ?? '',
      slug: map['slug'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      logo: map['logo'],
      status: map['status'],
      planType: map['plan_type'],
      employeeCodePrefix: map['employee_code_prefix'] ?? '',
    );
  }

  factory TenantModel.fromJson(String source) =>
      TenantModel.fromMap(json.decode(source));
}
