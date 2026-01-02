import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/started_timeclock_screen.dart';
import 'package:supergithr/screens/dashboard_screens/dashboard.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/network/repository/attendance_repo/attendance_repo.dart';

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
      // Navigate to dashboard first, then to time clock screen
      // This prevents going back to the map screen
      Get.offAll(() => DashBorad(index: 0));
      Get.to(() => const TimeClockStartedScreen());
    }
  }

  /// ✅ Clock-Out (Stop timer)
  Future<void> clockOut({
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
}
