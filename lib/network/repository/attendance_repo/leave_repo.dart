import 'dart:developer';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class LeaveRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Get Leave Types with Pagination
  Future getLeaveTypes({int page = 1, int pageSize = 100}) async {
    try {
      final url = '${AppURL.leaveTypesApi}?page=$page&page_size=$pageSize';
      final response = await _api.getRequest(url);

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Leave Types Response: Page $page, Total: ${response.data?['total'] ?? 0}");
        return response.data;
      } else {
        final message =
            response.data?['message'] ?? "Failed to fetch leave types";
        Utils.snackBar(message, true);
        log("❌ Leave Types Fetch Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in getLeaveTypes: $e", stackTrace: st);
      Utils.snackBar("Something went wrong while fetching leave types", true);
      return null;
    }
  }

  /// ✅ Submit Leave Request
  Future submitLeaveRequest({required Map<String, dynamic> data}) async {
    try {
      final response = await _api.postRequest(
        AppURL.leaveRequestsApi,
        data: data,
      );

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Leave Request Response: ${response.data}");
        Utils.snackBar(
          response.data?['message'] ?? "Leave request submitted successfully!",
          false,
        );
        return response.data;
      } else {
        final message = response.data?['message'] ?? "Leave request failed";
        Utils.snackBar(message, true);
        log("❌ Leave Request Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in submitLeaveRequest: $e", stackTrace: st);
      Utils.snackBar(
        "Something went wrong while submitting leave request",
        true,
      );
      return null;
    }
  }

  /// ✅ Fetch Employee Leave History with Pagination
  Future getEmployeeLeaveHistory(
    String employeeId, {
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final url = '${AppURL.leaveHistory(employeeId)}?page=$page&page_size=$pageSize';
      final response = await _api.getRequest(url);
      
      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Leave History Response: Page $page, Total: ${response.data?['total'] ?? 0}");
        return response.data;
      } else {
        Utils.snackBar("Failed to fetch leave history", true);
        return null;
      }
    } catch (e, st) {
      log("❌ Error in getEmployeeLeaveHistory: $e", stackTrace: st);
      Utils.snackBar("Error fetching leave history", true);
      return null;
    }
  }
}
