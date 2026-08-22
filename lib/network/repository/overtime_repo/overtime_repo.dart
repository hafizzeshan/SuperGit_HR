import 'dart:developer';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class OvertimeRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ GET attendance/overtime?employee_id=...&page=...&limit=...
  Future<Map<String, dynamic>?> getEmployeeOvertime({
    required String employeeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.getRequest(
        AppURL.overtimeList(employeeId: employeeId, page: page, limit: limit),
      );

      if (response == null) {
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        return body is Map ? Map<String, dynamic>.from(body) : null;
      }

      final message = Utils.extractApiError(
        response.data,
        TranslationKeys.failedToFetchOvertime.tr,
      );
      Utils.snackBar(message, true);
      log("❌ Overtime Fetch Failed: $message");
      return null;
    } catch (e, st) {
      log("❌ Exception in getEmployeeOvertime: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.somethingWentWrongFetchingOvertime.tr, true);
      return null;
    }
  }

  /// ✅ POST attendance/overtime
  Future<Map<String, dynamic>?> createOvertime(Map<String, dynamic> data) async {
    try {
      final response = await _api.postRequest(AppURL.overtimeApi, data: data);

      if (response == null) {
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Overtime Request Response: ${response.data}");
        Utils.snackBar(
          response.data?['message'] ??
              TranslationKeys.overtimeRequestCreated.tr,
          false,
        );
        final body = response.data;
        return body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
      }

      final message = Utils.extractApiError(
        response.data,
        TranslationKeys.overtimeRequestFailed.tr,
      );
      Utils.snackBar(message, true);
      log("❌ Overtime Request Failed: $message");
      return null;
    } catch (e, st) {
      log("❌ Exception in createOvertime: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.somethingWentWrongCreatingOvertime.tr, true);
      return null;
    }
  }
}
