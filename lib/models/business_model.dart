class BusinessResponse {
  final List<Business> data;
  final String? message;

  BusinessResponse({required this.data, this.message});

  factory BusinessResponse.fromJson(Map<String, dynamic> json) {
    return BusinessResponse(
      data:
          (json['data'] as List<dynamic>)
              .map((item) => Business.fromJson(item as Map<String, dynamic>))
              .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((e) => e.toJson()).toList(), 'message': message};
  }
}

class Business {
  final int id;
  final String? nameEn;
  final String? nameAr;
  final String? businessType;
  final String? address;
  final String? contactInfo;
  final String? vatNo;
  final String? crNo;
  final String? vatRegistrationDate;
  final String? logo;
  final String? signature;
  final String? stamp;
  final String? rcmEmail;
  final String? rcmPassword;
  final String? latitude;
  final String? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Business({
    required this.id,
    this.nameEn,
    this.nameAr,
    this.businessType,
    this.address,
    this.contactInfo,
    this.vatNo,
    this.crNo,
    this.vatRegistrationDate,
    this.logo,
    this.signature,
    this.stamp,
    this.rcmEmail,
    this.rcmPassword,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as int,
      nameEn: json['name_en'] as String?,
      nameAr: json['name_ar'] as String?,
      businessType: json['business_type'] as String?,
      address: json['address'] as String?,
      contactInfo: json['contact_info'] as String?,
      vatNo: json['vat_no'] as String?,
      crNo: json['cr_no'] as String?,
      vatRegistrationDate: json['vat_registration_date'] as String?,
      logo: json['logo'] as String?,
      signature: json['signature'] as String?,
      stamp: json['stamp'] as String?,
      rcmEmail: json['rcm_email'] as String?,
      rcmPassword: json['rcm_password'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'business_type': businessType,
      'address': address,
      'contact_info': contactInfo,
      'vat_no': vatNo,
      'cr_no': crNo,
      'vat_registration_date': vatRegistrationDate,
      'logo': logo,
      'signature': signature,
      'stamp': stamp,
      'rcm_email': rcmEmail,
      'rcm_password': rcmPassword,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
