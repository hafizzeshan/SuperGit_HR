class Branch {
  final int id;
  final int businessId;
  final String nameEn;
  final String nameAr;
  final String address;
  final String contactInfo;
  final String latitude;
  final String longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Branch({
    required this.id,
    required this.businessId,
    required this.nameEn,
    required this.nameAr,
    required this.address,
    required this.contactInfo,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      businessId: json['business_id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      address: json['address'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    'name_en': nameEn,
    'name_ar': nameAr,
    'address': address,
    'contact_info': contactInfo,
    'latitude': latitude,
    'longitude': longitude,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
