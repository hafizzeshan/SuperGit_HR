import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/holiday_controller.dart';
import 'package:supergithr/models/holiday_model.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/shimmer/holiday_shimmer.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  final HolidayController holidayController = Get.find<HolidayController>();

  @override
  void initState() {
    super.initState();
    // Fetch holidays on first load if list is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (holidayController.holidays.isEmpty) {
        holidayController.fetchHolidays();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: appBarrWitoutAction(title: TranslationKeys.holidays.tr),
      body: Obx(() {
        // Show shimmer only on first load
        if (holidayController.isLoading.value &&
            holidayController.holidays.isEmpty) {
          return const HolidayShimmer();
        }

        if (holidayController.holidays.isEmpty &&
            !holidayController.isLoading.value) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => holidayController.fetchHolidays(),
          color: kPrimaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: holidayController.holidays.length,
            itemBuilder: (context, index) {
              final holiday = holidayController.holidays[index];
              return _buildHolidayCard(holiday, index);
            },
          ),
        );
      }),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          kText(
            text: TranslationKeys.noHolidaysFound.tr,
            fSize: 18.0,
            fWeight: FontWeight.w600,
            tColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          kText(
            text: TranslationKeys.pullDownToRefresh.tr,
            fSize: 14.0,
            tColor: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  /// Modern Holiday Card with improved design
  Widget _buildHolidayCard(HolidaDatum holiday, int index) {
    final date = holiday.date;
    final dayName = date != null ? DateFormat('EEEE').format(date) : '';
    final dayNumber = date != null ? DateFormat('dd').format(date) : '';
    final monthName = date != null ? DateFormat('MMM').format(date) : '';
    final year = date != null ? DateFormat('yyyy').format(date) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: linearGradient2, // Use blue gradient instead of multiple colors
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date Circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    kText(
                      text: dayNumber,
                      fSize: 20.0,
                      fWeight: FontWeight.bold,
                      tColor: Colors.white,
                    ),
                    kText(
                      text: monthName.toUpperCase(),
                      fSize: 9.0,
                      fWeight: FontWeight.w600,
                      tColor: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Holiday Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kText(
                      text: holiday.nameEn ?? TranslationKeys.holiday.tr,
                      fSize: 16.0,
                      fWeight: FontWeight.bold,
                      tColor: Colors.white,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 5),
                        kText(
                          text: "$dayName, $year",
                          fSize: 12.0,
                          tColor: Colors.white.withOpacity(0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Recurring Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            holiday.isRecurring == true
                                ? Icons.repeat_rounded
                                : Icons.event_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          kText(
                            text: holiday.isRecurring == true
                                ? TranslationKeys.recurring.tr
                                : TranslationKeys.oneTime.tr,
                            fSize: 11.0,
                            fWeight: FontWeight.w600,
                            tColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
