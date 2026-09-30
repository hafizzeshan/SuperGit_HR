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
  /// Employee list filters.
  final statusFilter = Rxn<OvertimeStage>();
  final monthFilter = Rxn<String>();

  /// Approvals queue, shared by the manager and admin screens.
  final approvals = <OvertimeDatum>[].obs;
  final isLoadingApprovals = false.obs;
  final approvalFilter = Rxn<OvertimeStage>();
  final decidingId = ''.obs;

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

      final response = await _repo.list(
        employeeId: employeeId,
        page: page,
        limit: pageLimit,
        status: statusFilter.value?.queryValue,
        month: monthFilter.value,
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

      final response = await _repo.create(data);
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

  /// Applies a status filter and reloads from page 1.
  void setStatusFilter(OvertimeStage? stage) {
    if (statusFilter.value == stage) return;
    statusFilter.value = stage;
    fetchOvertimes(page: 1);
  }

  void setMonthFilter(String? month) {
    if (monthFilter.value == month) return;
    monthFilter.value = month;
    fetchOvertimes(page: 1);
  }

  /// Edits a request the manager has not acted on yet.
  Future<bool> updateOvertimeRequest(String id) async {
    if (isSubmitting.value) return false;

    final date = selectedDate.value;
    final reason = reasonController.text.trim();
    if (date == null || durationMinutes <= 0 || reason.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      Utils.snackBar(TranslationKeys.pleaseFillAllRequiredFields.tr, true);
      return false;
    }

    isSubmitting.value = true;
    try {
      final employeeId = await _employeeId();
      final response = await _repo.update(id, {
        "employee_id": employeeId,
        "date": _apiDate(date),
        "duration_minutes": durationMinutes,
        "reason": reason,
      });
      if (response == null) {
        Utils.snackBar(TranslationKeys.failedToUpdateReport.tr, true);
        return false;
      }
      clearForm();
      await fetchOvertimes(page: 1);
      Utils.snackBar(TranslationKeys.reportUpdatedSuccessfully.tr, false);
      return true;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Cancels a request that has not been approved yet.
  Future<bool> deleteOvertimeRequest(String id) async {
    final ok = await _repo.delete(id);
    if (ok) {
      overtimes.removeWhere((o) => o.id == id);
      totalRecords.value = (totalRecords.value - 1).clamp(0, 1 << 30);
      Utils.snackBar(TranslationKeys.requestDeleted.tr, false);
    } else {
      Utils.snackBar(TranslationKeys.failedToDeleteReport.tr, true);
    }
    return ok;
  }

  static String _apiDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";

  // ── approvals queue (manager + admin share this state) ────────────────

  /// Loads whichever queue [isAdmin] asks for. Managers are filtered by
  /// `current_approver_id`; admins see everything at the stage they act on.
  Future<void> loadApprovals({
    required bool isAdmin,
    bool force = false,
  }) async {
    if (isLoadingApprovals.value) return;
    try {
      isLoadingApprovals.value = true;
      final approverId = await _employeeId();
      final response = await _repo.list(
        currentApproverId: isAdmin ? null : approverId,
        page: 1,
        limit: 50,
        status: approvalFilter.value?.queryValue,
      );
      final parsed = response == null ? null : OvertimeModel.fromJson(response);
      approvals.assignAll(parsed?.data ?? const <OvertimeDatum>[]);
    } finally {
      isLoadingApprovals.value = false;
    }
  }

  void setApprovalFilter({required bool isAdmin, OvertimeStage? stage}) {
    if (approvalFilter.value == stage) return;
    approvalFilter.value = stage;
    loadApprovals(isAdmin: isAdmin, force: true);
  }

  Future<void> decide({
    required bool isAdmin,
    required OvertimeDatum request,
    required bool approve,
    String remarks = '',
    String reason = '',
  }) async {
    if (decidingId.value.isNotEmpty) return;
    try {
      decidingId.value = request.id;
      final ok =
          approve
              ? (isAdmin
                  ? await _repo.adminApprove(id: request.id, remarks: remarks)
                  : await _repo.managerApprove(
                    id: request.id,
                    remarks: remarks,
                  ))
              : await _repo.reject(
                id: request.id,
                remarks: remarks,
                reason: reason,
              );

      if (ok) {
        Utils.snackBar(TranslationKeys.decisionSaved.tr, false);
        await loadApprovals(isAdmin: isAdmin, force: true);
      } else {
        Utils.snackBar(TranslationKeys.failedToSaveDecision.tr, true);
      }
    } finally {
      decidingId.value = '';
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
