import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/models/leave_type_model.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/views/CustomButton.dart';

class NewLeaveRequestScreen extends StatefulWidget {
  const NewLeaveRequestScreen({super.key});

  @override
  State<NewLeaveRequestScreen> createState() => _NewLeaveRequestScreenState();
}

class _NewLeaveRequestScreenState extends State<NewLeaveRequestScreen> {
  final LeaveController leaveController = Get.find<LeaveController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(title: "New Leave Request"),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (leaveController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Leave Type
            UIHelper.verticalSpaceSm5,
            GestureDetector(
              onTap: _showLeaveTypeBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: linearGradient2,
                  border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kText(
                      text:
                          leaveController.selectedLeaveTypeId.value != null
                              ? leaveController.leaveTypes
                                  .firstWhere(
                                    (type) =>
                                        type.id ==
                                        leaveController
                                            .selectedLeaveTypeId
                                            .value,
                                  )
                                  .nameEn!
                              : "Select leave type",
                      fSize: 14.0,
                      tColor: whiteColor,
                    ),
                    const Icon(Icons.arrow_drop_down, color: whiteColor),
                  ],
                ),
              ),
            ),

            // Start + End Dates Row
            UIHelper.verticalSpaceSm20,
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(context, true),
                    child: _dateField(
                      title: "Start Date",
                      value: leaveController.startDateController.text,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(context, false),
                    child: _dateField(
                      title: "End Date",
                      value: leaveController.endDateController.text,
                    ),
                  ),
                ),
              ],
            ),

            // Total Days
            if (leaveController.totalDaysController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: linearGradient2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      kText(
                        text: "Total Days",
                        fSize: 14.0,
                        fWeight: FontWeight.w600,
                        tColor: whiteColor,
                      ),
                      kText(
                        text:
                            "${leaveController.totalDaysController.text} day${leaveController.totalDaysController.text == '1' ? '' : 's'}",
                        fSize: 14.0,
                        tColor: whiteColor,
                        fWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),

            // Reason
            UIHelper.verticalSpaceSm20,
            TextField(
              controller: leaveController.reasonController,

              onTapOutside: (event) async {
                FocusScope.of(context).unfocus();
              },
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Add reason for leave...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kPrimaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Obx(
          () => LoadingButton(
            isLoading: leaveController.isSubmitting.value,
            text: "Submit Request",
            onTap: () => leaveController.submitLeaveRequest(),
          ),
        ),
      ),
    );
  }

  Widget _dateField({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        gradient: linearGradient2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(text: title, fSize: 12.0, tColor: Colors.grey.shade200),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: whiteColor),
              UIHelper.horizontalSpaceSm10,
              kText(
                text: value.isNotEmpty ? value : "Select date",
                fSize: 13.5,
                tColor: whiteColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    DateTime initialDate = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate, // ✅ Only today and future dates
      lastDate: initialDate.add(
        const Duration(days: 365),
      ), // up to 1 year ahead
    );

    if (picked != null) {
      final formattedDate =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      // ✅ Update fields
      if (isStart) {
        leaveController.startDateController.text = formattedDate;
      } else {
        leaveController.endDateController.text = formattedDate;
      }

      // ✅ Recalculate total days and trigger UI update
      if (leaveController.startDateController.text.isNotEmpty &&
          leaveController.endDateController.text.isNotEmpty) {
        final start = DateTime.parse(leaveController.startDateController.text);
        final end = DateTime.parse(leaveController.endDateController.text);

        // Prevent negative day count (if user selects end < start)
        if (end.isBefore(start)) {
          Get.snackbar(
            "Invalid Date Range",
            "End date cannot be before start date",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.black,
          );
          leaveController.totalDaysController.clear();
          return;
        }

        final totalDays = end.difference(start).inDays + 1;
        leaveController.totalDaysController.text = totalDays.toString();
      }

      // ✅ Force refresh UI (important!)
      setState(() {});
    }
  }

  void _showLeaveTypeBottomSheet() {
    final scrollController = ScrollController();

    // Add scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        leaveController.loadMoreLeaveTypes();
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, scrollController2) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.blue.shade50.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle with animation
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
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

                    // Header Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: linearGradient2,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.event_available_rounded,
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
                                  text: "Choose Leave Type",
                                  fSize: 16.0,
                                  fWeight: FontWeight.bold,
                                  tColor: Colors.black87,
                                ),
                                const SizedBox(height: 4),
                                Obx(() {
                                  return kText(
                                    text:
                                        "${leaveController.leaveTypes.length} types available",
                                    fSize: 11.0,
                                    tColor: Colors.grey.shade600,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider with gradient
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            kPrimaryColor.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Scrollable list with beautiful cards
                    Expanded(
                      child: Obx(() {
                        final currentTypes = leaveController.leaveTypes;

                        if (currentTypes.isEmpty &&
                            leaveController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            await leaveController.refreshLeaveTypes();
                          },
                          color: kPrimaryColor,
                          child: ListView.builder(
                            controller: scrollController2,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount:
                                currentTypes.length +
                                (leaveController.hasMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Loading indicator at bottom
                              if (index == currentTypes.length) {
                                return Obx(() {
                                  if (leaveController.isLoadingMore.value) {
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

                              final type = currentTypes[index];
                              final isSelected =
                                  leaveController.selectedLeaveTypeId.value ==
                                  type.id;

                              return _buildLeaveTypeCard(
                                type: type,
                                isSelected: isSelected,
                                index: index,
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
    ).whenComplete(() {
      scrollController.dispose();
    });
  }

  // Beautiful leave type card
  Widget _buildLeaveTypeCard({
    required LeaveTypeModel type,
    required bool isSelected,
    required int index,
  }) {
    // Get icon based on leave type
    IconData getLeaveIcon() {
      final name = (type.nameEn ?? "").toLowerCase();
      if (name.contains("annual")) return Icons.beach_access_rounded;
      if (name.contains("sick")) return Icons.medical_services_rounded;
      if (name.contains("eid") ||
          name.contains("hajj") ||
          name.contains("fiter"))
        return Icons.celebration_rounded;
      if (name.contains("maternity")) return Icons.child_care_rounded;
      if (name.contains("paternity")) return Icons.family_restroom_rounded;
      if (name.contains("unpaid")) return Icons.money_off_rounded;
      if (name.contains("emergency")) return Icons.emergency_rounded;
      return Icons.event_note_rounded;
    }

    // Get color based on leave type
    Color getLeaveColor() {
      final name = (type.nameEn ?? "").toLowerCase();
      if (name.contains("annual")) return Colors.blue;
      if (name.contains("sick")) return Colors.red;
      if (name.contains("eid") ||
          name.contains("hajj") ||
          name.contains("fiter"))
        return Colors.purple;
      if (name.contains("maternity") || name.contains("paternity"))
        return Colors.pink;
      if (name.contains("unpaid")) return Colors.orange;
      if (name.contains("emergency")) return Colors.deepOrange;
      return kPrimaryColor;
    }

    final leaveColor = getLeaveColor();
    final leaveIcon = getLeaveIcon();

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [
                      leaveColor.withOpacity(0.1),
                      leaveColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? kPrimaryColor.withOpacity(0.5) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? kPrimaryColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              leaveController.selectedLeaveTypeId.value = type.id;
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [leaveColor.withOpacity(0.8), leaveColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: leaveColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(leaveIcon, color: Colors.white, size: 22),
                  ),

                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: kText(
                                text: type.nameEn ?? "-",
                                fSize: 13.0,
                                fWeight: FontWeight.w600,
                                tColor: Colors.black87,
                              ),
                            ),
                            if (type.isPaid == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade400,
                                      Colors.green.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    kText(
                                      text: "Paid",
                                      fSize: 10.0,
                                      tColor: Colors.white,
                                      fWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (type.nameAr != null) ...[
                          const SizedBox(height: 4),
                          kText(
                            text: type.nameAr!,
                            fSize: 11.0,
                            tColor: Colors.grey.shade600,
                          ),
                        ],
                        if (type.annualDays != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: leaveColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              kText(
                                text: "${type.annualDays} days/year",
                                fSize: 10.0,
                                tColor: Colors.grey.shade700,
                                fWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Selection indicator - only show when selected
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kPrimaryColor.withOpacity(0.8), kPrimaryColor],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
