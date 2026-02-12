import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/announcements/announcements_list.dart';
import 'package:supergithr/screens/dashboard_screens/home/holidays/holidays.dart';
import 'package:supergithr/screens/dashboard_screens/home/leave_summary/show_leavers.dart';
import 'package:supergithr/screens/dashboard_screens/home/loan_screen/loans.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/clock_in_map.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/started_timeclock_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/today_history/today_history.dart';
import 'package:supergithr/screens/dashboard_screens/setting/doc/personal_document.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/custom_animated_views.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

import 'package:supergithr/views/appBar.dart';

class QuickActionsGridScreen extends StatelessWidget {
  const QuickActionsGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController attendanceController =
        Get.find<AttendanceController>();

    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.timer_outlined,
        'title': TranslationKeys.timeTracking.tr,
        'onTap': () async {
          if (attendanceController.elapsedTime.value != "00:00:00") {
            Get.to(() => const TimeClockStartedScreen());
          } else {
            final result = await Get.to(() => const ClockInMapScreen());
            if (result != null) {
              Utils.snackBar("Clocked in at: $result", false);
            }
          }
        },
      },
      {
        'icon': Icons.history,
        'title': TranslationKeys.todayHistory.tr,
        'onTap': () {
          final c = Get.find<AttendanceHistoryController>();
          if (c.todayLogsModel.value == null ||
              c.todayLogsModel.value!.logs.isEmpty) {
            c.getTodayLogs();
          }
          Get.to(() => TodayHistoryScreen());
        },
      },
      {
        'icon': Icons.monetization_on_outlined,
        'title': TranslationKeys.loansAndExpenses.tr,
        'onTap': () {
          Get.to(() => LoanScreen());
        },
      },
      {
        'icon': Icons.calendar_today_outlined,
        'title': TranslationKeys.leaveSummary.tr,
        'onTap': () {
          Get.to(() => const LeaveSummaryScreen());
        },
      },
      {
        'icon': Icons.campaign_rounded,
        'title': TranslationKeys.announcements.tr,
        'onTap': () {
          Get.to(() => const AnnouncementsListScreen());
        },
      },
      {
        'icon': Icons.calendar_month_rounded,
        'title': TranslationKeys.holidays.tr,
        'onTap': () {
          Get.to(() => const HolidayScreen());
        },
      },
      {
        'icon': Icons.folder_shared_rounded,
        'title': TranslationKeys.personalDocuments.tr,
        'onTap': () {
          Get.to(() => PersonalDocumentsScreen());
        },
      },
    ];

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: TranslationKeys.quickActions.tr),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kMainBackgroundGradient,
        ),
        child: CustomAnimatedGridView(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              icon: action['icon'],
              title: action['title'],
              onTap: action['onTap'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor.withOpacity(0.08),
              ),
              child: Icon(icon, color: kPrimaryColor, size: 28),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textStyleMontserratBold(
                      fontSize: 15.0,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
