import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/models/leave_type_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

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
    leaveController.clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(title: TranslationKeys.newLeaveRequest.tr),
      backgroundColor: kMainBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: Obx(() {
          if (leaveController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Leave Type Selector
              GestureDetector(
                onTap: _showLeaveTypeBottomSheet,
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
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.category_rounded,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kText(
                              text: TranslationKeys.leaveType.tr,
                              fSize: 12.0,
                              tColor: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 4),
                            kText(
                              text:
                                  leaveController.selectedLeaveTypeId.value !=
                                          null
                                      ? leaveController.leaveTypes
                                          .firstWhere(
                                            (type) =>
                                                type.id ==
                                                leaveController
                                                    .selectedLeaveTypeId
                                                    .value,
                                            orElse:
                                                () => LeaveTypeModel(
                                                  nameEn: "Unknown",
                                                ),
                                          )
                                          .nameEn!
                                      : TranslationKeys.selectLeaveType.tr,
                              fSize: 15.0,
                              fWeight: FontWeight.bold,
                              tColor: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Date Selection Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(context, true),
                      child: _dateField(
                        title: TranslationKeys.startDate.tr,
                        value: leaveController.startDateController.text,
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(context, false),
                      child: _dateField(
                        title: TranslationKeys.endDate.tr,
                        value: leaveController.endDateController.text,
                        icon: Icons.event_rounded,
                      ),
                    ),
                  ),
                ],
              ),

              // Total Days Card
              if (leaveController.totalDaysController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColor.withOpacity(0.1),
                          kPrimaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              color: kPrimaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            kText(
                              text: TranslationKeys.totalDays.tr,
                              fSize: 14.0,
                              fWeight: FontWeight.w600,
                              tColor: kPrimaryColor.withOpacity(0.8),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: kText(
                            text:
                                "${leaveController.totalDaysController.text} Days",
                            fSize: 14.0,
                            tColor: kPrimaryColor,
                            fWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Reason Input
              kText(
                text: TranslationKeys.reason.tr,
                fSize: 14.0,
                fWeight: FontWeight.bold,
                tColor: Colors.black87,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: leaveController.reasonController,
                textDirection: (Get.locale?.languageCode == 'ur' || Get.locale?.languageCode == 'ar') ? TextDirection.rtl : TextDirection.ltr,
                onTapOutside: (event) async {
                  FocusScope.of(context).unfocus();
                },
                maxLines: 5,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: TranslationKeys.addReasonForLeave.tr,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: kPrimaryColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Attach Document
              kText(
                text: TranslationKeys.attachDocumentOptional.tr,
                fSize: 14.0,
                fWeight: FontWeight.bold,
                tColor: Colors.black87,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: leaveController.pickDocument,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          leaveController.attachedFile.value != null
                              ? kPrimaryColor
                              : Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (leaveController.attachedFile.value != null
                                  ? kPrimaryColor
                                  : Colors.grey)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          leaveController.attachedFile.value != null
                              ? Icons.description
                              : Icons.attach_file,
                          color:
                              leaveController.attachedFile.value != null
                                  ? kPrimaryColor
                                  : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kText(
                              text:
                                  leaveController.attachedFile.value != null
                                      ? TranslationKeys.selectedDocument.tr
                                      : TranslationKeys.uploadDocument.tr,
                              fSize: 12.0,
                              tColor: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 4),
                            kText(
                              text:
                                  leaveController.attachedFile.value?.name ??
                                  TranslationKeys.noFileSelected.tr,
                              fSize: 14.0,
                              fWeight: FontWeight.w600,
                              tColor: Colors.black87,
                              maxLines: 1,
                              textoverflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (leaveController.attachedFile.value != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: leaveController.clearAttachedFile,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(
          () => LoadingButton(
            isLoading: leaveController.isSubmitting.value,
            text: TranslationKeys.submitRequest.tr,
            onTap: () {
              print("Submit button tapped");
              leaveController.submitLeaveRequest();
            },
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(text: title, fSize: 12.0, tColor: Colors.grey.shade500),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 20, color: kPrimaryColor),
              UIHelper.horizontalSpaceSm10,
              kText(
                text: value.isNotEmpty ? value : TranslationKeys.selectDate.tr,
                fSize: 14.0,
                fWeight: FontWeight.w600,
                tColor:
                    value.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime initialDate = today;
    DateTime firstDate = DateTime(2000); // ✅ Allow past dates
    DateTime lastDate = DateTime(2100);

    // If picking Start Date, update initialDate to currently selected start date if any
    if (isStart && leaveController.startDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(leaveController.startDateController.text);
      } catch (_) {}
    }

    // If picking End Date, restrict to be >= Start Date
    if (!isStart && leaveController.startDateController.text.isNotEmpty) {
      try {
        final start = DateTime.parse(leaveController.startDateController.text);

        // The earliest end date allowed is the start date
        firstDate = start;

        // If end date is already selected, use it as initial. Otherwise use start date.
        if (leaveController.endDateController.text.isNotEmpty) {
          final end = DateTime.parse(leaveController.endDateController.text);
          initialDate = end;
        } else {
          initialDate = start;
        }
      } catch (_) {
        // Fallback to defaults if parsing fails
      }
    }

    // Ensure initialDate is within valid range
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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
          Utils.snackBar(
            TranslationKeys.endDateCannotBeBeforeStartDate.tr,
            true,
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
                  gradient: kMainBackgroundGradient,
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
                                  text: TranslationKeys.chooseLeaveType.tr,
                                  fSize: 16.0,
                                  fWeight: FontWeight.bold,
                                  tColor: Colors.black87,
                                ),
                                const SizedBox(height: 4),
                                Obx(() {
                                  return kText(
                                    text:
                                        "${leaveController.leaveTypes.length} ${TranslationKeys.typesAvailable.tr}",
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
                isSelected
                    ? kPrimaryColor.withOpacity(0.5)
                    : Colors.grey.shade200,
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
                                      text: TranslationKeys.paid.tr,
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
                                text:
                                    "${type.annualDays} ${TranslationKeys.daysPerYear.tr}",
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
                          colors: [
                            kPrimaryColor.withOpacity(0.8),
                            kPrimaryColor,
                          ],
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
