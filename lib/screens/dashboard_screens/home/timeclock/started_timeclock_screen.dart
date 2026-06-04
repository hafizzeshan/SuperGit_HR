import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/screens/dashboard_screens/dashboard.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

import 'package:supergithr/screens/dashboard_screens/home/timeclock/attendance_history_screen.dart';

class TimeClockStartedScreen extends StatefulWidget {
  const TimeClockStartedScreen({super.key});

  @override
  State<TimeClockStartedScreen> createState() => _TimeClockStartedScreenState();
}

class _TimeClockStartedScreenState extends State<TimeClockStartedScreen> {
  final AttendanceController _controller = Get.find<AttendanceController>();
  final AttendanceHistoryController _historyController =
      Get.find<AttendanceHistoryController>();
  final LocationController locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
  }

  /// ✅ End shift → pehle location ON check karo, phir confirm sheet kholo
  Future<void> _onEndShiftPressed(BuildContext context) async {
    // 1️⃣ Sabse pehle: location service (GPS) ON hai ya nahi? (currentLatLng
    // purani/stale ho sakti hai, is liye yahan seedha service check zaroori hai.)
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final shouldEnable = await _askEnableLocation();
      if (shouldEnable != true) return;
      // ✅ Sirf ek cheez: seedha device location settings screen kholo.
      // (requestService() peeche dusra system popup khol deta tha.)
      await Geolocator.openLocationSettings();
      // Settings se location ON karke wapas aayein, phir dobara Complete dabayein.
      return;
    }

    // 2️⃣ Location ON hai → ab fresh coordinates lo (stale coords pe bharosa
    // mat karo; service abhi-abhi on hui ho sakti hai).
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      barrierDismissible: false,
    );
    await locationController.getCurrentLocation();
    Get.back(); // Close loading

    if (locationController.currentLatLng.value == null) {
      Utils.snackBar(TranslationKeys.unableToFetchLocation.tr, true);
      return;
    }

    final coords = locationController.currentLatLng.value!;

    if (!mounted) return;
    // 3️⃣ Sab theek → Confirm Hours wali end-shift sheet kholo.
    _showConfirmEndShiftSheet(context, coords);
  }

  /// 🔔 Location OFF hone par enable karne ka dialog.
  Future<bool?> _askEnableLocation() {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: kText(
                text: TranslationKeys.locationRequired.tr,
                fSize: 18.0,
                fWeight: FontWeight.bold,
                tColor: Colors.black87,
              ),
            ),
          ],
        ),
        content: kText(
          text: TranslationKeys.locationServicesRequiredForClockOut.tr,
          fSize: 14.0,
          tColor: Colors.black87,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: kText(
              text: TranslationKeys.cancel.tr,
              fSize: 14.0,
              fWeight: FontWeight.w600,
              tColor: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: kText(
              text: TranslationKeys.enableLocation.tr,
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

  /// ✅ Confirmation Sheet (map + confirm/edit buttons)
  void _showConfirmEndShiftSheet(BuildContext context, LatLng coords) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Colors.red, size: 28),
                    ),
                    const SizedBox(height: 12),
                    kText(
                      text: TranslationKeys.confirmEndShift.tr,
                      fSize: 18.0,
                      fWeight: FontWeight.bold,
                      tColor: Colors.black87,
                    ),
                    const SizedBox(height: 6),
                    kText(
                      text: TranslationKeys.verifyLocationEndShift.tr,
                      fSize: 13.0,
                      tColor: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Map Card
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: coords,
                      zoom: 15,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId("currentLocation"),
                        position: coords,
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  // Edit Shift Button (Secondary)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditShiftSheet(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: kText(
                        text: TranslationKeys.editShift.tr,
                        fSize: 15.0,
                        fWeight: FontWeight.w600,
                        tColor: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Confirm Hours Button (Primary - Red for End Shift)
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _controller.isClockOutLoading.value
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _runClockOut(coords); 
                              },
                        child: _controller.isClockOutLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : kText(
                                text: TranslationKeys.confirmHours.tr,
                                fSize: 15.0,
                                fWeight: FontWeight.bold,
                                tColor: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✅ Clock-Out logic (LatLng supported)
  Future<void> _runClockOut(LatLng coords) async {
    print("🕒 Clock-Out initiated from UI with coords: $coords");

    // Ensure we have an address for remarks if possible
    if (locationController.address.value.isEmpty) {
      await locationController.getAddressFromLatLng(coords);
    }

    await _controller.clockOut(
      method: "App",
      sourceDevice: "Mobile",
      remarks:
          locationController.address.value.isNotEmpty
              ? locationController.address.value
              : TranslationKeys.unknown.tr,
      coords: coords, // ✅ Directly using the LatLng we passed
    );

    // After clock out, the controller will handle any navigation if needed,
    // but usually we want to go back to home.
    Get.offAll(() => DashBorad(index: 0));
  }

  /// ✅ Edit Shift Sheet (Updated Design)
  void _showEditShiftSheet(BuildContext context) {
    if (_controller.clockInTime.value == null) return;

    // Initialize with current clock-in info
    DateTime selectedDate = _controller.clockInTime.value!;
    TimeOfDay startTime = TimeOfDay.fromDateTime(selectedDate);
    TimeOfDay endTime = TimeOfDay.now();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.transparent,
      builder: (ct) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setMjState) {
            // Calculate Duration
            final dtStart = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              startTime.hour,
              startTime.minute,
            );
            var dtEnd = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              endTime.hour,
              endTime.minute,
            );

            // Handle overnight shift for duration calculation
            if (dtEnd.isBefore(dtStart)) {
              dtEnd = dtEnd.add(const Duration(days: 1));
            }

            final diff = dtEnd.difference(dtStart);
            final hours = diff.inHours.toString().padLeft(2, '0');
            final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
            final durationStr = "$hours ${TranslationKeys.h.tr} $minutes ${TranslationKeys.m.tr}";

            // Date Picker
            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate.isAfter(now) ? now : selectedDate,
                firstDate: DateTime(2000),
                lastDate: now,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: kPrimaryColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setMjState(() => selectedDate = picked);
              }
            }

            // Time Picker
            Future<void> pickTime(bool isStart) async {
              final initial = isStart ? startTime : endTime;
              final picked = await showTimePicker(
                context: context,
                initialTime: initial,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: kPrimaryColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setMjState(() {
                  if (isStart) {
                    startTime = picked;
                  } else {
                    endTime = picked;
                  }
                });
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ct).viewInsets.bottom + 24,
              ),
              child: FractionallySizedBox(
                heightFactor: 0.70,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Center(
                        child: kText(
                          text: TranslationKeys.requestEdit.tr,
                          fSize: 20.0,
                          fWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date Selection Card
                      InkWell(
                        onTap:(){},
                        // pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kMainBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  kText(
                                    text: TranslationKeys.date.tr, // Ensure 'Date' key or use string
                                    fSize: 12.0,
                                    tColor: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 4),
                                  kText(
                                    text:
                                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                    fSize: 16.0,
                                    fWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Selection Row
                      Row(
                        children: [
                          // Start Time
                          Expanded(
                            child: InkWell(
                              onTap: () => pickTime(true),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kMainBackgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.login_rounded,
                                          size: 16,
                                          color: Colors.green.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        kText(
                                          text: TranslationKeys.starts.tr,
                                          fSize: 12.0,
                                          tColor: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    kText(
                                      text: startTime.format(context),
                                      fSize: 18.0,
                                      fWeight: FontWeight.bold,
                                      tColor: Colors.black87,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // End Time
                          Expanded(
                            child: InkWell(
                              onTap: () => pickTime(false),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kMainBackgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          size: 16,
                                          color: Colors.red.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        kText(
                                          text: TranslationKeys.ends.tr,
                                          fSize: 12.0,
                                          tColor: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    kText(
                                      text: endTime.format(context),
                                      fSize: 18.0,
                                      fWeight: FontWeight.bold,
                                      tColor: Colors.black87,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Total Hours Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: kPrimaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            kText(
                              text: TranslationKeys.totalHours.tr,
                              fSize: 14.0,
                              fWeight: FontWeight.w500,
                              tColor: kPrimaryColor,
                            ),
                            kText(
                              text: durationStr,
                              fSize: 16.0,
                              fWeight: FontWeight.bold,
                              tColor: kPrimaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Note Input
                      kText(
                        text: TranslationKeys.addANote.tr,
                        fSize: 14.0,
                        fWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: TranslationKeys.attachNoteToRequest.tr,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: kMainBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: kPrimaryColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: kText(
                              text:
                                  TranslationKeys.allRequestsSentForApproval.tr,
                              fSize: 12.0,
                              tColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      LoadingButton(
                        isLoading: false,
                        text: TranslationKeys.sendForApproval.tr,
                        onTap: () async {
                          // Validation against future times
                          final now = DateTime.now();
                          final dtStart = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            startTime.hour,
                            startTime.minute,
                          );
                          var dtEnd = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            endTime.hour,
                            endTime.minute,
                          );

                          if (dtEnd.isBefore(dtStart)) {
                            dtEnd = dtEnd.add(const Duration(days: 1));
                          }

                          if (dtStart.isAfter(now) || dtEnd.isAfter(now)) {
                            Utils.snackBar(TranslationKeys.invalidTime.tr, true); // Fallback to a localized or safe string
                            return;
                          }

                          Navigator.pop(context);
                          
                          // Ensure we have coords
                          var coords = locationController.currentLatLng.value;
                          if (coords == null) {
                             await locationController.getCurrentLocation();
                             coords = locationController.currentLatLng.value;
                          }

                          if (coords == null) {
                             Utils.snackBar(TranslationKeys.unableToFetchLocation.tr, true);
                             return;
                          }

                          // Call Controller Method
                          await _controller.clockOutWithEditRequest(
                            coords: coords,
                            date: selectedDate,
                            startTime: startTime,
                            endTime: endTime,
                            reason: noteController.text.isNotEmpty ? noteController.text : TranslationKeys.shiftEditRequest.tr,
                          );

                          Utils.snackBar(
                            TranslationKeys.shiftEditRequestSent.tr,
                            false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _editRow(String title, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          kText(text: title, fSize: 14.0, fWeight: FontWeight.w500),
          value,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If timer is running (user is clocked in), go to home
        if (_controller.elapsedTime.value != "00:00:00") {
          Get.offAll(DashBorad(index: 0)); // Go to home/dashboard
          return false; // Prevent default back behavior
        }
        // If timer is not running, allow normal back navigation
        return true;
      },
      child: Scaffold(
        backgroundColor: kMainBackgroundColor,
        appBar: appBarrWitAction(
          title: TranslationKeys.timeClock.tr,
          actionwidget: IconButton(
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.black87,
              size: 22,
            ),
            onPressed: () => Get.to(() => const AttendanceHistoryScreen()),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // Main Timer Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Pulse Indicator & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.2, 1.2),
                              duration: 800.ms,
                            ),
                        const SizedBox(width: 8),
                        kText(
                          text: TranslationKeys.workingAsEmployee.tr,
                          fSize: 14.0,
                          tColor: Colors.grey.shade600,
                          fWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey.shade100),
                    const SizedBox(height: 20),

                    // Timer Big Text
                    Center(
                      child: Obx(
                        () => kText(
                          text: _controller.elapsedTime.value,
                          fSize: 48.0,
                          fWeight: FontWeight.bold,
                          tColor: kPrimaryColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Time Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() {
                        // Prefer latest "In" log from the server; fall back to local.
                        final start = _historyController.lastStartedAt ??
                            _controller.clockInTime.value?.toLocal();
                        final startStr =
                            start != null
                                ? "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}"
                                : "--:--";
                        return kText(
                          text: "${TranslationKeys.startedAt.tr} $startStr",
                          fSize: 14.0,
                          tColor: kPrimaryColor.withOpacity(0.8),
                          fWeight: FontWeight.w500,
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Location Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          kText(
                            text: TranslationKeys.location.tr,
                            fSize: 12.0,
                            tColor: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 4),
                          kText(
                            text:
                                _controller.clockInAddress.value.isNotEmpty
                                    ? _controller.clockInAddress.value
                                    : TranslationKeys.unknown.tr,
                            fSize: 14.0,
                            tColor: Colors.black87,
                            fWeight: FontWeight.w600,
                            maxLines: 2,
                            textoverflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Obx(
            () => LoadingButton(
              isLoading: _controller.isClockOutLoading.value,
              text: TranslationKeys.complete.tr,
              onTap: () => _onEndShiftPressed(context),
            ),
          ),
        ),
      ),
    );
  }
}
