import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/attendance_history_screen.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/date_time_helper.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/custom_animated_views.dart';

class TodayHistoryScreen extends StatefulWidget {
  const TodayHistoryScreen({super.key});

  @override
  State<TodayHistoryScreen> createState() => _TodayHistoryScreenState();
}

class _TodayHistoryScreenState extends State<TodayHistoryScreen> {
  final AttendanceHistoryController controller =
      Get.find<AttendanceHistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(
        title: TranslationKeys.todayHistory.tr,
        actionwidget: IconButton(
          icon: const Icon(
            Icons.calendar_month_rounded,
            color: Colors.black87,
            size: 22,
          ),
          onPressed: () => Get.to(() => const AttendanceHistoryScreen()),
        ),
      ),
      backgroundColor: kMainBackgroundColor, // Use standard background

      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          if (controller.isLoadingToday.value &&
              (controller.todayLogsModel.value == null ||
                  controller.todayLogsModel.value!.logs.isEmpty)) {
            return _buildShimmerList();
          }

          final todayModel = controller.todayLogsModel.value;

          if (todayModel == null || todayModel.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    TranslationKeys.noActivityLoggedToday.tr,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => controller.getTodayLogs(),
            color: kPrimaryColor,
            child: CustomAnimatedListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: todayModel.logs.length,
              itemBuilder: (_, index) {
                final log = todayModel.logs[index];

                return _modernHistoryTile(
                  type: log.clockType,
                  time: DateTimeHelper.utcToLocalTime(log.clockTime.toString()),
                  remarks: log.remarks ?? "", // Handle null explicitly
                  method: log.method,
                  device: log.sourceDevice,
                );
              },
            ),
          );
        }),
      ),
    );
  }

  // -------------------------------------------------------------------------
  //                      MODERN WHITE CARD TILE
  // -------------------------------------------------------------------------
  Widget _modernHistoryTile({
    required String? type,
    required String time,
    required String remarks,
    String? method,
    String? device,
  }) {
    final bool isClockIn = type?.toLowerCase().contains("in") ?? false;
    final bool isClockOut = type?.toLowerCase().contains("out") ?? false;

    // Modern indicator color
    final Color indicatorColor =
        isClockIn
            ? Colors.green
            : isClockOut
            ? Colors.red
            : kPrimaryColor;

    final IconData icon =
        isClockIn
            ? Icons.login
            : isClockOut
            ? Icons.logout
            : Icons.access_time_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: indicatorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: indicatorColor, size: 20),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kText(
                      text:
                          isClockIn
                              ? TranslationKeys.clockedIn.tr
                              : isClockOut
                              ? TranslationKeys.clockedOut.tr
                              : type ?? TranslationKeys.activity.tr,
                      fSize: 14.0,
                      fWeight: FontWeight.w600,
                      tColor: Colors.black87,
                    ),
                    kText(
                      text: time,
                      fSize: 14.0,
                      fWeight: FontWeight.bold,
                      tColor: kPrimaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Device Info Row
                Row(
                  children: [
                    Icon(Icons.devices, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: kText(
                        text:
                            "${method ?? TranslationKeys.unknown.tr} • ${device ?? TranslationKeys.unknown.tr}",
                        fSize: 12.0,
                        tColor: Colors.grey.shade600,
                        maxLines: 1,
                        textoverflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Remarks
                if (remarks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: kText(
                            text: remarks,
                            fSize: 11.0,
                            tColor: Colors.grey.shade700,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  //                SHIMMER LOADING
  // -----------------------------------------------------------
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade100,
                highlightColor: Colors.white,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade100,
                      highlightColor: Colors.white,
                      child: Container(
                        width: 150,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade100,
                      highlightColor: Colors.white,
                      child: Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
