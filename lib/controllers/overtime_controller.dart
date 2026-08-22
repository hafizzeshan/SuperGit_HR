import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/overtime_model.dart';
import 'package:supergithr/network/repository/overtime_repo/overtime_repo.dart';
import 'package:supergithr/utils/utils.dart';

import '../translations/translations/translation_keys.dart';

class OvertimeController extends GetxController {
  final OvertimeRepository _repo = OvertimeRepository();

  /// Observables
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSubmitting = false.obs;
  final overtimes = <OvertimeDatum>[].obs;

  /// Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalRecords = 0.obs;
  static const int pageLimit = 20;

  /// Form state
  final reasonController = TextEditingController();
  final selectedDate = Rxn<DateTime>();
  final hours = 0.obs;
  final minutes = 0.obs;

  int get durationMinutes => (hours.value * 60) + minutes.value;

  /// Total approved + pending overtime hours currently loaded.
  double get totalHours =>
      overtimes.fold<double>(0, (sum, e) => sum + (e.durationMinutes / 60.0));

  int get pendingCount =>
      overtimes.where((e) => e.status.toLowerCase() == 'pending').length;

  int get approvedCount =>
      overtimes.where((e) => e.status.toLowerCase() == 'approved').length;

  bool get hasMore => currentPage.value < totalPages.value;

  Future<String> _employeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_id') ?? "";
  }

  /// ✅ Fetch employee overtime requests (page 1 unless `append`).
  Future<void> fetchOvertimes({int page = 1, bool append = false}) async {
    if (append) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    try {
      final employeeId = await _employeeId();
      if (employeeId.isEmpty) {
        log("🔹 Employee ID not found in preferences.");
        Utils.snackBar(TranslationKeys.employeeIdNotFound.tr, true);
        return;
      }

      final response = await _repo.getEmployeeOvertime(
        employeeId: employeeId,
        page: page,
        limit: pageLimit,
      );
      if (response == null) return;

      final parsed = OvertimeModel.fromJson(response);
      if (append) {
        overtimes.addAll(parsed.data);
      } else {
        overtimes.assignAll(parsed.data);
      }
      currentPage.value = parsed.pagination.page;
      totalPages.value = parsed.pagination.totalPages;
      totalRecords.value = parsed.pagination.total;
      log("✅ Overtime fetched: ${overtimes.length}/${totalRecords.value}");
    } catch (e, st) {
      log("❌ fetchOvertimes: $e", stackTrace: st);
      Utils.snackBar("${TranslationKeys.error.tr}: $e", true);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// ✅ Load the next page for infinite scroll.
  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    await fetchOvertimes(page: currentPage.value + 1, append: true);
  }

  /// ✅ Create an overtime request.
  Future<void> createOvertimeRequest() async {
    if (isSubmitting.value) return;

    final date = selectedDate.value;
    final reason = reasonController.text.trim();

    if (date == null || durationMinutes <= 0 || reason.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      Utils.snackBar(TranslationKeys.pleaseFillAllRequiredFields.tr, true);
      return;
    }

    isSubmitting.value = true;
    try {
      final employeeId = await _employeeId();
      if (employeeId.isEmpty) {
        FocusManager.instance.primaryFocus?.unfocus();
        Utils.snackBar(TranslationKeys.employeeIdNotFound.tr, true);
        return;
      }

      final data = {
        "employee_id": employeeId,
        "date":
            "${date.year.toString().padLeft(4, '0')}-"
            "${date.month.toString().padLeft(2, '0')}-"
            "${date.day.toString().padLeft(2, '0')}",
        "duration_minutes": durationMinutes,
        "reason": reason,
      };
      log("⏱️ Overtime create payload: $data");

      final response = await _repo.createOvertime(data);
      if (response == null) return;

      // Snackbar already shown in repository. Refresh from page 1 so the new
      // request (server-generated id/status) shows at the top.
      clearForm();
      Get.back();
      await fetchOvertimes(page: 1);
    } catch (e, st) {
      log("❌ createOvertimeRequest: $e", stackTrace: st);
    } finally {
      isSubmitting.value = false;
    }
  }

  /// ✅ Clear form fields
  void clearForm() {
    reasonController.clear();
    selectedDate.value = null;
    hours.value = 0;
    minutes.value = 0;
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
