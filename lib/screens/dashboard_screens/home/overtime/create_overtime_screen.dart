import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supergithr/controllers/overtime_controller.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class CreateOvertimeScreen extends StatefulWidget {
  const CreateOvertimeScreen({super.key});

  @override
  State<CreateOvertimeScreen> createState() => _CreateOvertimeScreenState();
}

class _CreateOvertimeScreenState extends State<CreateOvertimeScreen> {
  final OvertimeController _c = Get.find<OvertimeController>();

  /// Quick-pick durations in minutes.
  static const List<int> _presets = [30, 60, 90, 120, 180, 240];

  @override
  void initState() {
    super.initState();
    // Start from a clean form and default the date to today.
    _c.clearForm();
    _c.selectedDate.value = DateTime.now();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _c.selectedDate.value ?? now,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) _c.selectedDate.value = picked;
  }

  void _applyPreset(int totalMinutes) {
    _c.hours.value = totalMinutes ~/ 60;
    _c.minutes.value = totalMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: appBarrWitoutAction(title: TranslationKeys.newOvertimeRequest.tr),
      body: Container(
        decoration: const BoxDecoration(gradient: kMainBackgroundGradient),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _durationPreview(),
              const SizedBox(height: 24),

              _label(TranslationKeys.date.tr),
              const SizedBox(height: 8),
              _dateField(),
              const SizedBox(height: 22),

              _label(TranslationKeys.selectOvertimeDuration.tr),
              const SizedBox(height: 8),
              _durationBox(),
              const SizedBox(height: 22),

              _label(TranslationKeys.reasonForOvertime.tr),
              const SizedBox(height: 8),
              _reasonField(),
              const SizedBox(height: 34),

              Obx(
                () => LoadingButton(
                  isLoading: _c.isSubmitting.value,
                  text: TranslationKeys.submitRequest.tr,
                  onTap: _c.createOvertimeRequest,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Gradient hero showing the live duration selection.
  Widget _durationPreview() {
    return Obx(() {
      final h = _c.hours.value;
      final m = _c.minutes.value;
      final decimal = (_c.durationMinutes / 60.0).toStringAsFixed(2);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              TranslationKeys.duration.tr,
              style: textStyleMontserratMiddle(
                fontSize: 12.0,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$h",
                  style: textStyleMontserratBold(
                    fontSize: 34.0,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    " ${TranslationKeys.hours.tr}  ",
                    style: textStyleMontserratMiddle(
                      fontSize: 13.0,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                Text(
                  "$m",
                  style: textStyleMontserratBold(
                    fontSize: 34.0,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    " ${TranslationKeys.minutes.tr}",
                    style: textStyleMontserratMiddle(
                      fontSize: 13.0,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_c.durationMinutes} ${TranslationKeys.minutes.tr}  ·  $decimal ${TranslationKeys.hours.tr}",
                style: textStyleMontserratMiddle(
                  fontSize: 11.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: kPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final date = _c.selectedDate.value;
                return Text(
                  date == null
                      ? TranslationKeys.selectDate.tr
                      : DateFormat('EEE, dd MMM yyyy').format(date),
                  style: textStyleMontserratMiddle(
                    fontSize: 14.0,
                    color: date == null ? Colors.grey.shade400 : Colors.black87,
                  ),
                );
              }),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _durationBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _fieldDecoration(),
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _stepper(
                    label: TranslationKeys.hours.tr,
                    value: _c.hours.value,
                    onMinus: () {
                      if (_c.hours.value > 0) _c.hours.value--;
                    },
                    onPlus: () {
                      if (_c.hours.value < 23) _c.hours.value++;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _stepper(
                    label: TranslationKeys.minutes.tr,
                    value: _c.minutes.value,
                    // Minutes move in 5-minute steps and roll into hours.
                    onMinus: () {
                      if (_c.minutes.value >= 5) {
                        _c.minutes.value -= 5;
                      } else if (_c.hours.value > 0) {
                        _c.hours.value--;
                        _c.minutes.value = 55;
                      }
                    },
                    onPlus: () {
                      if (_c.minutes.value >= 55) {
                        _c.minutes.value = 0;
                        if (_c.hours.value < 23) _c.hours.value++;
                      } else {
                        _c.minutes.value += 5;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map(_presetChip).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final label = h > 0 && m > 0
        ? "${h}h ${m}m"
        : h > 0
            ? "${h}h"
            : "${m}m";
    return Obx(() {
      final selected = _c.durationMinutes == totalMinutes;
      return GestureDetector(
        onTap: () => _applyPreset(totalMinutes),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? kPrimaryColor
                : kPrimaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? kPrimaryColor
                  : kPrimaryColor.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            style: textStyleMontserratBold(
              fontSize: 12.0,
              color: selected ? Colors.white : kPrimaryColor,
            ),
          ),
        ),
      );
    });
  }

  Widget _stepper({
    required String label,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyleMontserratMiddle(
            fontSize: 11.0,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: kMainBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepperButton(Icons.remove_rounded, onMinus),
              Text(
                "$value",
                style: textStyleMontserratBold(
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
              _stepperButton(Icons.add_rounded, onPlus),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 18, color: kPrimaryColor),
      ),
    );
  }

  Widget _reasonField() {
    return Container(
      decoration: _fieldDecoration(),
      child: TextFormField(
        controller: _c.reasonController,
        maxLines: 4,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: TranslationKeys.reasonForOvertime.tr,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _label(String text) {
    return Text(
      text,
      style: textStyleMontserratSemiBold(
        fontSize: 14.0,
        color: Colors.grey.shade700,
      ),
    );
  }
}
