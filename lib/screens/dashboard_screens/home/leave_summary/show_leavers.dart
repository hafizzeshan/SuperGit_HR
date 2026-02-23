import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
import 'package:supergithr/views/custom_animated_views.dart';
import 'package:supergithr/screens/dashboard_screens/setting/doc/document_viewer.dart';

class LeaveSummaryScreen extends StatefulWidget {
  final bool showBackButton;
  const LeaveSummaryScreen({super.key, this.showBackButton = true});

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
      print(
        '📊 Leave Summary - Leave Types count: ${controller.leaveTypes.length}',
      );
      print(
        '📊 Leave Summary - Leave History count: ${controller.leaveHistory.length}',
      );

      if (controller.leaveTypes.isEmpty) {
        print('🔄 Fetching leave types (list is empty)');
        controller.fetchLeaveTypes();
      } else {
        print(
          '✅ Using cached leave types (${controller.leaveTypes.length} items)',
        );
      }

      if (controller.leaveHistory.isEmpty) {
        print('🔄 Fetching leave history (list is empty)');
        controller.getEmployeeLeaveHistory();
      } else {
        print(
          '✅ Using cached leave history (${controller.leaveHistory.length} items)',
        );
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
    if (LocalizationHelper.isArabic) {
      return match?.nameAr ?? match?.nameEn ?? TranslationKeys.leaveType.tr;
    }
    return match?.nameEn ?? TranslationKeys.leaveType.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitAction(
        title: TranslationKeys.leaveSummary.tr,
        leadingWidget: widget.showBackButton ? null : const SizedBox(),
        titlefontSize: 18.0,
        actionwidget: IconButton(
          onPressed: () {
            Get.to(() => const NewLeaveRequestScreen());
          },
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: kPrimaryColor, size: 22),
          ),
        ),
      ),

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          if (controller.isHistoryLoading.value &&
              controller.leaveHistory.isEmpty) {
            return _buildShimmerList();
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
              padding: const EdgeInsets.only(bottom: 50), // Extra space for better scroll experience
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: controller.leaveHistory.length +
                  (controller.hasMoreHistory.value ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                // Optimistic trigger: start loading when we are near the end
                if (index >= controller.leaveHistory.length - 1 && 
                    controller.hasMoreHistory.value && 
                    !controller.isLoadingMoreHistory.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    print("📊 LEAVE SUMMARY => Near end (Index $index), triggering pagination");
                    controller.loadMoreLeaveHistory();
                  });
                }

                // Show loader at the very bottom
                if (index == controller.leaveHistory.length) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: kPrimaryColor,
                          strokeWidth: 2,
                        ),
                        UIHelper.verticalSpaceSm5,
                        kText(
                          text: "Loading more history...",
                          fSize: 11.0,
                          tColor: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }

                final leave = controller.leaveHistory[index];

                return _glassCard(
                  date: formatDate(leave.startDate),
                  type: getLeaveTypeName(leave.leaveTypeId, types),
                  status: LocalizationHelper.getLeaveStatus(
                    leave.status ?? "-",
                  ),
                  rawStatus: leave.status ?? "-",
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
    required String rawStatus,
    required LeaveRequestModel model,
  }) {
    Color statusColor =
        rawStatus.toLowerCase() == "approved"
            ? Colors.green
            : rawStatus.toLowerCase() == "pending"
            ? Colors.orange
            : Colors.red;

    final days = model.totalDays?.toString() ?? "0";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            () => _showLeaveDetailsBottomSheet(
              context,
              model,
              status,
              statusColor,
            ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ ROW 1: Days + title ------------------
              Row(
                children: [
                  // DAYS DISPLAY (Leading)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        kText(
                          text: days,
                          fSize: 18,
                          fWeight: FontWeight.bold,
                          tColor: statusColor,
                          height: 1.0,
                        ),
                        kText(
                          text: TranslationKeys.days.tr,
                          fSize: 9,
                          fWeight: FontWeight.w600,
                          tColor: statusColor,
                        ),
                      ],
                    ),
                  ),

                  UIHelper.horizontalSpaceSm15,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kText(
                          text: type,
                          fSize: 16.0,
                          fWeight: FontWeight.bold,
                          tColor: Colors.black87,
                        ),
                        UIHelper.verticalSpaceSm5,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: kText(
                            text: status,
                            fSize: 10.0,
                            fWeight: FontWeight.w600,
                            tColor: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 12),

              // ------------------ ROW 2: Dates Only ------------------
              Row(
                children: [
                  Expanded(
                    child: _dateColumn(
                      TranslationKeys.from.tr,
                      formatDate(model.startDate),
                    ),
                  ),
                  Container(width: 1, height: 20, color: Colors.grey.shade200),
                  Expanded(
                    child: _dateColumn(
                      TranslationKeys.to.tr,
                      formatDate(model.endDate),
                      alignRight: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateColumn(String label, String date, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        kText(text: label, fSize: 11.0, tColor: Colors.grey.shade500),
        const SizedBox(height: 4),
        kText(
          text: date,
          fSize: 13.0,
          fWeight: FontWeight.w600,
          tColor: Colors.black87,
        ),
      ],
    );
  }

  void _showLeaveDetailsBottomSheet(
    BuildContext context,
    LeaveRequestModel model,
    String status,
    Color statusColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: kMainBackgroundGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Centered Header Status ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getLeaveIcon(model.leaveTypeId),
                    color: statusColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                kText(
                  text: status,
                  fSize: 22,
                  fWeight: FontWeight.bold,
                  tColor: statusColor,
                ),
                const SizedBox(height: 8),
                kText(
                  text: getLeaveTypeName(
                    model.leaveTypeId,
                    controller.leaveTypes,
                  ),
                  fSize: 15,
                  tColor: Colors.grey.shade600,
                ),

                const SizedBox(height: 30),

                // --- Timeline Visual ---
                // --- Timeline Visual (Vertical) ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      // Start Date
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: kPrimaryColor,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 30,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                kText(
                                  text: TranslationKeys.startDate.tr,
                                  fSize: 12,
                                  tColor: Colors.grey.shade500,
                                ),
                                kText(
                                  text: formatDate(model.startDate),
                                  fSize: 16,
                                  fWeight: FontWeight.bold,
                                  tColor: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Duration (Middle)
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 2,
                                height: 30,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: kText(
                              text:
                                  "${model.totalDays} ${TranslationKeys.days.tr} ${TranslationKeys.duration.tr}",
                              fSize: 12,
                              fWeight: FontWeight.w600,
                              tColor: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),

                      // End Date
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                kText(
                                  text: TranslationKeys.endDate.tr,
                                  fSize: 12,
                                  tColor: Colors.grey.shade500,
                                ),
                                kText(
                                  text: formatDate(model.endDate),
                                  fSize: 16,
                                  fWeight: FontWeight.bold,
                                  tColor: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (model.reason != null && model.reason!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: kText(
                      text: TranslationKeys.reason.tr,
                      fSize: 14,
                      fWeight: FontWeight.w600,
                      tColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: kText(
                      text: model.reason!,
                      fSize: 14,
                      tColor: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],

                if (model.documentUrl != null &&
                    model.documentUrl!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: kText(
                      text: TranslationKeys.document.tr,
                      fSize: 14,
                      fWeight: FontWeight.w600,
                      tColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => DocumentViewerScreen(
                            filePath: model.documentUrl,
                            status: model.status,
                            leave: model,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  kText(
                                    text: TranslationKeys.viewDocument.tr,
                                    fSize: 14,
                                    fWeight: FontWeight.w600,
                                    tColor: Colors.black87,
                                  ),
                                  kText(
                                    text: model.documentUrl!.split('/').last,
                                    fSize: 11,
                                    tColor: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getLeaveIcon(String? typeId) {
    // Simple helper since we don't have the full name here easily without lookup
    // Or just return a generic valid icon if lazy, but let's try to match logic
    return Icons.event_note_rounded;
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        kText(text: label, fSize: 14, tColor: Colors.grey.shade600),
        kText(
          text: value,
          fSize: 14,
          fWeight: FontWeight.bold,
          tColor: Colors.black87,
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Days Display Shimmer
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade100,
                    highlightColor: Colors.white,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  UIHelper.horizontalSpaceSm15,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        UIHelper.verticalSpaceSm5,
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpaceSm20,
              Row(
                children: [
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
}
