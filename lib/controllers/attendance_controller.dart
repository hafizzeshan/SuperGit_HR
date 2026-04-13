import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/started_timeclock_screen.dart';
import 'package:supergithr/screens/dashboard_screens/dashboard.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/network/repository/attendance_repo/attendance_repo.dart';
import 'package:supergithr/models/attendance_history_model.dart';
import 'package:supergithr/models/attendance_edit_request_model.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';

import '../translations/translations/translation_keys.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository _repo = AttendanceRepository();

  var isClockInLoading = false.obs;
  var isClockOutLoading = false.obs;
  var elapsedTime = "00:00:00".obs;
  var clockInTime = Rxn<DateTime>();
  var clockInAddress = "".obs; // Store clock-in address

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    restoreClockInState();
  }

  /// ✅ Restore saved clock-in session after app restart
  Future<void> restoreClockInState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getString('clock_in_time');
    final savedAddress = prefs.getString('clock_in_address');
    if (savedTime != null) {
      clockInTime.value = DateTime.parse(savedTime);
      clockInAddress.value = savedAddress ?? "";
      _startTimer();
    }
  }

  /// ✅ Clock-In (Start timer)
  Future<void> clockIn({
    required String method,
    required String sourceDevice,
    required String remarks,
    required LatLng coords,
    String? address, // Add address parameter
  }) async {
    isClockInLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    final String employeeId = prefs.getString('employee_id') ?? "";

    final data = {
      "method": method,
      "source_device": sourceDevice,
      "location": {"latitude": coords.latitude, "longitude": coords.longitude},
      "remarks": remarks,
      "employee_id": employeeId,
    };
    print(data);
    final response = await _repo.clockIn(data: data);
    isClockInLoading.value = false;

    if (response != null) {
      clockInTime.value = DateTime.now();
      clockInAddress.value = address ?? "";
      await prefs.setString(
        'clock_in_time',
        clockInTime.value!.toIso8601String(),
      );
      await prefs.setString('clock_in_address', clockInAddress.value);
      _startTimer();
      
      // ✅ Fetch today's logs to update history
      if (Get.isRegistered<AttendanceHistoryController>()) {
         Get.find<AttendanceHistoryController>().getTodayLogs();
      }

      // Navigate to dashboard first, then to time clock screen
      // This prevents going back to the map screen
      Get.offAll(() => DashBorad(index: 0));
      Get.to(() => const TimeClockStartedScreen());
    }
  }

  /// ✅ Clock-Out (Stop timer)
  Future<Map<String, dynamic>?> clockOut({
    required String method,
    required String sourceDevice,
    required String remarks,
    required LatLng coords,
  }) async {
    isClockOutLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    final String employeeId = prefs.getString('employee_id') ?? "";

    final data = {
      "method": method,
      "source_device": sourceDevice,
      "location": {"latitude": coords.latitude, "longitude": coords.longitude},
      "remarks": remarks,
      "employee_id": employeeId,
    };

    final response = await _repo.clockOut(data: data);
    isClockOutLoading.value = false;

    if (response != null) {
      _stopTimer();
      await prefs.remove('clock_in_time');
      await prefs.remove('clock_in_address');
      
      // ✅ Fetch today's logs to update history
      if (Get.isRegistered<AttendanceHistoryController>()) {
         Get.find<AttendanceHistoryController>().getTodayLogs();
      }

      return response;
    }
    return null;
  }

  /// ✅ Clock-Out With Edit Request
  Future<void> clockOutWithEditRequest({
    required LatLng coords,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String reason,
  }) async {
    // 1. First, clock out partially to end the session
    // We use "Mobile" and empty remark or "Edit Request" remark
    final response = await clockOut(
      method: "App",
      sourceDevice: "Mobile",
      remarks: "Clock out with edit request: $reason",
      coords: coords,
    );

    if (response != null) {
      // 2. Extract Attendance ID from response
      // Assuming response structure: { "data": { "id": "..." } } or { "id": "..." }
      String? attendanceId;
      if (response['data'] != null && response['data'] is Map) {
        attendanceId = response['data']['id']?.toString();
        print("attendanceId: $attendanceId");
      } else if (response['id'] != null) {
        attendanceId = response['id']?.toString();
        print("attendanceId: $attendanceId");
      }

      if (attendanceId != null) {
        // Format Times
        final startStr =
            "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
        final endStr =
            "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
        final dateStr =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        final dto = CreateEditRequestDTO(
          date: dateStr,
          requestedClockInTime: startStr,
          requestedClockOutTime: endStr,
          reason: reason,
        );

        // 3. Create Edit Request
        await createEditAttendanceRequest(
          attendanceId: attendanceId,
          requestDto: dto,
        );

        // Navigation handled in CreateEditRequest or here
        Get.offAll(() => DashBorad(index: 0));
      } else {
        Utils.snackBar(TranslationKeys.failedToRetrieveAttendanceID.tr, true);
        Get.offAll(() => DashBorad(index: 0));
      }
    }
  }

  /// ✅ Auto stop local timer (when server says not clocked in)
  Future<void> autoStopLocalTimer() async {
    print("🔹 Auto stopping local timer - server says not clocked in");
    _stopTimer();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('clock_in_time');
    await prefs.remove('clock_in_address');
  }

  /// ✅ Auto clock-out via API (when clock-in exceeds 13 hours)
  Future<void> autoClockOut() async {
    print("🔹 Auto clock-out triggered - exceeded 13 hours");
    final prefs = await SharedPreferences.getInstance();
    final String employeeId = prefs.getString('employee_id') ?? "";

    final data = {
      "method": "App",
      "source_device": "Mobile",
      "location": {"latitude": 0.0, "longitude": 0.0},
      "remarks": "Auto clock-out: exceeded 13 hours",
      "employee_id": employeeId,
    };

    final response = await _repo.clockOut(data: data);
    if (response != null) {
      _stopTimer();
      await prefs.remove('clock_in_time');
      await prefs.remove('clock_in_address');
      print("✅ Auto clock-out successful");
    } else {
      // If API fails, still stop local timer to stay in sync
      _stopTimer();
      await prefs.remove('clock_in_time');
      await prefs.remove('clock_in_address');
      print("⚠️ Auto clock-out API failed, local timer stopped");
    }
  }

  /// ✅ Timer handling
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (clockInTime.value == null) return;
      final diff = DateTime.now().difference(clockInTime.value!);
      elapsedTime.value =
          "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    elapsedTime.value = "00:00:00";
    clockInTime.value = null;
    clockInAddress.value = "";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Attendance History Variables
  var attendanceHistory = <Months>[].obs;
  var isHistoryLoading = false.obs;

  /// ✅ Fetch Attendance History
  Future<void> getAttendanceHistory({
    required String startDate,
    required String endDate,
  }) async {
    isHistoryLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar(TranslationKeys.employeeIdNotFound.tr, true);
        isHistoryLoading.value = false;
        return;
      }

      final response = await _repo.getAttendanceHistory(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
      );

      if (response != null) {
        final model = AttendanceHistoryModel.fromJson(response);
        if (model.months != null) {
          attendanceHistory.assignAll(model.months!);
        } else {
          attendanceHistory.clear();
        }
      } else {
        attendanceHistory.clear();
      }
    } catch (e) {
      print("Error fetching history: $e");
      attendanceHistory.clear();
    } finally {
      isHistoryLoading.value = false;
    }
  }

  // Edit Request State
  var isEditRequestLoading = false.obs;

  /// ✅ Create Attendance Edit Request
  Future<void> createEditAttendanceRequest({
    required String attendanceId,
    required CreateEditRequestDTO requestDto,
  }) async {
    isEditRequestLoading.value = true;
    try {
      print("Edit Request Payload: ${requestDto.toJson()}");
      final response = await _repo.createEditRequest(
        attendanceId: attendanceId,
        data: requestDto.toJson(),
      );

      if (response != null) {
        // Handle success
        Get.back(); // Close dialog/bottom sheet
      }
    } catch (e) {
      print("Error creating edit request: $e");
    } finally {
      isEditRequestLoading.value = false;
    }
  }
}
