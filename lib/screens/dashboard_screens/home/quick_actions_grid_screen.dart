import 'package:flutter/material.dart';
import 'package:supergithr/views/safe_insets.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/controllers/team_leave_controller.dart';
import 'package:supergithr/controllers/social_post_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/air_tickets/air_tickets_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/team_leave/team_leave_requests_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/holidays/holidays.dart';
import 'package:supergithr/screens/dashboard_screens/home/leave_summary/show_leavers.dart';
import 'package:supergithr/screens/dashboard_screens/home/loan_screen/loans.dart';
import 'package:supergithr/screens/dashboard_screens/home/discipline/discipline_admin_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/discipline/discipline_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/remote_work/remote_approvals_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/remote_work/remote_work_screen.dart';
import 'package:supergithr/models/remote_work_model.dart';
import 'package:supergithr/screens/dashboard_screens/home/ethics/ethics_reports_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/overtime/overtime_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/overtime/overtime_approvals_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/clock_in_map.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/started_timeclock_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/today_history/today_history.dart';
import 'package:supergithr/services/force_update_service.dart';
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

    // Role flags, resolved once so the list below reads in plain order and
    // each feature can sit next to its own approvals tile.
    final bool canReview =
        Get.isRegistered<TeamLeaveController>() &&
        Get.find<TeamLeaveController>().canReview;
    final bool isAdmin =
        Get.isRegistered<SocialPostController>() &&
        Get.find<SocialPostController>().isAdmin.value;

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

      // ── remote work + its approvals ──────────────────────────────────
      {
        'icon': Icons.laptop_mac_rounded,
        'title': TranslationKeys.remoteWork.tr,
        'onTap': () {
          Get.to(() => const RemoteWorkScreen());
        },
      },
      if (canReview)
        {
          'icon': Icons.approval_rounded,
          'title': TranslationKeys.remoteApprovals.tr,
          'onTap': () {
            Get.to(
              () => const RemoteApprovalsScreen(mode: ApprovalMode.teamLead),
            );
          },
        },
      if (isAdmin)
        {
          'icon': Icons.verified_user_outlined,
          'title':
              "${TranslationKeys.remoteApprovals.tr} · ${TranslationKeys.adminReview.tr}",
          'onTap': () {
            Get.to(() => const RemoteApprovalsScreen(mode: ApprovalMode.admin));
          },
        },

      // ── overtime + its approvals ─────────────────────────────────────
      {
        'icon': Icons.more_time_rounded,
        'title': TranslationKeys.overtime.tr,
        'onTap': () {
          Get.to(() => const OvertimeScreen());
        },
      },
      if (canReview)
        {
          'icon': Icons.fact_check_outlined,
          'title': TranslationKeys.overtimeApprovals.tr,
          'onTap': () {
            Get.to(() => const OvertimeApprovalsScreen(isAdmin: false));
          },
        },
      if (isAdmin)
        {
          'icon': Icons.payments_outlined,
          'title':
              "${TranslationKeys.overtimeApprovals.tr} · ${TranslationKeys.adminReview.tr}",
          'onTap': () {
            Get.to(() => const OvertimeApprovalsScreen(isAdmin: true));
          },
        },

      // ── leave + team leave approvals ─────────────────────────────────
      {
        'icon': Icons.calendar_today_outlined,
        'title': TranslationKeys.leaveSummary.tr,
        'onTap': () {
          Get.to(() => const LeaveSummaryScreen());
        },
      },
      if (canReview)
        {
          'icon': Icons.playlist_add_check_rounded,
          'title': "Team Leave Requests",
          'onTap': () {
            Get.to(() => const TeamLeaveRequestsScreen());
          },
        },

      // ── conduct ──────────────────────────────────────────────────────
      {
        'icon': Icons.shield_outlined,
        'title': TranslationKeys.ethicsReports.tr,
        'onTap': () {
          Get.to(() => const EthicsReportsScreen());
        },
      },
      {
        'icon': Icons.balance_rounded,
        'title': TranslationKeys.discipline.tr,
        'onTap': () {
          Get.to(() => const DisciplineScreen());
        },
      },
      if (isAdmin)
        {
          'icon': Icons.gavel_rounded,
          'title': TranslationKeys.manageDiscipline.tr,
          'onTap': () {
            Get.to(() => const DisciplineAdminScreen());
          },
        },

      {
        'icon': Icons.calendar_month_rounded,
        'title': TranslationKeys.holidays.tr,
        'onTap': () {
          Get.to(() => const HolidayScreen());
        },
      },

      // Hidden unless the matching Remote Config flag is on.
      if (ForceUpdateService.showLoans)
        {
          'icon': Icons.monetization_on_outlined,
          'title': TranslationKeys.loansAndExpenses.tr,
          'onTap': () {
            Get.to(() => LoanScreen());
          },
        },
      if (ForceUpdateService.showAirTickets)
        {
          'icon': Icons.flight_takeoff_rounded,
          'title': "Air Tickets",
          'onTap': () {
            Get.to(() => const AirTicketsScreen());
          },
        },
    ];

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: TranslationKeys.quickActions.tr),
      body: Container(
        // Fill the whole body, including the area behind the home indicator,
        // so no bare strip shows under the grid.
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: CustomAnimatedGridView(
          // Bottom padding follows the device inset, so the last row clears
          // the home indicator instead of being cut off by it.
          padding: EdgeInsets.fromLTRB(
            16,
            18,
            16,
            18 + MediaQuery.paddingOf(context).bottom,
          ).atLeastBottom(context.gestureInset + 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            // Flatter than square so more rows fit on small screens, while
            // still leaving room for the icon plus a two-line title — checked
            // down to a 320pt wide device.
            childAspectRatio: 1.2,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor.withValues(alpha: 0.08),
              ),
              child: Icon(icon, color: kPrimaryColor, size: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textStyleMontserratBold(
                      fontSize: 13.5,
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
