import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/models/leave_request_model.dart';
import 'package:supergithr/screens/dashboard_screens/requests/new_request_screen.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final LeaveController leaveController = Get.find<LeaveController>();

  @override
  void initState() {
    super.initState();
    // Fetch leave history on first load if list is empty
    // After that, data persists and only refreshes via pull-to-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (leaveController.leaveHistory.isEmpty) {
        leaveController.getEmployeeLeaveHistory();
      }
    });
  }

  /// Format date to readable format
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat("MMM dd, yyyy").format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  /// Get status color
  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get leave type name from ID
  String getLeaveTypeName(String? leaveTypeId) {
    if (leaveTypeId == null) return "Leave";
    final leaveType = leaveController.leaveTypes.firstWhereOrNull(
      (type) => type.id == leaveTypeId,
    );
    return leaveType?.nameEn ?? TranslationKeys.leave.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(
        title: TranslationKeys.requests.tr,
        leadingWidget: const SizedBox(),
        titlefontSize: 18.0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kText(
              text: TranslationKeys.requestsHistory.tr,
              fSize: 16.0,
              fWeight: FontWeight.bold,
            ),
            UIHelper.verticalSpaceSm20,

            // Leave Requests List
            Expanded(
              child: Obx(() {
                // Show empty state if no data and not loading
                if (leaveController.leaveHistory.isEmpty &&
                    !leaveController.isHistoryLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        UIHelper.verticalSpaceSm10,
                        kText(
                          text: TranslationKeys.noLeaveRequestsFound.tr,
                          fSize: 14.0,
                          tColor: Colors.grey,
                        ),
                        UIHelper.verticalSpaceSm5,
                        kText(
                          text: TranslationKeys.clickBelowToMakeRequest.tr,
                          fSize: 12.0,
                          tColor: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await leaveController.refreshLeaveHistory();
                  },
                  color: kPrimaryColor,
                  child: Obx(() {
                    // Show shimmer when loading (initial or refresh)
                    if (leaveController.isHistoryLoading.value) {
                      return _buildShimmerList();
                    }

                    // Show actual data
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: leaveController.leaveHistory.length +
                          (leaveController.hasMoreHistory.value ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // Loading indicator at bottom
                        if (index == leaveController.leaveHistory.length) {
                          // Trigger load more
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            leaveController.loadMoreLeaveHistory();
                          });

                          return Obx(() {
                            if (leaveController.isLoadingMoreHistory.value) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: kPrimaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          });
                        }

                        final leave = leaveController.leaveHistory[index];
                        return _buildLeaveCard(leave);
                      },
                    );
                  }),
                );
              }),
            ),
          ],
        ),
      ),

      // Request Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: LoadingButton(
          isLoading: false,
          text: TranslationKeys.makeARequest.tr,
          onTap: () {
            Get.to(
              () => const NewLeaveRequestScreen(),
              transition: Transition.rightToLeft,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequestModel leave) {
    final statusColor = getStatusColor(leave.status);
    final leaveTypeName = getLeaveTypeName(leave.leaveTypeId);

    return GestureDetector(
      onTap: () => _showLeaveDetailsBottomSheet(leave),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event_note, color: whiteColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kText(
                        text: leaveTypeName,
                        fWeight: FontWeight.bold,
                        fSize: 15.0,
                        tColor: whiteColor,
                      ),
                      const SizedBox(height: 4),
                      kText(
                        text:
                            "${formatDate(leave.startDate)} - ${formatDate(leave.endDate)}",
                        fSize: 12.0,
                        tColor: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: kText(
                    text: leave.status ?? TranslationKeys.unknown.tr,
                    fSize: 11.0,
                    tColor: whiteColor,
                    fWeight: fontWeightBold,
                  ),
                ),
              ],
            ),

            if (leave.totalDays != null || leave.reason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (leave.totalDays != null) ...[
                      Icon(Icons.calendar_today, size: 14, color: whiteColor),
                      const SizedBox(width: 6),
                      kText(
                        text:
                            "${leave.totalDays} ${leave.totalDays! > 1 ? TranslationKeys.days.tr : TranslationKeys.day.tr}",
                        fSize: 12.0,
                        tColor: whiteColor,
                        fWeight: FontWeight.w500,
                      ),
                    ],
                    if (leave.totalDays != null &&
                        leave.reason != null &&
                        leave.reason!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 1,
                        height: 14,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    if (leave.reason != null && leave.reason!.isNotEmpty)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.notes, size: 14, color: whiteColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: kText(
                                text: leave.reason!,
                                fSize: 12.0,
                                tColor: whiteColor,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show detailed leave information in bottom sheet
  void _showLeaveDetailsBottomSheet(LeaveRequestModel leave) {
    final statusColor = getStatusColor(leave.status);
    final leaveTypeName = getLeaveTypeName(leave.leaveTypeId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withOpacity(0.3),
                        kPrimaryColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: linearGradient2,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kText(
                              text: TranslationKeys.leaveDetails.tr,
                              fSize: 18.0,
                              fWeight: FontWeight.bold,
                              tColor: Colors.black87,
                            ),
                            const SizedBox(height: 4),
                            kText(
                              text: leaveTypeName,
                              fSize: 13.0,
                              tColor: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: kText(
                          text: leave.status ?? TranslationKeys.unknown.tr,
                          fSize: 12.0,
                          tColor: Colors.white,
                          fWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Range
                        _detailCard(
                          icon: Icons.calendar_today,
                          title: TranslationKeys.dateRange.tr,
                          content:
                              "${formatDate(leave.startDate)} - ${formatDate(leave.endDate)}",
                        ),

                        const SizedBox(height: 12),

                        // Total Days
                        if (leave.totalDays != null)
                          _detailCard(
                            icon: Icons.event_available,
                            title: TranslationKeys.totalDays.tr,
                            content:
                                "${leave.totalDays} ${leave.totalDays! > 1 ? TranslationKeys.days.tr : TranslationKeys.day.tr}",
                          ),

                        const SizedBox(height: 12),

                        // Reason
                        if (leave.reason != null && leave.reason!.isNotEmpty)
                          _detailCard(
                            icon: Icons.notes,
                            title: TranslationKeys.reason.tr,
                            content: leave.reason!,
                          ),

                        const SizedBox(height: 12),

                        // Approver
                        if (leave.approverId != null)
                          _detailCard(
                            icon: Icons.person_outline,
                            title: TranslationKeys.approverId.tr,
                            content: leave.approverId!,
                          ),

                        const SizedBox(height: 12),

                        // Approved At
                        if (leave.approvedAt != null)
                          _detailCard(
                            icon: Icons.check_circle_outline,
                            title: TranslationKeys.approvedAt.tr,
                            content: formatDate(leave.approvedAt),
                          ),

                        const SizedBox(height: 12),

                        // Created At
                        if (leave.createdAt != null)
                          _detailCard(
                            icon: Icons.access_time,
                            title: TranslationKeys.requestedOn.tr,
                            content: formatDate(leave.createdAt),
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: linearGradient2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kText(
                  text: title,
                  fSize: 11.0,
                  tColor: Colors.grey.shade600,
                  fWeight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                kText(
                  text: content,
                  fSize: 14.0,
                  tColor: Colors.black87,
                  fWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer loading list
  Widget _buildShimmerList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
