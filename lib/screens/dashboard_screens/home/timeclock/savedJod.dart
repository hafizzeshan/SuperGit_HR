import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class SavedJobsSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const SavedJobsSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final AttendanceController attendanceController =
        Get.find<AttendanceController>();
    final LocationController locationController =
        Get.find<LocationController>();

    final LatLng coords = data['coords'] as LatLng;

    /// ✅ Fetch address for provided coordinates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationController.getAddressFromLatLng(coords);
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          )),
      child: Obx(() {
        final bool isLoading = locationController.isLoading.value;
        final String address = locationController.address.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Drag handle ---
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

            /// --- Header ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on_rounded,
                        color: kPrimaryColor, size: 28),
                  ),
                  const SizedBox(height: 12),
                  kText(
                    text: TranslationKeys.confirmClockInLocation.tr,
                    fSize: 18.0,
                    fWeight: FontWeight.bold,
                    tColor: Colors.black87,
                  ),
                  const SizedBox(height: 5),
                  kText(
                    text: TranslationKeys.verifyLocationClockIn.tr,
                    fSize: 13.0,
                    tColor: Colors.grey.shade500,
                    textalign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            /// --- Address Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: isLoading
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kPrimaryColor)),
                    ))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.map_outlined, color: kPrimaryColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kText(
                                text: TranslationKeys.detectedLocation.tr,
                                fSize: 11.0,
                                tColor: Colors.grey.shade500,
                                fWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 4),
                              kText(
                                text: address.isNotEmpty
                                    ? address
                                    : TranslationKeys.unknown.tr,
                                fSize: 14.0,
                                tColor: Colors.black87,
                                fWeight: FontWeight.w600,
                                maxLines: 3,
                                textoverflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              kText(
                                text:
                                    "${coords.latitude.toStringAsFixed(5)}, ${coords.longitude.toStringAsFixed(5)}",
                                fSize: 11.0,
                                tColor: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            /// --- Buttons ---
            Row(
              children: [
                /// Cancel Button
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: kText(
                      text: TranslationKeys.cancel.tr,
                      fSize: 15.0,
                      fWeight: FontWeight.w600,
                      tColor: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                /// Confirm Button
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                         elevation: 0,
                         shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: attendanceController.isClockInLoading.value || isLoading
                          ? null
                          : () async {
                              await attendanceController.clockIn(
                                method: data["method"],
                                sourceDevice: data["sourceDevice"],
                                remarks: data["remarks"],
                                coords: coords,
                                address: address,
                              );
                            },
                      child: attendanceController.isClockInLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : kText(
                              text: TranslationKeys.confirm.tr,
                              fSize: 15.0,
                              fWeight: FontWeight.bold,
                              tColor: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        );
      }),
    );
  }
}
