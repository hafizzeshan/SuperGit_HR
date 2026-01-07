import 'package:flutter/material.dart';
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
  final AnnouncementController _announcementController = Get.put(
    AnnouncementController(),
  );

  @override
  Widget build(BuildContext context) {
    final user = _profileController.userModel.value;

    final firstName = user.firstNameEn ?? "User";
    final lastName = user.lastNameEn ?? "";

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: linearGradient3,
                  ),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    firstName.isNotEmpty
                        ? (firstName[0].toUpperCase() +
                            (lastName.isNotEmpty
                                ? lastName[0].toUpperCase()
                                : ''))
                        : 'U',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                UIHelper.horizontalSpaceSm10,
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      // Removed profile fetch - data already loaded from cache
                      LocationController locationController =
                          Get.find<LocationController>();
                      locationController.getCurrentLocation();
                      //   await Future.delayed(Duration(seconds: 1));
                    },
                    child: kText(
                      text:
                          "${LocalizationHelper.getTimeBasedGreeting()} \n$firstName $lastName 👋",
                      fSize: 14.0,
                      fWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Get.to(() => const NotificationScreen()),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none, size: 28),
                      ),
                      // Positioned(
                      //   right: 5,
                      //   top: 2,
                      //   child: Container(
                      //     padding: const EdgeInsets.all(4),
                      //     decoration: const BoxDecoration(
                      //       color: Colors.red,
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: const Text(
                      //       "9",
                      //       style: TextStyle(color: Colors.white, fontSize: 10),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            UIHelper.verticalSpaceSm20,

            // Quick Actions Grid
            Wrap(
              spacing: 10.0,
              runSpacing: 10,
              children: [
                _gridActionTile(
                  Icons.lock_clock,
                  TranslationKeys.timeClock.tr,
                  () async {
                    // Use the existing controller instance (not a new one)
                    if (_attendanceController.elapsedTime.value != "00:00:00") {
                      // already clocked in → go to started screen (replace current screen)
                      Get.to(() => const TimeClockStartedScreen());
                    } else {
                      // not clocked in → open map screen
                      final result = await Get.to(
                        () => const ClockInMapScreen(),
                      );
                      if (result != null) {
                        Utils.snackBar("Clocked in at: $result", false);
                      }
                    }
                  },
                ),
                _gridActionTile(
                  Icons.history,
                  TranslationKeys.todayHistory.tr,
                  () {
                    final c = Get.find<AttendanceHistoryController>();
                    if (c.todayLogsModel.value == null ||
                        c.todayLogsModel.value!.logs.isEmpty) {
                      c.getTodayLogs();
                    }
                    Get.to(() => TodayHistoryScreen());
                  },
                ),
                _gridActionTile(
                  Icons.payment,
                  TranslationKeys.salaryStructure.tr,
                  () {
                    Get.to(() => EmployeeSalaryStructureScreen());
                  },
                ),
                _gridActionTile(
                  Icons.event_available,
                  TranslationKeys.leaveSummary.tr,
                  () {
                    Get.to(() => const LeaveSummaryScreen());
                  },
                ),
                _gridActionTile(
                  Icons.history,
                  TranslationKeys.applyLoan.tr,
                  () {
                    Get.to(() => LoanScreen());
                  },
                ),
                _gridActionTile(Icons.history, TranslationKeys.holidays.tr, () {
                  Get.to(() => HolidayScreen());
                }),
              ],
            ),

            UIHelper.verticalSpaceSm20,

            // ✅ Attendance Summary (Dynamic)
            // ✅ Attendance Summary (Dynamic)
            Obx(() {
              final elapsedTime = _attendanceController.elapsedTime.value;
              final startTime = _attendanceController.clockInTime.value;

              if (startTime == null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_clock,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      UIHelper.horizontalSpaceSm10,
                      kText(
                        text: TranslationKeys.notClockedInYet.tr,
                        fSize: 14.0,
                        fWeight: FontWeight.w600,
                        tColor: Colors.grey.shade600,
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: linearGradient2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kText(
                          text: TranslationKeys.activeSession.tr,
                          fSize: 12.0,
                          fWeight: FontWeight.w500,
                          tColor: Colors.white.withOpacity(0.9),
                        ),
                        UIHelper.verticalSpaceSm5,
                        kText(
                          text: elapsedTime,
                          fSize: 24.0,
                          fWeight: FontWeight.bold,
                          tColor: Colors.white,
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 14,
                              ),
                              UIHelper.horizontalSpaceSm10,
                              kText(
                                text:
                                    "${TranslationKeys.startedAt.tr} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
                                fSize: 12.0,
                                tColor: Colors.white,
                                fWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            UIHelper.verticalSpaceSm20,

            // Announcements Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: linearGradient2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    UIHelper.horizontalSpaceSm10,
                    kText(
                      text: TranslationKeys.announcements.tr,
                      fSize: 18.0,
                      fWeight: FontWeight.bold,
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Get.to(() => const AnnouncementsListScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    child: Row(
                      children: [
                        kText(
                          text: TranslationKeys.viewAll.tr,
                          fSize: 12.0,
                          tColor: kPrimaryColor,
                          fWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpaceSm10,

            // Beautiful Announcement Card
            Obx(() {
              final lastAnnouncement = _announcementController.latestAnnouncement;
              if (lastAnnouncement == null) {
                return const SizedBox();
              }

              final title = lastAnnouncement.title ?? "";
              final message = lastAnnouncement.message ?? "";
              final publishDate = lastAnnouncement.publishAt != null
                  ? DateFormat('dd MMM, yyyy HH:mm').format(
                    DateTime.parse(lastAnnouncement.publishAt!),
                  )
                  : "";

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withOpacity(0.8),
                      kSecondaryColor.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                kText(
                                  text: TranslationKeys.new_.tr,
                                  fSize: 11.0,
                                  tColor: Colors.white,
                                  fWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpaceSm10,
                          // Title
                          kText(
                            text: title,
                            fSize: 18.0,
                            fWeight: FontWeight.bold,
                            tColor: Colors.white,
                            maxLines: 2,
                            textoverflow: TextOverflow.ellipsis,
                          ),
                          UIHelper.verticalSpaceSm5,
                          // Date & Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              kText(
                                text: publishDate,
                                fSize: 12.0,
                                tColor: Colors.white.withOpacity(0.8),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpaceSm10,
                          // Description
                          kText(
                            text: message,
                            fSize: 13.0,
                            tColor: Colors.white.withOpacity(0.95),
                            maxLines: 3,
                            textoverflow: TextOverflow.ellipsis,
                          ),
                          UIHelper.verticalSpaceSm10,
                          // Read More Button
                          InkWell(
                            onTap: () {
                              showAnnouncementDetail(context, title, message);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  kText(
                                    text: TranslationKeys.readMore.tr,
                                    fSize: 13.0,
                                    tColor: kPrimaryColor,
                                    fWeight: FontWeight.w600,
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: kPrimaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void showAnnouncementDetail(BuildContext context, String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Gradient Header
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor, kSecondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  kText(
                                    text: TranslationKeys.new_.tr,
                                    fSize: 10.0,
                                    tColor: Colors.white,
                                    fWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            kText(
                              text: title,
                              fSize: 18.0,
                              fWeight: FontWeight.bold,
                              tColor: Colors.white,
                              maxLines: 2,
                              textoverflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date & Time Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 20,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  kText(
                                    text: TranslationKeys.published.tr,
                                    fSize: 11.0,
                                    tColor: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 2),
                                  kText(
                                    text: TranslationKeys.todayAtTime.tr,
                                    fSize: 13.0,
                                    fWeight: FontWeight.w600,
                                    tColor: Colors.black87,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 14,
                                      color: kPrimaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    kText(
                                      text: TranslationKeys.important.tr,
                                      fSize: 11.0,
                                      tColor: kPrimaryColor,
                                      fWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Body Content
                        kText(
                          text: TranslationKeys.details.tr,
                          fSize: 16.0,
                          fWeight: FontWeight.bold,
                          tColor: Colors.black87,
                        ),
                        const SizedBox(height: 12),
                        kText(
                          text: body,
                          fSize: 14.0,
                          tColor: Colors.grey.shade700,
                          fWeight: FontWeight.w400,
                        ),

                        const SizedBox(height: 24),

                        // Additional Info Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kPrimaryColor.withOpacity(0.05),
                                kSecondaryColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: kPrimaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: kText(
                                  text: TranslationKeys.contactHrMessage.tr,
                                  fSize: 12.0,
                                  tColor: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          kText(
                            text: TranslationKeys.close.tr,
                            fSize: 16.0,
                            fWeight: FontWeight.w600,
                            tColor: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_outline, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _gridActionTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width / 2.3,
        height: 50,
        decoration: BoxDecoration(
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Icon(icon, color: whiteColor, size: 25)),
            Expanded(
              flex: 3,
              child: kText(
                text: label,
                fSize: 12.0,
                fWeight: FontWeight.w600,
                tColor: whiteColor,
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
