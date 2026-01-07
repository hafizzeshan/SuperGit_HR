import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/date_time_helper.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

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
      appBar: appBarrWitAction(title: TranslationKeys.todayHistory.tr),
      backgroundColor: const Color(0xFFF1F3F8),

      body: Obx(() {
        if (controller.isLoadingToday.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final todayModel = controller.todayLogsModel.value;

        if (todayModel == null || todayModel.logs.isEmpty) {
          return Center(child: Text(TranslationKeys.noActivityLoggedToday.tr));
        }

        return RefreshIndicator(
          onRefresh: () async => controller.getTodayLogs(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todayModel.logs.length,
            itemBuilder: (_, index) {
              final log = todayModel.logs[index];

              return _modernHistoryTile(
                type: log.clockType,
                time: DateTimeHelper.utcToLocalTime(log.clockTime.toString()),
                remarks: log.remarks,
              );
            },
          ),
        );
      }),
    );
  }

  // -------------------------------------------------------------------------
  //                      MODERN BEAUTIFUL CARD TILE
  // -------------------------------------------------------------------------
  Widget _modernHistoryTile({
    required String? type,
    required String time,
    required String remarks,
  }) {
    final bool isClockIn = type?.toLowerCase().contains("in") ?? false;
    final bool isClockOut = type?.toLowerCase().contains("out") ?? false;

    // Modern gradient indicator color
    final Color indicatorColor =
        isClockIn
            ? Colors.green
            : isClockOut
            ? Colors.redAccent
            : kPrimaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),

        gradient: linearGradient2,
      ),

      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: linearGradient3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIcon(type),
                      color: indicatorColor,
                      size: 22,
                    ),
                  ),

                  UIHelper.horizontalSpaceSm15,

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kText(
                          text:
                              isClockIn
                                  ? TranslationKeys.clockedIn.tr
                                  : isClockOut
                                  ? TranslationKeys.clockedOut.tr
                                  : type ?? TranslationKeys.activity.tr,
                          fSize: 15,
                          fWeight: FontWeight.w600,
                          tColor: whiteColor,
                        ),

                        if (remarks.isNotEmpty) ...[
                          UIHelper.verticalSpaceSm5,
                          kText(
                            text: remarks,
                            fSize: 12,
                            tColor: Colors.grey.shade200,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // -----------------------------------------------------------
                  //                   TIME BADGE
                  // -----------------------------------------------------------
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: kText(
                      text: time,
                      fSize: 12.0,
                      fWeight: FontWeight.bold,
                      tColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  //                ICON MAPPING
  // -----------------------------------------------------------
  IconData _getIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'clock in':
      case 'in':
        return Icons.login;
      case 'clock out':
      case 'out':
        return Icons.logout;
      case 'break start':
        return Icons.pause_circle_filled;
      case 'break end':
        return Icons.play_circle_fill_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }
}
