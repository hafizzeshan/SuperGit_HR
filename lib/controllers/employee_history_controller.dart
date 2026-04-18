import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/models/all_logs_model.dart';
import 'package:supergithr/models/attendance_logs.dart';
import 'package:supergithr/models/today_logs_model.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/customText.dart';

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

        // Auto clock-out if server says not clocked in but local timer is running
        _checkAndAutoClockOut();
      }
    } catch (e, st) {
      // Don't show error message - let the 401 interceptor handle session expiry
      log("❌ Error loading today's logs: $e", stackTrace: st);
    } finally {
      isLoadingToday.value = false;
    }
  }

  /// ✅ Sync local clock-in state with server on app open.
  /// Cases:
  /// 1. Server clocked in + elapsed ≥ 13h → force GPS + call clock-out API
  /// 2. Server clocked in + local timer not running → start timer from server time + popup
  /// 3. Server clocked in + local timer drift > 2s vs server → resync + popup
  /// 4. Server clocked in + in sync → no-op
  /// 5. Server NOT clocked in + local timer running → stop local timer (no API)
  void _checkAndAutoClockOut() {
    if (!Get.isRegistered<AttendanceController>()) return;
    final attendanceController = Get.find<AttendanceController>();
    final todayLogs = todayLogsModel.value;
    if (todayLogs == null) return;

    final isLocallyRunning = attendanceController.clockInTime.value != null;

    // Case 5: Server says not clocked in → stop local timer, no API
    if (!todayLogs.currentlyClockedIn) {
      if (isLocallyRunning) {
        log("⚠️ Server not clocked in but local timer running. Stopping.");
        attendanceController.autoStopLocalTimer();
      }
      return;
    }

    // Server says clocked in — find latest "In" log for reference time
    final latestIn = _latestClockInLog(todayLogs.logs);
    if (latestIn == null) return;

    // Anchor elapsed on the earlier of server/local (safer for the 13h check).
    final serverClockTime = latestIn.clockTime;
    final localClockTime = attendanceController.clockInTime.value;
    final anchor = (localClockTime != null && localClockTime.isBefore(serverClockTime))
        ? localClockTime
        : serverClockTime;
    final elapsed = DateTime.now().difference(anchor);

    // Case 1: 13+ hours → force-enable GPS + call clock-out API
    if (elapsed.inHours >= 13) {
      log("⚠️ Clock-in exceeded 13 hours. Forcing auto clock-out.");
      attendanceController.autoClockOut();
      return;
    }

    // Case 4: already in sync
    if (isLocallyRunning) {
      final drift = localClockTime!.difference(serverClockTime).abs();
      if (drift.inSeconds <= 2) return;
    }

    // Cases 2 & 3: start or resync timer from server time + show popup
    attendanceController.syncClockInFromServer(serverClockTime);
    _showCurrentlyClockedInDialog(latestIn);
  }

  AttendanceLog? _latestClockInLog(List<AttendanceLog> logs) {
    AttendanceLog? latest;
    for (final log in logs) {
      if (log.clockType.toLowerCase() != 'in') continue;
      if (latest == null || log.clockTime.isAfter(latest.clockTime)) {
        latest = log;
      }
    }
    return latest;
  }

  void _showCurrentlyClockedInDialog(AttendanceLog log) {
    final formatted = DateFormat('MMM d, yyyy hh:mm a').format(log.clockTime.toLocal());
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: kText(
                text: "Clock-In Active",
                fSize: 18.0,
                fWeight: FontWeight.bold,
                tColor: Colors.black87,
              ),
            ),
          ],
        ),
        content: kText(
          text: "You are currently clocked in from ${log.sourceDevice} at $formatted",
          fSize: 14.0,
          tColor: Colors.black87,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: kText(
              text: "OK",
              fSize: 14.0,
              fWeight: FontWeight.w600,
              tColor: Colors.white,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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
