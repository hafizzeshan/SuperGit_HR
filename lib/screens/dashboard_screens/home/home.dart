import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/holidays/holidays.dart';
import 'package:supergithr/screens/dashboard_screens/home/leave_summary/show_leavers.dart';
import 'package:supergithr/screens/dashboard_screens/home/loan_screen/loans.dart';
import 'package:supergithr/screens/dashboard_screens/home/salary/salary_structure.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/clock_in_map.dart';
import 'package:supergithr/screens/dashboard_screens/home/notification.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/started_timeclock_screen.dart';
import 'package:supergithr/screens/dashboard_screens/home/today_history/today_history.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/announcement_bottom_sheet.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';
import '../../../controllers/employee_history_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../translations/translations/translation_keys.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/announcement_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/announcements/announcements_list.dart';
import '../../../utils/localization_helper.dart';

import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/views/custom_animated_views.dart';
import 'package:supergithr/screens/dashboard_screens/home/quick_actions_grid_screen.dart';
import 'package:supergithr/screens/dashboard_screens/setting/profile_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AttendanceController _attendanceController = Get.put(
    AttendanceController(),
  );
  final _profileController = Get.find<ProfileController>();
  final AnnouncementController _announcementController = Get.find<AnnouncementController>();

  @override
  void initState() {
    super.initState();
    // ✅ Refresh announcements if not already loaded (fixes login issue)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_announcementController.announcements.isEmpty) {
        _announcementController.fetchAnnouncements();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = _profileController.userModel.value;
    final firstName = user.firstNameEn ?? TranslationKeys.user.tr;
    final lastName = user.lastNameEn ?? "";

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Avatar, Greeting, Notification
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => ProfileViewScreen());
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kPrimaryColor,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      firstName.isNotEmpty
                                          ? firstName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      kText(
                                        text:
                                            LocalizationHelper.getTimeBasedGreeting(),
                                        fSize: 13.0,
                                        tColor: Colors.grey.shade600,
                                      ),
                                      kText(
                                        text: "$firstName $lastName",
                                        fSize: 16.0,
                                        fWeight: FontWeight.bold,
                                        tColor: Colors.black87,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const NotificationScreen());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.black87,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Hero Title & Chat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            TranslationKeys.empowerYourWorkflow.tr,
                            style: textStyleMontserratBold(
                              fontSize: 30.0,
                              color: const Color(0xff1A1A1A),
                              height: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                TranslationKeys.chat.tr,
                                style: textStyleMontserratBold(
                                  fontSize: 14.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 10),

              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 110),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ACTIVE TIMER WIDGET (Restored)
                      Obx(() {
                        final elapsedTime =
                            _attendanceController.elapsedTime.value;
                        final startTime =
                            _attendanceController.clockInTime.value;

                        if (startTime == null) return const SizedBox.shrink();

                        return GestureDetector(
                          onTap: () {
                            Get.to(() => const TimeClockStartedScreen());
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kPrimaryColor.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.timer,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          TranslationKeys.activeSession.tr,
                                          style: textStyleMontserratBold(
                                            fontSize: 12.0,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      elapsedTime,
                                      style: textStyleMontserratBold(
                                        fontSize: 28.0,
                                        color: kPrimaryColor,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        TranslationKeys.startedAt.tr,
                                        style: textStyleMontserratMiddle(
                                          fontSize: 10.0,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
                                        style: textStyleMontserratBold(
                                          fontSize: 14.0,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn().scale();
                      }),

                      const SizedBox(height: 10),

                      // Horizontal Modules (Time Tracking, Org Chart, etc)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TranslationKeys.quickActions.tr,
                              style: textStyleMontserratBold(
                                fontSize: 18.0,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const QuickActionsGridScreen());
                              },
                              child: Text(
                                TranslationKeys.viewAll.tr,
                                style: textStyleMontserratMiddle(
                                  fontSize: 14.0,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      SizedBox(
                        height: 145,
                        child: CustomAnimatedListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: 4,
                          separator: const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return _buildModuleCard(
                                  icon: Icons.timer_outlined,
                                  title: TranslationKeys.timeTracking.tr,
                                  onTap: () async {
                                    if (_attendanceController
                                            .elapsedTime
                                            .value !=
                                        "00:00:00") {
                                      Get.to(
                                        () => const TimeClockStartedScreen(),
                                      );
                                    } else {
                                      final result = await Get.to(
                                        () => const ClockInMapScreen(),
                                      );
                                      if (result != null) {
                                        Utils.snackBar(
                                          "Clocked in at: $result",
                                          false,
                                        );
                                      }
                                    }
                                  },
                                );
                              case 1:
                                return _buildModuleCard(
                                  icon: Icons.history,
                                  title: TranslationKeys.todayHistory.tr,
                                  onTap: () {
                                    final c =
                                        Get.find<AttendanceHistoryController>();
                                    if (c.todayLogsModel.value == null ||
                                        c.todayLogsModel.value!.logs.isEmpty) {
                                      c.getTodayLogs();
                                    }
                                    Get.to(() => TodayHistoryScreen());
                                  },
                                );
                              case 2:
                                return _buildModuleCard(
                                  icon: Icons.monetization_on_outlined,
                                  title: TranslationKeys.loansAndExpenses.tr,
                                  onTap: () {
                                    Get.to(() => LoanScreen());
                                  },
                                );
                              case 3:
                                return _buildModuleCard(
                                  icon: Icons.calendar_today_outlined,
                                  title: TranslationKeys.leaveSummary.tr,
                                  onTap: () {
                                    Get.to(() => const LeaveSummaryScreen());
                                  },
                                );
                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Announcements Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TranslationKeys.announcements.tr,
                              style: textStyleMontserratBold(
                                fontSize: 18.0,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const AnnouncementsListScreen());
                              },
                              child: Text(
                                TranslationKeys.viewAll.tr,
                                style: textStyleMontserratMiddle(
                                  fontSize: 14.0,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Dynamic Announcement List
                      Obx(() {
                        final announcements =
                            _announcementController.announcements;
                        final isLoading =
                            _announcementController.isLoading.value;

                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (announcements.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                _buildLargeAnnouncementCard(
                                  date: TranslationKeys.anytime.tr,
                                  time: "",
                                  title:
                                      TranslationKeys
                                          .noAnnouncementsAvailable
                                          .tr,
                                  subtitle:
                                      TranslationKeys.youAreAllCaughtUp.tr,
                                  isSecondary: true,
                                  onTap: () {},
                                ).animate().fadeIn(),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...announcements
                                  .map((announcement) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: _buildLargeAnnouncementCard(
                                        date:
                                            announcement.publishAt != null
                                                ? DateFormat('dd MMMM').format(
                                                  DateTime.parse(
                                                    announcement.publishAt!,
                                                  ),
                                                )
                                                : TranslationKeys.today.tr,
                                        time:
                                            announcement.publishAt != null
                                                ? DateFormat('HH:mm a').format(
                                                  DateTime.parse(
                                                    announcement.publishAt!,
                                                  ),
                                                )
                                                : "",
                                        title:
                                            announcement.title ??
                                            TranslationKeys.announcement.tr,
                                        subtitle:
                                            announcement.message ??
                                            TranslationKeys.tapToViewDetails.tr,
                                        onTap: () {
                                          showAnnouncementDetail(
                                            context,
                                            announcement.title ?? "",
                                            announcement.message ?? "",
                                          );
                                        },
                                        isSecondary:
                                            announcements.indexOf(
                                                  announcement,
                                                ) %
                                                2 !=
                                            0, // Alternate styles
                                      ),
                                    );
                                  })
                                  .toList()
                                  .animate(interval: 200.ms)
                                  .fadeIn()
                                  .slideX(
                                    begin: 0.1,
                                    end: 0,
                                    curve: Curves.easeOutQuart,
                                  ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, // Off-white/greyish
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(icon, color: Colors.black87, size: 22),
            ),
            Text(
              title,
              style: textStyleMontserratBold(
                fontSize: 16.0,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeAnnouncementCard({
    required String date,
    required String time,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    // Random gradients/colors based on secondary flag for visual variety
    final bgGradient =
        isSecondary
            ? const LinearGradient(
              colors: [Color(0xffE8F0F2), Color(0xffE8F0F2)],
            )
            : const LinearGradient(
              colors: [Color(0xffE3EEFF), Color(0xffF0F6FF)], // Bluish
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: textStyleMontserratMiddle(
                              fontSize: 10.0,
                              color: Colors.black54,
                            ),
                          ),
                          if (time.isNotEmpty)
                            Text(
                              time,
                              style: textStyleMontserratBold(
                                fontSize: 10.0,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.black45),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: textStyleMontserratBold(
                fontSize: 20.0,
                color: Colors.black87,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: textStyleMontserratMiddle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xff2A2A2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAnnouncementDetail(BuildContext context, String title, String body) {
    AnnouncementBottomSheet.show(context: context, title: title, body: body);
  }

  Widget _gridActionTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (Get.width - 40) / 2, // Adjusted for padding calculations
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ), // Added border for visibility
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Increased opacity
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kPrimaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: kText(
                text: label,
                fSize: 12.0,
                fWeight: FontWeight.w600,
                tColor: Colors.black87,
                textalign: TextAlign.start,
                maxLines: 2,
                textoverflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
