class UserModel {
  final String? id;
  final String? userId;
  final String? employeeCode;
  final String? firstNameEn;
  final String? lastNameEn;
  final String? firstNameAr;
  final String? lastNameAr;
  final String? gender;
  final String? dateOfBirth;
  final String? nationality;
  final String? documentId;
  final String? maritalStatus;
  final String? mobileNumber;
  final String? email;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? jobTitle;
  final String? departmentId;
  final String? dateFormat;
  final String? managerId;
  final String? jobRoleId;
  final String? jobRoleName;
  final String? managerName;
  final String? departmentName;
  final bool isManager;
  final bool isDepartmentHead;
  final String? employmentStatus;
  final String? joinDate;
  final dynamic documents;
  final dynamic ids;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  UserModel({
    this.id,
    this.userId,
    this.employeeCode,
    this.firstNameEn,
    this.lastNameEn,
    this.firstNameAr,
    this.lastNameAr,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.documentId,
    this.maritalStatus,
    this.mobileNumber,
    this.email,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.jobTitle,
    this.departmentId,
    this.dateFormat,
    this.managerId,
    this.jobRoleId,
    this.jobRoleName,
    this.managerName,
    this.departmentName,
    this.isManager = false,
    this.isDepartmentHead = false,
    this.employmentStatus,
    this.joinDate,
    this.documents,
    this.ids,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// ✅ Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserModel();

    return UserModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      employeeCode: json['employee_code'] as String?,
      firstNameEn: json['first_name_en'] as String?,
      lastNameEn: json['last_name_en'] as String?,
      firstNameAr: json['first_name_ar'] as String?,
      lastNameAr: json['last_name_ar'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      nationality: json['nationality'] as String?,
      documentId: json['document_id'] as String?,
      maritalStatus: json['marital_status'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      email: json['email'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactNumber: json['emergency_contact_number'] as String?,
      jobTitle: json['job_title'] as String?,
      departmentId: json['department_id'] as String?,
      dateFormat: json['date_format'] as String?,
      managerId: json['manager_id'] as String?,
      jobRoleId: json['job_role_id'] as String?,
      jobRoleName: json['job_role_name'] as String?,
      managerName: json['manager_name'] as String?,
      departmentName: json['department_name'] as String?,
      isManager: json['is_manager'] == true,
      isDepartmentHead: json['is_department_head'] == true,
      employmentStatus: json['employment_status'] as String?,
      joinDate: json['join_date'] as String?,
      documents: json['documents'],
      ids: json['ids'],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  /// ✅ Convert UserModel to JSON (for storage or API requests)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "employee_code": employeeCode,
      "first_name_en": firstNameEn,
      "last_name_en": lastNameEn,
      "first_name_ar": firstNameAr,
      "last_name_ar": lastNameAr,
      "gender": gender,
      "date_of_birth": dateOfBirth,
      "nationality": nationality,
      "document_id": documentId,
      "marital_status": maritalStatus,
      "mobile_number": mobileNumber,
      "email": email,
      "emergency_contact_name": emergencyContactName,
      "emergency_contact_number": emergencyContactNumber,
      "job_title": jobTitle,
      "department_id": departmentId,
      "date_format": dateFormat,
      "manager_id": managerId,
      "job_role_id": jobRoleId,
      "job_role_name": jobRoleName,
      "manager_name": managerName,
      "department_name": departmentName,
      "is_manager": isManager,
      "is_department_head": isDepartmentHead,
      "employment_status": employmentStatus,
      "join_date": joinDate,
      "documents": documents,
      "ids": ids,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "deleted_at": deletedAt,
    };
  }
}
