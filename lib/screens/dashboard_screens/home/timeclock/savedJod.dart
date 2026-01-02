import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/views/ui_helpers.dart';
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
      print("Coords in SavedJobsSheet: ${locationController.address.value}");
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        final bool isLoading = locationController.isLoading.value;
        final String address = locationController.address.value;

        return Wrap(
          runSpacing: 16,
          children: [
            /// --- Drag handle ---
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

            /// --- Title ---
            Center(
              child: kText(
                text: TranslationKeys.confirm.tr,
                fSize: 16.0,
                fWeight: FontWeight.bold,
              ),
            ),

            /// --- Address Info ---
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width,

                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: kText(
                              text:
                                  address.isNotEmpty
                                      ? address
                                      : "Unable to fetch address",
                              fSize: 14.0,
                              tColor: Colors.grey.shade600,
                              textoverflow: TextOverflow.ellipsis,
                              fWeight: fontWeightBold,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // const SizedBox(height: 6),
                    // kText(
                    //   text:
                    //       "(${coords.latitude.toStringAsFixed(5)}, ${coords.longitude.toStringAsFixed(5)})",
                    //   fSize: 12.0,
                    //   tColor: Colors.grey.shade500,
                    // ),
                  ],
                ),

            const SizedBox(height: 20),

            /// --- Buttons ---
            Row(
              children: [
                /// Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: kText(
                      text: TranslationKeys.cancel.tr,
                      fSize: 14.0,
                      tColor: kPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                /// Confirm Button
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed:
                          attendanceController.isClockInLoading.value
                              ? null
                              : () async {
                                await attendanceController.clockIn(
                                  method: data["method"],
                                  sourceDevice: data["sourceDevice"],
                                  remarks: data["remarks"],
                                  coords: coords,
                                  address: address, // Pass the address
                                );
                              },
                      child:
                          attendanceController.isClockInLoading.value
                              ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : kText(
                                text: TranslationKeys.confirm.tr,
                                fSize: 14.0,
                                fWeight: FontWeight.bold,
                                tColor: Colors.white,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
