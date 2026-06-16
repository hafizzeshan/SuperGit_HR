import 'dart:developer';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:supergithr/utils/utils.dart';

class AttendanceHistoryRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Fetch Today's Logs
  Future<Map<String, dynamic>?> fetchTodayLogs(String employeeId) async {
    try {
      final response = await _api.getRequest(
        "${AppURL.todayLogsApi}/$employeeId",
      );

      if (response == null) {
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Today's Logs: ${response.data}");
        return response.data;
      } else {
        final message =
            Utils.extractApiError(response.data, "Failed to load today's logs");
        Utils.snackBar(message, true);
        log("❌ Fetch Today's Logs failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in fetchTodayLogs: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.errorLoadingTodaysLogs.tr, true);
      return null;
    }
  }

  /// ✅ Fetch All Logs
  Future<Map<String, dynamic>?> fetchAllLogs(String employeeId) async {
    try {
      final response = await _api.getRequest(
        "${AppURL.allLogsApi}/$employeeId",
      );

      if (response == null) {
        Utils.snackBar(TranslationKeys.unableToReachServer.tr, true);
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ All Logs: ${response.data}");
        return response.data;
      } else {
        final message = Utils.extractApiError(response.data, "Failed to load all logs");
        Utils.snackBar(message, true);
        log("❌ Fetch All Logs failed: $message");
        return null;
      }
    } catch (e, st) {
      log("❌ Exception in fetchAllLogs: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.errorLoadingAllLogs.tr, true);
      return null;
    }
  }
}
