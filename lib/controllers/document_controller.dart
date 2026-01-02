import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/employee_doc_model.dart';
import 'package:supergithr/network/repository/doc_repo/doc_repo.dart';
import 'package:supergithr/utils/utils.dart';

class DocumentController extends GetxController {
  final DocumentRepository _repo = DocumentRepository();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var documents = <EmployeeDocumentModel>[].obs;

  final documentTypeController = TextEditingController();
  final documentNameController = TextEditingController();
  final documentNumberController = TextEditingController();
  final issueDateController = TextEditingController();
  final expiryDateController = TextEditingController();
  final filePathController = TextEditingController();

  @override
  void onInit() {
    log("✅ DocumentController initialized");
    super.onInit();
  }

  /// ✅ Fetch Documents
  Future<void> fetchEmployeeDocuments() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar("Employee ID not found. Please log in again.", true);
        return;
      }

      final response = await _repo.getEmployeeDocuments(employeeId);

      if (response != null && response["data"] != null) {
        final docList =
            (response["data"] as List)
                .map((e) => EmployeeDocumentModel.fromJson(e))
                .toList();
        documents.assignAll(docList);
        log("✅ Documents fetched: ${documents.length}");
      } else {
        Utils.snackBar("No documents found.", true);
      }
    } catch (e, st) {
      log("❌ Error fetching documents: $e", stackTrace: st);
      Utils.snackBar("Error fetching documents", true);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Add Document (with file upload)
  Future<void> addDocument() async {
    final documentType = documentTypeController.text.trim();
    final documentName = documentNameController.text.trim();
    final documentNumber = documentNumberController.text.trim();
    final issueDate = issueDateController.text.trim();
    final expiryDate = expiryDateController.text.trim();
    final filePath = filePathController.text.trim();

    if (documentType.isEmpty ||
        documentName.isEmpty ||
        documentNumber.isEmpty ||
        issueDate.isEmpty ||
        expiryDate.isEmpty ||
        filePath.isEmpty) {
      Utils.snackBar("Please fill all required fields", true);
      return;
    }

    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar("Employee ID not found. Please log in again.", true);
        isSubmitting.value = false;
        return;
      }

      final data = {
        "document_type": documentType,
        "document_name": documentName,
        "document_number": documentNumber,
        "issue_date": issueDate,
        "expiry_date": expiryDate,
        "file_path": filePath,
      };

      final response = await _repo.addEmployeeDocument(
        employeeId: employeeId,
        data: data,
      );

      if (response != null && response["data"] != null) {
        final newDoc = EmployeeDocumentModel.fromJson(response["data"]);
        documents.add(newDoc);
        Utils.snackBar(response["message"], false);
        Get.back();
        clearForm();
        print("✅ Document Added: ${newDoc.toJson()}");
      } else {
        print(response.toString());
        Utils.snackBar("Failed to add document", true);
      }
    } catch (e, st) {
      log("❌ Error adding document: $e", stackTrace: st);
      Utils.snackBar("Error adding document", true);
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    documentTypeController.clear();
    documentNameController.clear();
    documentNumberController.clear();
    issueDateController.clear();
    expiryDateController.clear();
    filePathController.clear();
  }

  @override
  void onClose() {
    documentTypeController.dispose();
    documentNameController.dispose();
    documentNumberController.dispose();
    issueDateController.dispose();
    expiryDateController.dispose();
    filePathController.dispose();
    super.onClose();
  }
}
