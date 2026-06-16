import 'dart:developer';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class AttendanceRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Clock In API
  Future clockIn({required data}) async {
    try {
      final response = await _api.postRequest(AppURL.clockInApi, data: data);

      if (response == null) {
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Clock-In Response: ${response.data}");
        // Utils.snackBar(
        //   response.data?['message'] ?? "Clock-In Successful!",
        //   false,
        // );
        return response.data;
      } else {
        final message = Utils.extractApiError(response.data, "Clock-In failed");
        Utils.snackBar(message, true);
        log("❌ Clock-In Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in Clock-In: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.somethingWentWrongClockIn.tr, true);
      return null;
    }
  }

  /// ✅ Clock Out API
  Future clockOut({required data}) async {
    try {
      final response = await _api.postRequest(AppURL.clockOutApi, data: data);

      if (response == null) {
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Clock-Out Response: ${response.data}");
        // Utils.snackBar(
        //   response.data?['message'] ?? "Clock-Out Successful!",
        //   false,
        // );
        return response.data;
      } else {
        final message = Utils.extractApiError(response.data, "Clock-Out failed");
        Utils.snackBar(message, true);
        log("❌ Clock-Out Failed: $message");
      }
    } catch (e, st) {
      log("❌ Exception in Clock-Out: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.somethingWentWrongClockOut.tr, true);
    }
  }

  /// ✅ Get Attendance History
  Future getAttendanceHistory({
    required String employeeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final url = AppURL.attendanceHistory(employeeId, startDate, endDate);
      final response = await _api.getRequest(url);

      if (response == null) {
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        Utils.snackBar(
          Utils.extractApiError(response.data, "Failed to fetch attendance history"),
          true,
        );
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in getAttendanceHistory: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.errorFetchingAttendanceHistory.tr, true);
      return null;
    }
  }

  /// ✅ Create Edit Request
  Future createEditRequest({
    required String attendanceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = AppURL.editAttendanceRequest(attendanceId);
      
      print("\n================= EDIT REQUEST START =================");
      print("🔹 URL: ${AppURL.baseUrl}$url");
      print("🔹 Payload: $data");

      // Assuming postRequest is the correct method for edit requests
      final response = await _api.postRequest(url, data: data);

      if (response == null) {
        print("❌ Edit Request Response: NULL (Network Error)");
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      print("🔹 Headers Sent: ${_api.dio.options.headers}");
      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Data: ${response.data}");
      print("================= EDIT REQUEST END =================\n");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.snackBar(
          response.data?['message'] ?? "Request Submitted Successfully!",
          false,
        );
        return response.data;
      } else {
        final message =
            Utils.extractApiError(response.data, "Failed to submit request");
        Utils.snackBar(message, true);
        log("❌ Edit Request Failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in createEditRequest: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.somethingWentWrongRequestSubmission.tr, true);
      return null;
    }
  }
}
