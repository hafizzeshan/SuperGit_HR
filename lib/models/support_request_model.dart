import 'package:cloud_firestore/cloud_firestore.dart';

/// A support message an employee sent from the Contact Support screen.
class SupportRequestModel {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String email;
  final String phone;
  final String message;

  /// `yyyy-MM-dd` of when it was sent — used for the per-day send limit.
  final String dayKey;

  /// Null only for the brief moment before the server timestamp lands.
  final DateTime? createdAt;

  const SupportRequestModel({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.email,
    required this.phone,
    required this.message,
    required this.dayKey,
    this.createdAt,
  });

  factory SupportRequestModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawCreated = data['created_at'];
    return SupportRequestModel(
      id: doc.id,
      employeeId: (data['employee_id'] ?? '') as String,
      employeeCode: (data['employee_code'] ?? '') as String,
      employeeName: (data['employee_name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      message: (data['message'] ?? '') as String,
      dayKey: (data['day_key'] ?? '') as String,
      createdAt: rawCreated is Timestamp ? rawCreated.toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'employee_id': employeeId,
    'employee_code': employeeCode,
    'employee_name': employeeName,
    'email': email,
    'phone': phone,
    'message': message,
    'day_key': dayKey,
    'created_at': FieldValue.serverTimestamp(),
  };
}
