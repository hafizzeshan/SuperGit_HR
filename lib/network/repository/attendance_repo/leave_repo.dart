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
            Utils.extractApiError(response.data, "Failed to fetch leave types");
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

  /// ✅ Create Leave Request
  Future createLeaveRequest({
    required dynamic data,
    bool isMultipart = false,
  }) async {
    try {
      final response = await _api.postRequest(
        AppURL.leaveRequestsApi,
        data: data,
        isMultipart: isMultipart,
      );

      if (response == null) {
        Utils.snackBar("Unable to reach server. Please try again.", true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Leave Request Response: ${response.data}");
        return response.data;
      } else {
        String message = "Leave request failed";
        if (response.data != null) {
          final data = response.data;
          if (data is Map) {
            if (data['message'] != null) {
              message = data['message'].toString();
            } else if (data['error'] != null) {
              message = data['error'].toString();
            } else if (data['errors'] != null) {
              if (data['errors'] is Map) {
                final errors = data['errors'] as Map;
                if (errors.isNotEmpty) {
                  final firstError = errors.values.first;
                  message = firstError is List
                      ? firstError.first.toString()
                      : firstError.toString();
                }
              } else {
                message = data['errors'].toString();
              }
            }
          } else {
             message = data.toString();
          }
        }
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

  /// ✅ Fetch Leave Balances for an employee/year
  /// GET ess/leave-balances/:employee_id?year=YYYY
  Future getLeaveBalances(String employeeId, {int? year}) async {
    try {
      final response = await _api.getRequest(
        AppURL.leaveBalances(employeeId, year: year),
      );
      if (response == null) return null;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        Utils.snackBar(
          Utils.extractApiError(response.data, "Failed to load leave balances"),
          true,
        );
        return null;
      }
    } catch (e, st) {
      log("❌ Error in getLeaveBalances: $e", stackTrace: st);
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
        Utils.snackBar(
          Utils.extractApiError(response.data, "Failed to fetch leave history"),
          true,
        );
        return null;
      }
    } catch (e, st) {
      log("❌ Error in getEmployeeLeaveHistory: $e", stackTrace: st);
      Utils.snackBar("Error fetching leave history", true);
      return null;
    }
  }
}
