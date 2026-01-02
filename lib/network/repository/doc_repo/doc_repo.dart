import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class DocumentRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Fetch All Employee Documents
  Future getEmployeeDocuments(String employeeId) async {
    try {
      final response = await _api.getRequest(
        AppURL.employeeDocuments(employeeId),
      );

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Employee Documents Response: ${response.data}");
        return response.data;
      } else {
        final message =
            response.data?['message'] ?? "Failed to fetch documents";
        Utils.snackBar(message, true);
        log("❌ Fetch Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in getEmployeeDocuments: $e", stackTrace: st);
      Utils.snackBar("Something went wrong while fetching documents", true);
      return null;
    }
  }

  /// ✅ Add New Employee Document (Multipart Upload)
  Future addEmployeeDocument({
    required String employeeId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // ✅ Prepare FormData
      final formData = FormData.fromMap({
        'file_path': [
          await MultipartFile.fromFile(
            data['file_path'], // path to the local file
            filename: data['file_path'].split('/').last,
          ),
        ],
        'document_type': data['document_type'],
        'document_name': data['document_name'],
        'document_number': data['document_number'],
        'issue_date': data['issue_date'],
        'expiry_date': data['expiry_date'],
        'is_signed': 'true',
      });

      print(formData.fields);

      final response = await _api.postRequest(
        AppURL.employeeDocuments(employeeId),
        data: formData,
        isMultipart: true, // ✅ Important: ensures proper headers
      );
      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Add Document Response: ${response.data}");
        // If server returns message, use it; otherwise fallback
        // final message =
        //     response.data?['message'] ?? "Document added successfully!";
        // Utils.snackBar(message, false);
        return response.data;
      } else {
        print("❌ Add Document Failed Status: ${response.statusCode}");
        print("❌ Add Document Response Data: ${response.data}");

        // Try to show a meaningful error
        String errorMessage = "Failed to add document";

        if (response.data != null) {
          if (response.data is Map<String, dynamic>) {
            if (response.data!['message'] != null) {
              errorMessage = response.data!['message'];
            } else if (response.data!['errors'] != null) {
              // If errors are in form validation style
              errorMessage = response.data!['errors'].toString();
            }
          } else {
            errorMessage = response.data.toString();
          }
        }

        Utils.snackBar(errorMessage, true);
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in addEmployeeDocument: $e", stackTrace: st);
      Utils.snackBar("Error while adding document", true);
      return null;
    }
  }
}
