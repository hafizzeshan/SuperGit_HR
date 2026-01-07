import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/screens/dashboard_screens/requests/new_request_screen.dart';

import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/models/leave_request_model.dart';
import 'package:supergithr/models/leave_type_model.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/utils/localization_helper.dart';

class LeaveSummaryScreen extends StatefulWidget {
  const LeaveSummaryScreen({super.key});

  @override
  State<LeaveSummaryScreen> createState() => _LeaveSummaryScreenState();
}

class _LeaveSummaryScreenState extends State<LeaveSummaryScreen> {
  late final LeaveController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LeaveController>();
    
    // Fetch data only if lists are empty (first time)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📊 Leave Summary - Leave Types count: ${controller.leaveTypes.length}');
      print('📊 Leave Summary - Leave History count: ${controller.leaveHistory.length}');
      
      if (controller.leaveTypes.isEmpty) {
        print('🔄 Fetching leave types (list is empty)');
        controller.fetchLeaveTypes();
      } else {
        print('✅ Using cached leave types (${controller.leaveTypes.length} items)');
      }
      
      if (controller.leaveHistory.isEmpty) {
        print('🔄 Fetching leave history (list is empty)');
        controller.getEmployeeLeaveHistory();
      } else {
        print('✅ Using cached leave history (${controller.leaveHistory.length} items)');
      }
    });
  }

  /// Date formatter
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    return DateFormat("MMM dd, yyyy").format(DateTime.parse(date));
  }

  /// Convert ID → name
  String getLeaveTypeName(String? id, List<LeaveTypeModel> types) {
    final match = types.firstWhereOrNull((t) => t.id.toString() == id);
    return match?.nameEn ?? TranslationKeys.leaveType.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => NewLeaveRequestScreen());
        },
        backgroundColor: kPrimaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      appBar: appBarrWitAction(title: TranslationKeys.leaveSummary.tr, titlefontSize: 18.0),

      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Obx(() {
          if (controller.isHistoryLoading.value && controller.leaveHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (controller.leaveHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  kText(
                    text: TranslationKeys.noLeaveHistoryFound.tr,
                    fSize: 15.0,
                    tColor: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  kText(
                    text: TranslationKeys.pullDownToRefresh.tr,
                    fSize: 12.0,
                    tColor: Colors.grey.shade400,
                  ),
                ],
              ),
            );
          }

          final types = controller.leaveTypes;

          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshLeaveHistory();
              if (controller.leaveTypes.isEmpty) {
                await controller.fetchLeaveTypes();
              }
            },
            color: kPrimaryColor,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: controller.leaveHistory.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final leave = controller.leaveHistory[index];

                return _glassCard(
                  date: formatDate(leave.startDate),
                  type: getLeaveTypeName(leave.leaveTypeId, types),
                  status: LocalizationHelper.getLeaveStatus(leave.status ?? "-"),
                  model: leave,
                );
              },
            ),
          );
        }),
      ),
    );
  }

  // -------------------------------------------------------------------
  //                 GLASSMORPHIC ULTRA-MODERN CARD
  // -------------------------------------------------------------------
  Widget _glassCard({
    required String date,
    required String type,
    required String status,
    required LeaveRequestModel model,
  }) {
    IconData icon;

    if (type.toLowerCase().contains("sick")) {
      icon = Icons.sick_rounded;
    } else if (type.toLowerCase().contains("annual")) {
      icon = Icons.sunny;
    } else if (type.toLowerCase().contains("unpaid")) {
      icon = Icons.money_off_rounded;
    } else {
      icon = Icons.event_note_rounded;
    }

    Color statusColor =
        status == "Approved"
            ? Colors.green
            : status == "Pending"
            ? Colors.orange
            : Colors.red;

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ ROW 1: Icon + title + status ------------------
            Row(
              children: [
                // ICON
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: whiteColor, size: 28),
                ),

                UIHelper.horizontalSpaceSm15,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kText(
                        text: type,
                        fSize: 16.0,
                        fWeight: FontWeight.w700,
                        tColor: whiteColor,
                      ),
                      UIHelper.verticalSpaceSm5,
                      kText(
                        text: date,
                        fSize: 12.0,
                        tColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),

                // STATUS CHIP
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,

                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: kText(
                    text: status,
                    fSize: 12.0,
                    tColor: whiteColor,
                    fWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            UIHelper.verticalSpaceSm20,

            // ------------------ ROW 2: information chips ------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _infoChip(TranslationKeys.totalDays.tr, model.totalDays?.toString() ?? "-"),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _infoChip(TranslationKeys.from.tr, formatDate(model.startDate)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _infoChip(TranslationKeys.to.tr, formatDate(model.endDate)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(text: title, fSize: 11.0, tColor: Colors.grey.shade500),
          const SizedBox(height: 4),
          kText(
            text: value,
            fSize: 13.0,
            fWeight: FontWeight.bold,
            tColor: Colors.black87,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
