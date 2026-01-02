import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/leave_request_model.dart';
import 'package:supergithr/models/leave_type_model.dart';
import 'package:supergithr/network/repository/attendance_repo/leave_repo.dart';
import 'package:supergithr/utils/utils.dart';

class LeaveController extends GetxController {
  final LeaveRepository _repo = LeaveRepository();

  /// Observables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var isHistoryLoading = false.obs;
  var isLoadingMore = false.obs;
  var isLoadingMoreHistory = false.obs;

  var leaveTypes = <LeaveTypeModel>[].obs;
  var leaveHistory = <LeaveRequestModel>[].obs;
  var selectedLeaveTypeId = RxnString();

  /// Pagination variables for leave types
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var pageSize = 100.obs;
  var hasMore = true.obs;

  /// Pagination variables for leave history
  var historyCurrentPage = 1.obs;
  var historyTotalPages = 1.obs;
  var historyTotalItems = 0.obs;
  var historyPageSize = 10.obs;
  var hasMoreHistory = true.obs;

  /// Form controllers
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final totalDaysController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  void onInit() {
    log("✅ LeaveController initialized");
    super.onInit();
  }

  /// ✅ Fetch Leave Types (Initial Load)
  Future<void> fetchLeaveTypes({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      leaveTypes.clear();
      hasMore.value = true;
    }

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final response = await _repo.getLeaveTypes(
        page: currentPage.value,
        pageSize: pageSize.value,
      );

      if (response != null && response["data"] != null) {
        final types = (response["data"] as List)
            .map((e) => LeaveTypeModel.fromJson(e))
            .toList();

        if (currentPage.value == 1) {
          leaveTypes.assignAll(types);
        } else {
          leaveTypes.addAll(types);
        }

        // Update pagination metadata
        totalPages.value = response["total_pages"] ?? 1;
        totalItems.value = response["total"] ?? 0;
        hasMore.value = currentPage.value < totalPages.value;

        log("✅ Leave Types fetched: Page ${currentPage.value}/${totalPages.value}, Items: ${types.length}, Total: ${totalItems.value}");
      } else {
        log("⚠️ Failed to load leave types - response was null");
        hasMore.value = false;
      }
    } catch (e) {
      // Don't show error message - let the 401 interceptor handle session expiry
      log("❌ Error loading leave types: $e");
      hasMore.value = false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// ✅ Load More Leave Types
  Future<void> loadMoreLeaveTypes() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) {
      return;
    }

    currentPage.value++;
    await fetchLeaveTypes();
  }

  /// ✅ Refresh Leave Types
  Future<void> refreshLeaveTypes() async {
    await fetchLeaveTypes(refresh: true);
  }

  /// ✅ Submit Leave Request
  Future<void> submitLeaveRequest() async {
    final startDate = startDateController.text.trim();
    final endDate = endDateController.text.trim();
    final totalDays = totalDaysController.text.trim();
    final reason = reasonController.text.trim();

    if (selectedLeaveTypeId.value == null ||
        startDate.isEmpty ||
        endDate.isEmpty ||
        totalDays.isEmpty ||
        reason.isEmpty) {
      Utils.snackBar("Please fill all required fields", true);
      return;
    }

    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar("Employee ID not found. Please log in again.", true);
        isSubmitting.value = false;
        return;
      }

      final data = {
        "employee_id": employeeId,
        "leave_type_id": selectedLeaveTypeId.value,
        "start_date": startDate,
        "end_date": endDate,
        "total_days": int.tryParse(totalDays) ?? 1,
        "reason": reason,
      };

      final response = await _repo.submitLeaveRequest(data: data);
      isSubmitting.value = false;

      if (response != null && response["data"] != null) {
        final leaveRequest = LeaveRequestModel.fromJson(response["data"]);
        
        // Add the new leave request to the top of the history list
        leaveHistory.insert(0, leaveRequest);
        historyTotalItems.value++;
        
        Utils.snackBar("Leave request submitted successfully!", false);
        clearForm();
        log("✅ Leave Request: ${leaveRequest.toJson()}");
        
        // Navigate back to requests screen
        Get.back();
      } else {
        Utils.snackBar("Failed to submit leave request", true);
      }
    } catch (e) {
      isSubmitting.value = false;
      Utils.snackBar("Error submitting leave request: $e", true);
    }
  }

  /// ✅ Fetch Employee Leave History with Pagination
  Future<void> getEmployeeLeaveHistory({bool refresh = false}) async {
    if (refresh) {
      historyCurrentPage.value = 1;
      leaveHistory.clear();
      hasMoreHistory.value = true;
    }

    if (historyCurrentPage.value == 1) {
      isHistoryLoading.value = true;
    } else {
      isLoadingMoreHistory.value = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? "";

      if (employeeId.isEmpty) {
        Utils.snackBar("Employee ID not found. Please log in again.", true);
        return;
      }

      final response = await _repo.getEmployeeLeaveHistory(
        employeeId,
        page: historyCurrentPage.value,
        pageSize: historyPageSize.value,
      );

      if (response != null && response["data"] != null) {
        final history = (response["data"] as List)
            .map((e) => LeaveRequestModel.fromJson(e))
            .toList();

        if (historyCurrentPage.value == 1) {
          leaveHistory.assignAll(history);
        } else {
          leaveHistory.addAll(history);
        }

        // Update pagination metadata
        historyTotalPages.value = response["total_pages"] ?? 1;
        historyTotalItems.value = response["total"] ?? 0;
        hasMoreHistory.value = historyCurrentPage.value < historyTotalPages.value;

        log("✅ Leave history fetched: Page ${historyCurrentPage.value}/${historyTotalPages.value}, Items: ${history.length}, Total: ${historyTotalItems.value}");
      } else {
        hasMoreHistory.value = false;
      }
    } catch (e, st) {
      log("❌ Error fetching leave history: $e", stackTrace: st);
      hasMoreHistory.value = false;
    } finally {
      isHistoryLoading.value = false;
      isLoadingMoreHistory.value = false;
    }
  }

  /// ✅ Load More Leave History
  Future<void> loadMoreLeaveHistory() async {
    if (!hasMoreHistory.value || isLoadingMoreHistory.value || isHistoryLoading.value) {
      return;
    }

    historyCurrentPage.value++;
    await getEmployeeLeaveHistory();
  }

  /// ✅ Refresh Leave History
  Future<void> refreshLeaveHistory() async {
    await getEmployeeLeaveHistory(refresh: true);
  }

  /// ✅ Clear Form Fields
  void clearForm() {
    startDateController.clear();
    endDateController.clear();
    totalDaysController.clear();
    reasonController.clear();
    selectedLeaveTypeId.value = null;
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    totalDaysController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
