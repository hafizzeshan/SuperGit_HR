import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/models/all_logs_model.dart';
import 'package:supergithr/models/attendance_logs.dart';
import 'package:supergithr/models/today_logs_model.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/colors.dart';

import '../network/repository/attendance_repo/employee_history_repo.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceHistoryRepository _repo = AttendanceHistoryRepository();

  var isLoadingToday = false.obs;
  var isLoadingAll = false.obs;

  Rxn<TodayLogsModel> todayLogsModel = Rxn<TodayLogsModel>();
  Rxn<AllLogsModel> allLogsModel = Rxn<AllLogsModel>();

  /// Latest log with `clock_type == "In"` from today's logs, or null.
  AttendanceLog? get latestClockInLog {
    final logs = todayLogsModel.value?.logs;
    if (logs == null || logs.isEmpty) return null;
    return _latestClockInLog(logs);
  }

  /// Local-time clock-in timestamp from the latest "In" log, or null.
  DateTime? get lastStartedAt => latestClockInLog?.clockTime.toLocal();

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
    final anchor =
        (localClockTime != null && localClockTime.isBefore(serverClockTime))
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
    final clockedIn = log.clockTime.toLocal();
    // Short form keeps the value on one line — the full month name was
    // getting cut off with an ellipsis on narrow phones.
    final date = DateFormat('EEE, d MMM yyyy').format(clockedIn);
    final time = DateFormat('hh:mm a').format(clockedIn);
    final device = log.sourceDevice.trim();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryColor.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: kPrimaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              kText(
                text: TranslationKeys.clockInActive.tr,
                fSize: 19.0,
                fWeight: FontWeight.w700,
                tColor: Colors.black87,
                textalign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              kText(
                text: TranslationKeys.currentlyClockedIn.tr,
                fSize: 13.0,
                tColor: Colors.grey.shade600,
                textalign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: kMainBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _clockedInDetailRow(
                      Icons.calendar_today_rounded,
                      TranslationKeys.date.tr,
                      date,
                    ),
                    _clockedInRowDivider(),
                    _clockedInDetailRow(
                      Icons.schedule_rounded,
                      TranslationKeys.clockTime.tr,
                      time,
                    ),
                    if (device.isNotEmpty) ...[
                      _clockedInRowDivider(),
                      _clockedInDetailRow(
                        Icons.phone_iphone_rounded,
                        TranslationKeys.device.tr,
                        device,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: kText(
                    text: TranslationKeys.okay.tr,
                    fSize: 15.0,
                    fWeight: FontWeight.w600,
                    tColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// One label/value line inside the clocked-in dialog's detail card.
  Widget _clockedInDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kPrimaryColor),
          const SizedBox(width: 12),
          kText(text: label, fSize: 13.0, tColor: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: kText(
              text: value,
              fSize: 13.5,
              fWeight: FontWeight.w600,
              tColor: Colors.black87,
              textalign: TextAlign.end,
              maxLines: 1,
              textoverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _clockedInRowDivider() =>
      Container(height: 1, color: Colors.grey.shade200);

  /// ✅ Fetch All Logs
  Future<void> getAllLogs() async {
    try {
      isLoadingAll.value = true;
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString("employee_id") ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar(TranslationKeys.employeeIdNotFound.tr, true);
        return;
      }

      final response = await _repo.fetchAllLogs(employeeId);
      if (response != null) {
        allLogsModel.value = AllLogsModel.fromMap(response);
        log("✅ Loaded All Logs");
      }
    } catch (e, st) {
      log("❌ Error loading all logs: $e", stackTrace: st);
      Utils.snackBar(TranslationKeys.failedToLoadAllLogs.tr, true);
    } finally {
      isLoadingAll.value = false;
    }
  }
}
