class EmployeeDocumentModel {
  final String? id;
  final String? employeeId;
  final String? documentType;
  final String? documentName;
  final String? documentNumber;
  final String? issueDate;
  final String? expiryDate;
  final String? filePath;
  final bool isSigned;
  final String? signedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  EmployeeDocumentModel({
    this.id,
    this.employeeId,
    this.documentType,
    this.documentName,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.filePath,
    this.isSigned = false,
    this.signedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// ✅ Factory constructor for JSON → Model
  factory EmployeeDocumentModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDocumentModel(
      id: json["id"] ?? "",
      employeeId: json["employee_id"] ?? "",
      documentType: json["document_type"] ?? "",
      documentName: json["document_name"] ?? "",
      documentNumber: json["document_number"] ?? "",
      issueDate: json["issue_date"] ?? "",
      expiryDate: json["expiry_date"] ?? "",
      filePath: json["file_path"] ?? "",
      isSigned: json["is_signed"] ?? false,
      signedAt: json["signed_at"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      deletedAt: json["deleted_at"],
    );
  }

  /// ✅ Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "employee_id": employeeId,
      "document_type": documentType,
      "document_name": documentName,
      "document_number": documentNumber,
      "issue_date": issueDate,
      "expiry_date": expiryDate,
      "file_path": filePath,
      "is_signed": isSigned,
      "signed_at": signedAt,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "deleted_at": deletedAt,
    };
  }
}
