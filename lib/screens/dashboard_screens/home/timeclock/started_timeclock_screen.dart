import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
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
  final LocationController locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
  }

  /// ✅ End shift → open confirmation sheet
  Future<void> _onEndShiftPressed(BuildContext context) async {
    // Show a small loading if location is not ready
    if (locationController.currentLatLng.value == null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
        barrierDismissible: false,
      );
      await locationController.getCurrentLocation();
      Get.back(); // Close loading
    }

    if (locationController.currentLatLng.value == null) {
      Utils.snackBar(TranslationKeys.unableToFetchLocation.tr, true);
      return;
    }

    final coords = locationController.currentLatLng.value!;

    if (!mounted) return;
    _showConfirmEndShiftSheet(context, coords);
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

  /// ✅ Edit Shift Sheet
  void _showEditShiftSheet(BuildContext context) {
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (ct) {
        return Container(
          decoration: const BoxDecoration(
            gradient: kMainBackgroundGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ct).viewInsets.bottom + 20,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.75,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  kText(
                    text: TranslationKeys.requestEdit.tr,
                    fSize: 18.0,
                    fWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  // _editRow(
                  //   "Job",
                  //   Chip(label: kText(text: "Flutter Developer", fSize: 12.0)),
                  // ),
                  _editRow(
                    TranslationKeys.starts.tr,
                    Obx(() {
                      final start = _controller.clockInTime.value;
                      return kText(
                        text:
                            start != null
                                ? "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} • ${start.day}/${start.month}/${start.year}"
                                : "-",
                        fSize: 14.0,
                        tColor: Colors.blue,
                      );
                    }),
                  ),
                  _editRow(
                    TranslationKeys.totalHours.tr,
                    Obx(
                      () => kText(
                        text: _controller.elapsedTime.value,
                        fSize: 15.0,
                        fWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: kText(
                      text: TranslationKeys.addANote.tr,
                      fSize: 14.0,
                      fWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: TranslationKeys.attachNoteToRequest.tr,
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  kText(
                    text: TranslationKeys.allRequestsSentForApproval.tr,
                    fSize: 12.0,
                    tColor: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  LoadingButton(
                    isLoading: false,
                    text: TranslationKeys.sendForApproval.tr,
                    onTap: () {
                      Navigator.pop(context);
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
                        final start = _controller.clockInTime.value;
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
