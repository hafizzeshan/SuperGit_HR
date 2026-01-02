import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/all_logs_model.dart';
import 'package:supergithr/models/today_logs_model.dart';
import 'package:supergithr/utils/utils.dart';

import '../network/repository/attendance_repo/employee_history_repo.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceHistoryRepository _repo = AttendanceHistoryRepository();

  var isLoadingToday = false.obs;
  var isLoadingAll = false.obs;

  Rxn<TodayLogsModel> todayLogsModel = Rxn<TodayLogsModel>();
  Rxn<AllLogsModel> allLogsModel = Rxn<AllLogsModel>();

  /// ✅ Fetch Today's Logs
  Future<void> getTodayLogs() async {
    try {
      isLoadingToday.value = true;
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString("employee_id") ?? "";

      if (employeeId.isEmpty) {
        log("⚠️ Employee ID not found");
        return;
      }

      final response = await _repo.fetchTodayLogs(employeeId);
      if (response != null) {
        todayLogsModel.value = TodayLogsModel.fromMap(response);
        log("✅ Loaded Today's Logs");
      }
    } catch (e, st) {
      // Don't show error message - let the 401 interceptor handle session expiry
      log("❌ Error loading today's logs: $e", stackTrace: st);
    } finally {
      isLoadingToday.value = false;
    }
  }

  /// ✅ Fetch All Logs
  Future<void> getAllLogs() async {
    try {
      isLoadingAll.value = true;
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString("employee_id") ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar("Employee ID not found. Please log in again.", true);
        return;
      }

      final response = await _repo.fetchAllLogs(employeeId);
      if (response != null) {
        allLogsModel.value = AllLogsModel.fromMap(response);
        log("✅ Loaded All Logs");
      }
    } catch (e, st) {
      log("❌ Error loading all logs: $e", stackTrace: st);
      Utils.snackBar("Failed to load all logs", true);
    } finally {
      isLoadingAll.value = false;
    }
  }
}
