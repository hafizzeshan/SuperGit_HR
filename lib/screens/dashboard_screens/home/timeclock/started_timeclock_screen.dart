import 'package:flutter/material.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              kText(
                text: TranslationKeys.confirmEndShift.tr,
                fSize: 18.0,
                fWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: coords,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      position: coords,
                    ),
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => LoadingButton(
                        isLoading: _controller.isClockOutLoading.value,
                        text: TranslationKeys.confirmHours.tr,
                        onTap: () async {
                          Navigator.pop(context);
                          await _runClockOut(coords); // ✅ Now passing LatLng
                        },
                      ),
                    ),
                  ),
                  UIHelper.horizontalSpaceSm10,
                  Expanded(
                    child: LoadingButton(
                      isLoading: false,
                      text: TranslationKeys.editShift.tr,
                      onTap: () {
                        Navigator.pop(context);
                        _showEditShiftSheet(context);
                      },
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
      remarks: locationController.address.value.isNotEmpty
          ? locationController.address.value
          : "Clock out from mobile app",
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
      backgroundColor: Colors.white,
      builder: (ct) {
        return Padding(
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
                      Utils.snackBar(TranslationKeys.shiftEditRequestSent.tr, false);
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
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: appBarrWitAction(
          title: TranslationKeys.timeClock.tr,
          actionwidget: const Icon(Icons.history),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [kSecondaryColor, kPrimaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: TranslationKeys.workingAsEmployee.tr,
                    fSize: 14.0,
                    tColor: Colors.white,
                  ),
                  UIHelper.verticalSpaceSm20,
                  Center(
                    child: Obx(
                      () => kText(
                        text: _controller.elapsedTime.value,
                        fSize: 40.0,
                        fWeight: FontWeight.bold,
                        tColor: Colors.white,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceSm20,
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      UIHelper.horizontalSpaceSm5,
                      Expanded(
                        child: kText(
                          text:
                              "${TranslationKeys.startedAt.tr}: ${_controller.clockInAddress.value}",
                          fSize: 13.0,
                          tColor: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
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
